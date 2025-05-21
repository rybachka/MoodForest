import SwiftUI
import SDWebImageSwiftUI
import Foundation



struct Gif: Identifiable, Decodable {
    let id: String
    let images: Images

    struct Images: Decodable {
        let original: Original
        struct Original: Decodable {
            let url: String
        }
    }
}

struct GiphyResponse: Decodable {
    let data: [Gif]
}

struct GifsView: View {
    @State private var gifs: [Gif] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let apiKey = Secrets.giphyApiKey

    var body: some View {
        NavigationStack {
            VStack {
                Text("Funny GIFs")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                if isLoading {
                    ProgressView("Loading GIFs...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(gifs) { gif in
                                if let url = URL(string: gif.images.original.url) {
                                    WebImage(url: url)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 200)
                                        .cornerRadius(10)
                                        .shadow(radius: 5)
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Funny GIFs")
            .onAppear(perform: fetchGifs)
        }
    }

    func fetchGifs() {
        guard let url = URL(string: "https://api.giphy.com/v1/gifs/search?api_key=\(apiKey)&q=funny&limit=25&rating=g") else {
            errorMessage = "❌ Invalid API URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "❌ Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "❌ No data received"
                }
                return
            }

            do {
                let result = try JSONDecoder().decode(GiphyResponse.self, from: data)
                DispatchQueue.main.async {
                    self.gifs = result.data
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "❌ Failed to parse response"
                }
            }
        }.resume()
    }
}

struct Secrets {
    static var giphyApiKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["GIPHY_API_KEY"] as? String else {
            fatalError("GIPHY_API_KEY not found in Secrets.plist")
        }
        return key
    }

    static var newsApiKey: String {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["NEWS_API_KEY"] as? String else {
            fatalError("NEWS_API_KEY not found in Secrets.plist")
        }
        return key
    }
}
