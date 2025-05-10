import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CalendarView: View {
    @State private var selectedDate = Date()
    @State private var moodsForSelectedDate: [MoodEntry] = []
    @State private var showAddMood = false
    @State private var showEditSheet = false
    @State private var selectedEntry: MoodEntry?
    @State private var showDeleteAlert = false
    @State private var entryToDelete: MoodEntry?

    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                Text("Calendar")
                    .font(.largeTitle)
                    .bold()

                CalendarUIKitView(selectedDate: $selectedDate)
                    .frame(height: UIScreen.main.bounds.height * 0.35) // Fixed height for calendar
                    .padding(.bottom, 8)

                Text("Selected: \(formattedDate(selectedDate))")
                    .font(.subheadline)

                // Fixed container for mood display
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .frame(height: 220) // <- Adjust this to fit max expected list size

                    if moodsForSelectedDate.isEmpty {
                        Text("You didn’t share your mood this day.")
                            .foregroundColor(.gray)
                    } else {
                        List(moodsForSelectedDate) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(entry.timestamp.formatted(date: .omitted, time: .shortened))
                                        .bold()
                                    Spacer()
                                    Button {
                                        selectedEntry = entry
                                        showEditSheet = true
                                    } label: {
                                        Image(systemName: "pencil")
                                            .foregroundColor(.blue)
                                    }
                                    Button {
                                        entryToDelete = entry
                                        showDeleteAlert = true
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }

                                ForEach(entry.moods.sorted(by: { $0.key < $1.key }), id: \.key) { mood, value in
                                    Text("\(mood.capitalized): \(value)")
                                }

                                if let note = entry.note, !note.isEmpty {
                                    Text("📝 \(note)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .padding(.top, 4)
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        .listStyle(PlainListStyle())
                        .frame(height: 220)
                    }
                }
                .padding(.horizontal)

                // Add Mood Button
                Button {
                    showAddMood = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        Text("Add Mood")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.bottom)
            }

            .padding()
            .onAppear(perform: loadMoodsForSelectedDate)
            .onChange(of: selectedDate) {
                loadMoodsForSelectedDate()
            }

            .sheet(isPresented: $showAddMood) {
                AddMoodView()
            }
            .sheet(item: $selectedEntry) { entry in
                EditMoodView(entry: entry) {
                    loadMoodsForSelectedDate()
                }
            }
            .alert("Delete Mood Entry", isPresented: $showDeleteAlert, presenting: entryToDelete) { entry in
                Button("Delete", role: .destructive) {
                    deleteMood(entry)
                }
                Button("Cancel", role: .cancel) {}
            } message: { _ in
                Text("Are you sure you want to delete this mood entry?")
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    func loadMoodsForSelectedDate() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        Firestore.firestore()
            .collection("users").document(uid)
            .collection("moods")
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("timestamp", isLessThan: Timestamp(date: endOfDay))
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    moodsForSelectedDate = docs.compactMap { doc in
                        let data = doc.data()
                        guard let ts = data["timestamp"] as? Timestamp,
                              let moods = data["moods"] as? [String: Int] else { return nil }
                        return MoodEntry(
                            id: doc.documentID,
                            timestamp: ts.dateValue(),
                            moods: moods,
                            note: data["note"] as? String
                        )
                    }
                }
            }
    }

    func deleteMood(_ entry: MoodEntry) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore()
            .collection("users").document(uid)
            .collection("moods").document(entry.id)
            .delete { error in
                if let error = error {
                    print("❌ Failed to delete: \(error.localizedDescription)")
                } else {
                    moodsForSelectedDate.removeAll { $0.id == entry.id }
                    print("✅ Mood deleted")
                }
            }
    }
}
