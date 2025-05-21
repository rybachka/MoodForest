import SwiftUI
import WebKit

struct RestView: View {
    // YouTube Video IDs
    let videoIDs = [
        "xNN7iTA57jM", // Rain in forest
        "V1RPi2MYptM", // Gentle thunderstorm
        "1ZYbU82GVz4", // Deep sleep rain
        "29XymHesxa0", // Window rain + night sounds
        "uwEaQk5VeS4"  // Rain on leaves
    ]

    @State private var selectedVideoID: String = "xNN7iTA57jM"

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("🌧️ Choose your rest sound")
                    .font(.headline)
                    .padding(.top)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(videoIDs, id: \.self) { id in
                            Button(action: {
                                selectedVideoID = id
                            }) {
                                VStack {
                                    Image(systemName: "play.rectangle.fill")
                                        .resizable()
                                        .frame(width: 60, height: 40)
                                        .foregroundColor(.blue)

                                    Text("Video \(videoIDs.firstIndex(of: id)! + 1)")
                                        .font(.caption)
                                }
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Divider()


                YouTubePlayerView(videoID: selectedVideoID)
                    .frame(height: 250)
                    .cornerRadius(12)
                    .shadow(radius: 5)

                Text("Just close your eyes and relax")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)


                Spacer()
            }
            .padding()
            .navigationTitle("Rain Rest")
        }
    }
}

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let embedURL = "https://www.youtube.com/embed/\(videoID)?playsinline=1"
        if let url = URL(string: embedURL) {
            webView.scrollView.isScrollEnabled = false
            webView.load(URLRequest(url: url))
        }
    }
}
