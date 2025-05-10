import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditMoodView: View {
    @Environment(\.dismiss) var dismiss
    var entry: MoodEntry
    var onSave: () -> Void

    @State private var moodValues: [String: Double] = [:]
    @State private var note: String = ""
    @State private var showSuccessMessage = false

    // Expand/collapse control
    @State private var showPositive = true
    @State private var showNegative = false
    @State private var showNeutral = false

    var body: some View {
        NavigationStack {
            VStack {
                if showSuccessMessage {
                    Text("✅ Mood updated successfully!")
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Edit Mood")
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

                        Button("Save Changes") {
                            saveChanges()
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom)
                    }
                    .padding()
                }
            }
            //.navigationTitle("Edit Mood")
            .onAppear {
                moodValues = entry.moods.mapValues { Double($0) }
                note = entry.note ?? ""
            }
        }
    }

    // MARK: - Mood categories
    let positiveMoods = ["joy", "calm", "inspired", "inLove", "gratitude", "pride", "hopeful", "energetic"]
    let negativeMoods = ["sadness", "anger", "fear", "anxiety", "loneliness", "tiredness", "disappointment", "guilt"]
    let neutralMoods  = ["boredom", "confusion", "emptiness", "apathy", "surprised", "mixedFeelings"]

    func moodSlider(_ mood: String) -> some View {
        VStack(alignment: .leading) {
            Text("\(formatMoodLabel(mood)): \(Int(moodValues[mood] ?? 0))")
            Slider(value: Binding(
                get: { moodValues[mood] ?? 0 },
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

    func saveChanges() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var updatedData: [String: Any] = [
            "timestamp": Timestamp(date: entry.timestamp),
            "moods": moodValues.mapValues { Int($0) }
        ]

        if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updatedData["note"] = note
        }

        Firestore.firestore()
            .collection("users").document(uid)
            .collection("moods").document(entry.id)
            .setData(updatedData) { error in
                if let error = error {
                    print("❌ Error updating mood: \(error.localizedDescription)")
                } else {
                    showSuccessMessage = true
                    print("✅ Mood updated")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showSuccessMessage = false
                        onSave()
                        dismiss()
                    }
                }
            }
    }
}
