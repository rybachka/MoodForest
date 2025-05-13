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

    // Expand/collapse
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

                        DisclosureGroup("Positive emotions", isExpanded: $showPositive) {
                            VStack(spacing: 12) {
                                ForEach(positiveMoods, id: \.self, content: moodSlider)
                            }
                        }.font(.headline)

                        DisclosureGroup("Negative emotions", isExpanded: $showNegative) {
                            VStack(spacing: 12) {
                                ForEach(negativeMoods, id: \.self, content: moodSlider)
                            }
                        }.font(.headline)

                        DisclosureGroup("Neutral emotions", isExpanded: $showNeutral) {
                            VStack(spacing: 12) {
                                ForEach(neutralMoods, id: \.self, content: moodSlider)
                            }
                        }.font(.headline)

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

    // MARK: - Mood slider
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

    // MARK: - Slider logic
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

    // MARK: - Save to Firestore
    func saveChanges() {
        guard let user = Auth.auth().currentUser else { return }

        let moodInts = moodValues.mapValues { Int($0) }

        let total = moodInts.values.reduce(0, +)
        let posSum = positiveMoods.map { moodInts[$0] ?? 0 }.reduce(0, +)
        let negSum = negativeMoods.map { moodInts[$0] ?? 0 }.reduce(0, +)
        let neuSum = neutralMoods.map { moodInts[$0] ?? 0 }.reduce(0, +)

        let percent: (Int) -> Int = { sum in
            total > 0 ? Int(round(Double(sum) / Double(total) * 100)) : 0
        }

        var updatedData: [String: Any] = [
            "timestamp": Timestamp(date: entry.timestamp),
            "moods": moodInts,
            "positivePct": percent(posSum),
            "negativePct": percent(negSum),
            "neutralPct": percent(neuSum),
            "uid": user.uid
        ]

        if !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updatedData["note"] = note
        }

        // Save to both global and user-specific collections
        let db = Firestore.firestore()

        // 🌍 Global collection update
        db.collection("moods").document(entry.id).setData(updatedData, merge: true)

        // 👤 User-specific collection update
        db.collection("users")
            .document(user.uid)
            .collection("moods")
            .document(entry.id)
            .setData(updatedData, merge: true) { error in
                if let error = error {
                    print("❌ Error updating mood: \(error.localizedDescription)")
                } else {
                    print("✅ Mood updated in both global and user collections")
                    showSuccessMessage = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showSuccessMessage = false
                        onSave()
                        dismiss()
                    }
                }
            }
    }

}
