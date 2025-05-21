import SwiftUI

struct EmotionInfo: Identifiable {
    let id = UUID()
    let emotion: String
    let purpose: String
    let reflection: String
}

struct WhatIFeelView: View {
    private let emotions: [EmotionInfo] = [
        EmotionInfo(emotion: "Anger", purpose: "Protection and Restoration", reflection: "What must be protected? What must be restored?"),
        EmotionInfo(emotion: "Apathy and Boredom", purpose: "The Mask for Anger", reflection: "What is being avoided? What must be made conscious?"),
        EmotionInfo(emotion: "Guilt and Shame", purpose: "Restoring Integrity", reflection: "Who has been hurt? What must be made right?"),
        EmotionInfo(emotion: "Hatred", purpose: "The Profound Mirror", reflection: "What has fallen into my shadow? What must be reintegrated?"),
        EmotionInfo(emotion: "Fear", purpose: "Intuition and Action", reflection: "What action must be taken?"),
        EmotionInfo(emotion: "Confusion", purpose: "The Mask for Fear", reflection: "What is my intention? What action should be taken?"),
        EmotionInfo(emotion: "Jealousy and Envy", purpose: "Relational Radar", reflection: "What has been betrayed? What must be healed and restored?"),
        EmotionInfo(emotion: "Panic and Terror", purpose: "Frozen Fire", reflection: "What has been frozen in time? What healing action must be taken?"),
        EmotionInfo(emotion: "Sadness", purpose: "Release and Rejuvenation", reflection: "What must be released? What must be rejuvenated?"),
        EmotionInfo(emotion: "Grief", purpose: "The Deep River of the Soul", reflection: "What must be mourned? What must be released completely?"),
        EmotionInfo(emotion: "Depression", purpose: "Ingenious Stagnation", reflection: "Where has my energy gone? Why was it sent away?"),
        EmotionInfo(emotion: "Suicidal Urges", purpose: "The Darkness Before Dawn", reflection: "What idea or behavior must end now? What can no longer be tolerated in my soul?"),
        EmotionInfo(emotion: "Happiness", purpose: "Amusement and Anticipation", reflection: "Thank you for this lively celebration!"),
        EmotionInfo(emotion: "Contentment", purpose: "Appreciation and Recognition", reflection: "Thank you for renewing my faith in myself!"),
        EmotionInfo(emotion: "Joy", purpose: "Affinity and Communion", reflection: "Thank you for this radiant moment!")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("🧠 Emotional Insight")
                        .font(.title)
                        .bold()

                    Text("""
The following analysis is taken from the book “The Language of Emotions” by Karla McLaren. The detailed analysis of each emotion includes associated questions to ask or statements to make when the emotion arises, along with gifts the emotion brings and advice on how to integrate the emotion honorably into one’s life.
""")
                        .font(.body)

                    Divider()

                    Text("🗂️ ♥️Emotional Table")
                        .font(.headline)

                    VStack(spacing: 10) {
                        HStack {
                            Text("Emotion").bold().frame(maxWidth: .infinity, alignment: .leading)
                            Text("Purpose").bold().frame(maxWidth: .infinity, alignment: .leading)
                            Text("Reflection").bold().frame(maxWidth: .infinity, alignment: .leading)
                        }

                        ForEach(emotions) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    Text(item.emotion)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(item.purpose)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(item.reflection)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider()
                            }
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("What I Feel Now?")
        }
    }
}
