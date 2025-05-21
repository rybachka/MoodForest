import SwiftUI
import SafariServices

struct NewsArticle: Identifiable, Decodable {
    let id = UUID()
    let title: String
    let url: String

    private enum CodingKeys: String, CodingKey {
        case title, url
    }
}
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}


struct NewsResponse: Decodable {
    let articles: [NewsArticle]
}

struct NewsView: View {
    @State private var articles: [NewsArticle] = []
    @State private var selectedURL: URL? = nil
    @State private var isShowingSafari = false


    var body: some View {
        NavigationStack {
            List(articles) { article in
                Button(action: {
                    if let url = URL(string: article.url) {
                        selectedURL = url
                        isShowingSafari = true
                    }

                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.title)
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("📰 World News")
            .onAppear(perform: fetchNews)
            .sheet(isPresented: $isShowingSafari) {
                if let url = selectedURL {
                    SafariView(url: url)
                }
            }

        }
    }

    func fetchNews() {
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?language=en&pageSize=20&apiKey=\(Secrets.newsApiKey)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            if let decoded = try? JSONDecoder().decode(NewsResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.articles = decoded.articles
                }
            }
        }.resume()
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}

