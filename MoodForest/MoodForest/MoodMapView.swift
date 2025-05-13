import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth
import Combine


struct MoodMapView: View {
    @State private var annotations: [MoodAnnotation] = []
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 50.061, longitude: 19.938),
            span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        )
    )
    var locationPublisher: AnyPublisher<CLLocation, Never> {
        locationManager.$location
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }


    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Map")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                    .padding(.horizontal)

                Map(position: $cameraPosition) {
                    // Show user location
                    UserAnnotation()

                    // Add mood annotations
                    ForEach(annotations) { mood in
                        Annotation("", coordinate: mood.coordinate) {
                            VStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(mood.annotationColor)
                                    .font(.title2)
                                Text(mood.label)
                                    .font(.caption2)
                                    .padding(4)
                                    .background(.thinMaterial)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                .frame(height: 600)
                .cornerRadius(12)
                .padding()
            }
            .onAppear {
                locationManager.requestLocationPermission()

                // If location is already available
                if let userLoc = locationManager.location {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: userLoc.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                        )
                    )
                }

                loadMoodLocations()
            }
            .onReceive(locationPublisher) { loc in
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: loc.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    )
                )
            }


            .navigationTitle("Mood Map")
        }
    }

    func loadMoodLocations() {
        Firestore.firestore()
            .collection("moods") // ✅ Common collection for all users
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                guard let docs = snapshot?.documents else { return }

                var coordinateMap: [String: Int] = [:]
                self.annotations = docs.compactMap { doc in
                    let data = doc.data()
                    guard
                        let lat = data["latitude"] as? CLLocationDegrees,
                        let lon = data["longitude"] as? CLLocationDegrees
                    else { return nil }

                    let key = "\(lat),\(lon)"
                    let index = coordinateMap[key, default: 0]
                    coordinateMap[key] = index + 1

                    let jitterOffset = 0.001 * Double(index)
                    let adjustedLat = lat + jitterOffset
                    let adjustedLon = lon + jitterOffset

                    let positive = data["positivePct"] as? Int ?? 0
                    let negative = data["negativePct"] as? Int ?? 0
                    let neutral = data["neutralPct"] as? Int ?? 0
                    let note = data["note"] as? String ?? ""

                    return MoodAnnotation(
                        id: doc.documentID,
                        coordinate: CLLocationCoordinate2D(latitude: adjustedLat, longitude: adjustedLon),
                        label: "🙂\(positive)% 😐\(neutral)% 🙁\(negative)%" + (note.isEmpty ? "" : "\n📝\(note)"),
                        annotationColor: colorFor(positive: positive, neutral: neutral, negative: negative)
                    )
                }
            }
    }


    func colorFor(positive: Int, neutral: Int, negative: Int) -> Color {
        if positive >= neutral && positive >= negative {
            return .green
        } else if neutral >= positive && neutral >= negative {
            return .brown
        } else {
            return .black
        }
    }
}

struct MoodAnnotation: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let label: String
    let annotationColor: Color
}
