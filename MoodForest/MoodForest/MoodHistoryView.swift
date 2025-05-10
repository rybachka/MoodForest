import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MoodEntry: Identifiable, Hashable {
    var id: String
    var timestamp: Date
    var moods: [String: Int]
    var note: String?

    static func == (lhs: MoodEntry, rhs: MoodEntry) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MoodHistoryView: View {
    @State private var moodEntries: [MoodEntry] = []
    @State private var isLoading = true
    @State private var showEditSheet: Bool = false
    @State private var selectedEntry: MoodEntry?
    @State private var showDeleteAlert = false
    @State private var entryToDelete: MoodEntry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(moodEntries.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label {
                                Text(entry.timestamp.formatted(date: .long, time: .shortened))
                                    .bold()
                            } icon: {
                                Image(systemName: "calendar")
                            }

                            Spacer()

                            Button {
                                selectedEntry = entry
                                showEditSheet = true
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            Button {
                                entryToDelete = entry
                                showDeleteAlert = true
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }

                        ForEach(entry.moods.sorted(by: { $0.key < $1.key }), id: \.key) { mood, value in
                            Text("\(mood.capitalized): \(value)")
                                .font(.subheadline)
                        }

                        if let note = entry.note, !note.isEmpty {
                            Text("📝 \(note)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.top, 4)
                        }

                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Mood History")
            .onAppear(perform: loadMoods)
            .sheet(item: $selectedEntry) { entry in
                EditMoodView(entry: entry) {
                    loadMoods()
                }
            }
            .alert("Delete Mood Entry", isPresented: $showDeleteAlert, presenting: entryToDelete) { entry in
                Button("Delete", role: .destructive) {
                    deleteMood(entry)
                }
                Button("Cancel", role: .cancel) {}
            } message: { _ in
                Text("Are you sure you want to delete this mood entry? This cannot be undone.")
            }
        }
    }

    func loadMoods() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        Firestore.firestore().collection("users").document(uid).collection("moods").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                moodEntries = documents.compactMap { doc in
                    let data = doc.data()
                    guard let ts = data["timestamp"] as? Timestamp,
                          let moods = data["moods"] as? [String: Int] else { return nil }
                    let note = data["note"] as? String
                    return MoodEntry(id: doc.documentID, timestamp: ts.dateValue(), moods: moods, note: note)

                    
                }
                isLoading = false
            }
        }
    }

    func deleteMood(_ entry: MoodEntry) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("moods")
            .document(entry.id)
            .delete { error in
                if let error = error {
                    print("❌ Failed to delete: \(error.localizedDescription)")
                } else {
                    moodEntries.removeAll { $0.id == entry.id }
                    print("✅ Mood deleted")
                }
            }
    }
}
