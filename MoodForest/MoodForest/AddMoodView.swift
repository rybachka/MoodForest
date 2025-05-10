import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddMoodView: View {
    @State private var moodValues: [String: Double] = [
        // Positive
        "joy": 12.5, "calm": 12.5, "inspired": 12.5, "inLove": 12.5,
        "gratitude": 12.5, "pride": 12.5, "hopeful": 12.5, "energetic": 12.5,
        // Negative
        "sadness": 0, "anger": 0, "fear": 0, "anxiety": 0,
        "loneliness": 0, "tiredness": 0, "disappointment": 0, "guilt": 0,
        // Neutral
        "boredom": 0, "confusion": 0, "emptiness": 0, "apathy": 0,
        "surprised": 0, "mixedFeelings": 0
    ]
    
    @State private var note: String = ""
    @State private var showSuccessMessage = false
    @Environment(\.dismiss) var dismiss
    
    // Collapsible control
    @State private var showPositive = false
    @State private var showNegative = false
    @State private var showNeutral = false

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

                        DisclosureGroup("Positive", isExpanded: $showPositive) {
                            VStack(spacing: 12) {
                                ForEach(positiveMoods, id: \.self, content: moodSlider)
                            }
                        }
                        .font(.headline)

                        DisclosureGroup("Negative", isExpanded: $showNegative) {
                            VStack(spacing: 12) {
                                ForEach(negativeMoods, id: \.self, content: moodSlider)
                            }
                        }
                        .font(.headline)

                        DisclosureGroup("Neutral", isExpanded: $showNeutral) {
                            VStack(spacing: 12) {
                                ForEach(neutralMoods, id: \.self, content: moodSlider)
                            }
                        }
                        .font(.headline)

                        Group {
                            Text("Note (optional)").font(.headline)
                            TextEditor(text: $note)
                                .frame(height: 100)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        }

                        Button(action: saveMood) {
                            Text("Save Mood")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: - Mood categories
    let positiveMoods = ["joy", "calm", "inspired", "inLove", "gratitude", "pride", "hopeful", "energetic"]
    let negativeMoods = ["sadness", "anger", "fear", "anxiety", "loneliness", "tiredness", "disappointment", "guilt"]
    let neutralMoods  = ["boredom", "confusion", "emptiness", "apathy", "surprised", "mixedFeelings"]

    // MARK: - Mood slider
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

    // MARK: - Slider sum logic
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

    // MARK: - Firestore
    func saveMood() {
        guard let user = Auth.auth().currentUser else { return }

        let db = Firestore.firestore()
        let moodData = moodValues.mapValues { Int($0) }

        var entry: [String: Any] = [
            "timestamp": Timestamp(date: Date()),
            "moods": moodData
        ]

        if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            entry["note"] = note
        }

        db.collection("users")
            .document(user.uid)
            .collection("moods")
            .addDocument(data: entry) { error in
                if let error = error {
                    print("❌ Error saving mood: \(error.localizedDescription)")
                } else {
                    print("✅ Mood saved to Firestore")
                    showSuccessMessage = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        dismiss()
                    }
                }
            }
    }
}
