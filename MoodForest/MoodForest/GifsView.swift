import SwiftUI

struct GifsView: View {
    let gifURLs = [
        URL(string: "https://media.giphy.com/media/JIX9t2j0ZTN9S/giphy.gif")!,
        URL(string: "https://media.giphy.com/media/3o6ZtaO9BZHcOjmErm/giphy.gif")!,
        URL(string: "https://media.giphy.com/media/l0HlBO7eyXzSZkJri/giphy.gif")!
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Funny GIFs")
                    .font(.largeTitle)
                    .bold()
                
                TabView {
                    ForEach(gifURLs, id: \.self) { url in
                        GIFWebView(gifURL: url)
                            .frame(height: 300)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                            .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            }
        }
    }
}
