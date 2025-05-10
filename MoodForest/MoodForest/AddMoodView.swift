import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AddMoodView: View {
    @State private var moodValues: [String: Double] = [
        "joy": 20, "calm": 20, "inspire": 20,
        "angry": 10, "sad": 10,
        "bored": 20
    ]
    
    @State private var note: String = ""
    private let moodOrder = ["joy", "calm", "inspire", "angry", "sad", "bored"]
    @Environment(\.dismiss) var dismiss
    @State private var showSuccessMessage = false

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

                        Group {
                            Text("Positive").font(.headline).foregroundColor(.gray)
                            moodSlider("joy")
                            moodSlider("calm")
                            moodSlider("inspire")
                        }

                        Group {
                            Text("Negative").font(.headline).foregroundColor(.gray)
                            moodSlider("angry")
                            moodSlider("sad")
                        }

                        Group {
                            Text("Neutral").font(.headline).foregroundColor(.gray)
                            moodSlider("bored")
                        }

                        Group {
                            Text("Note (optional)")
                                .font(.headline)
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

    func moodSlider(_ mood: String) -> some View {
        VStack(alignment: .leading) {
            Text("\(mood.capitalized): \(Int(moodValues[mood]!))")
            Slider(value: Binding(
                get: { self.moodValues[mood]! },
                set: { newValue in self.updateSliders(for: mood, to: newValue) }
            ), in: 0...100)
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
