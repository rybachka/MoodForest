import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreLocation

struct AddMoodView: View {
    var onHighAnger: (() -> Void)? = nil
    var onHighSadness: (() -> Void)? = nil

    @State private var moodValues: [String: Double] = [
        "joy": 12.5, "calm": 12.5, "inspired": 12.5, "inLove": 12.5,
        "gratitude": 12.5, "pride": 12.5, "hopeful": 12.5, "energetic": 12.5,
        "sadness": 0, "anger": 0, "fear": 0, "anxiety": 0,
        "loneliness": 0, "tiredness": 0, "disappointment": 0, "guilt": 0,
        "boredom": 0, "confusion": 0, "emptiness": 0, "apathy": 0,
        "surprised": 0, "mixedFeelings": 0
    ]

    @State private var note: String = ""
    @State private var showSuccessMessage = false
    @Environment(\.dismiss) var dismiss

    @StateObject private var locationManager = LocationManager()
    @State private var showPositive = false
    @State private var showNegative = false
    @State private var showNeutral = false

    let positiveMoods = ["joy", "calm", "inspired", "inLove", "gratitude", "pride", "hopeful", "energetic"]
    let negativeMoods = ["sadness", "anger", "fear", "anxiety", "loneliness", "tiredness", "disappointment", "guilt"]
    let neutralMoods  = ["boredom", "confusion", "emptiness", "apathy", "surprised", "mixedFeelings"]

    var body: some View {
        NavigationStack {
            VStack {
                if showSuccessMessage {
                    Text("✅ Your mood was saved successfully!")
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Today's Mood")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top)

                        DisclosureGroup("Positive emotions", isExpanded: $showPositive) {
                            ForEach(positiveMoods, id: \.self, content: moodSlider)
                        }

                        DisclosureGroup("Negative emotions", isExpanded: $showNegative) {
                            ForEach(negativeMoods, id: \.self, content: moodSlider)
                        }

                        DisclosureGroup("Neutral emotions", isExpanded: $showNeutral) {
                            ForEach(neutralMoods, id: \.self, content: moodSlider)
                        }

                        Group {
                            Text("Note (optional)").font(.headline)
                            TextEditor(text: $note)
                                .frame(height: 100)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        }

                        Button("Save Mood", action: saveMood)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.top, 10)
                    }
                    .padding()
                }
            }
            .onAppear {
                locationManager.requestLocationPermission()
            }
        }
    }

    func moodSlider(_ mood: String) -> some View {
        VStack(alignment: .leading) {
            Text("\(formatMoodLabel(mood)): \(Int(moodValues[mood]!))")
            Slider(value: Binding(
                get: { moodValues[mood]! },
                set: { newValue in updateSliders(for: mood, to: newValue) }
            ), in: 0...100)
        }
    }

    func formatMoodLabel(_ key: String) -> String {
        switch key {
        case "inLove": return "In Love"
        case "mixedFeelings": return "Mixed Feelings"
        default: return key.capitalized
        }
    }

    func updateSliders(for adjustedMood: String, to newValue: Double) {
        var newMoodValues = moodValues
        newMoodValues[adjustedMood] = newValue

        let otherKeys = newMoodValues.keys.filter { $0 != adjustedMood }
        let totalOther = otherKeys.map { moodValues[$0] ?? 0 }.reduce(0, +)
        let remaining = max(0, 100 - newValue)

        if totalOther == 0 {
            let equalShare = remaining / Double(otherKeys.count)
            for key in otherKeys {
                newMoodValues[key] = equalShare
            }
        } else {
            for key in otherKeys {
                let currentValue = moodValues[key] ?? 0
                newMoodValues[key] = (currentValue / totalOther) * remaining
            }
        }

        moodValues = newMoodValues
    }

    func saveMood() {
        guard let user = Auth.auth().currentUser else { return }

        let moodInts = moodValues.mapValues { Int($0) }

        let total = moodInts.values.reduce(0, +)
        let percent: (Int) -> Int = { sum in
            total > 0 ? Int(round(Double(sum) / Double(total) * 100)) : 0
        }

        let posSum = positiveMoods.map { moodInts[$0] ?? 0 }.reduce(0, +)
        let negSum = negativeMoods.map { moodInts[$0] ?? 0 }.reduce(0, +)
        let neuSum = neutralMoods.map { moodInts[$0] ?? 0 }.reduce(0, +)

        let id = UUID().uuidString
        var entry: [String: Any] = [
            "id": id,
            "timestamp": Timestamp(date: Date()),
            "moods": moodInts,
            "positivePct": percent(posSum),
            "negativePct": percent(negSum),
            "neutralPct": percent(neuSum),
            "uid": user.uid
        ]

        if let loc = locationManager.location {
            entry["latitude"] = loc.coordinate.latitude
            entry["longitude"] = loc.coordinate.longitude
        }

        if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            entry["note"] = note
        }

        let db = Firestore.firestore()

        db.collection("moods").document(id).setData(entry)
        db.collection("users")
            .document(user.uid)
            .collection("moods")
            .document(id)
            .setData(entry) { error in
                if let error = error {
                    print("❌ Error saving mood: \(error.localizedDescription)")
                } else {
                    showSuccessMessage = true
                    print("✅ Mood saved to Firestore")

                    let angerLevel = moodInts["anger"] ?? 0
                    let sadnessLevel = moodInts["sadness"] ?? 0

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if angerLevel > 50 {
                            onHighAnger?()
                        }
                        if sadnessLevel > 50 {
                            onHighSadness?()
                        }
                        dismiss()
                    }
                }
            }
    }
}
