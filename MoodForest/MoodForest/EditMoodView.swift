import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EditMoodView: View {
    @Environment(\.dismiss) var dismiss
    var entry: MoodEntry
    var onSave: () -> Void

    @State private var moodValues: [String: Double] = [:]
    @State private var showSuccessMessage = false

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    ForEach(moodValues.keys.sorted(), id: \.self) { mood in
                        VStack(alignment: .leading) {
                            Text("\(mood.capitalized): \(Int(moodValues[mood]!))")
                            Slider(value: Binding(
                                get: { moodValues[mood]! },
                                set: { newValue in updateSliders(for: mood, to: newValue) }
                            ), in: 0...100)
                        }
                    }

                    Button("Save Changes") {
                        saveChanges()
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }

                if showSuccessMessage {
                    Text("✅ Mood updated successfully")
                        .foregroundColor(.green)
                        .padding(.top, 10)
                        .transition(.opacity)
                }
            }
            .navigationTitle("Edit Mood")
            .onAppear {
                moodValues = entry.moods.mapValues { Double($0) }
            }
        }
    }

    // Adjust sliders to ensure total stays 100
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

        let updatedData: [String: Any] = [
            "timestamp": Timestamp(date: entry.timestamp),
            "moods": moodValues.mapValues { Int($0) }
        ]

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
