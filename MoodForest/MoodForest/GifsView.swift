import SwiftUI
import SDWebImageSwiftUI

struct GifsView: View {
    let gifURLs = [
        "https://media.giphy.com/media/YTbZzCkRQCEJa/giphy.gif",
        "https://media.giphy.com/media/ASd0Ukj0y3qMM/giphy.gif",
        "https://media.giphy.com/media/JIX9t2j0ZTN9S/giphy.gif",
        "https://media.giphy.com/media/3o7aD2saalBwwftBIY/giphy.gif",
        "https://media.giphy.com/media/13HgwGsXF0aiGY/giphy.gif",
        "https://media.giphy.com/media/l0Exk8EUzSLsrErEQ/giphy.gif"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(gifURLs, id: \.self) { url in
                    WebImage(url: URL(string: url))
                        .resizable()
                        .indicator(.activity)
                        .scaledToFit()
                        .frame(height: 220)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Funny GIFs")
    }
}
