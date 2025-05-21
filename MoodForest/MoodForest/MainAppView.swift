import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var showProfile = false
    @State private var showCalendar = false
    @State private var showAddMood = false
    @State private var showHistory = false
    @State private var showTree = false
    @State private var showMap = false

    // Support logic
    @State private var showAngerSupportAlert = false
    @State private var showBoxBreath = false
    @State private var supportTriggered = false

    @State private var showSadnessSupportAlert = false
    @State private var showGifsView = false
    @State private var sadnessSupportTriggered = false

    @State private var showSupportMenu = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to MoodForest!")

                Button("Sign Out") {
                    auth.signOut()
                }

                Spacer()

                Text("Today is:")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(Date(), style: .date)
                    .font(.title2)
                    .bold()

                Spacer()

                HStack(spacing: 30) {
                    Button {
                        showAddMood = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.purple)
                    }

                    Button {
                        showCalendar = true
                    } label: {
                        Image(systemName: "calendar")
                            .font(.system(size: 30))
                            .padding()
                            .background(.purple)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }

                    Button {
                        showTree = true
                    } label: {
                        Image(systemName: "tree.fill")
                            .font(.system(size: 30))
                            .padding()
                            .background(.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }

                    Button {
                        showMap = true
                    } label: {
                        Image(systemName: "map.fill")
                            .font(.system(size: 30))
                            .padding()
                            .background(.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }

                    // ❤️ Support Menu
                    Button {
                        showSupportMenu = true
                    } label: {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 30))
                            .padding()
                            .background(.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }

                Button {
                    showHistory = true
                } label: {
                    Image(systemName: "list.bullet.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.purple)
                }
                .padding(.bottom, 30)
            }
            .padding()
            .navigationTitle("MoodForest")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                    }
                }
            }

            // Sheets
            .sheet(isPresented: $showProfile) { ProfileView() }
            .sheet(isPresented: $showCalendar) { CalendarView() }
            .sheet(isPresented: $showHistory) { MoodHistoryView() }
            .sheet(isPresented: $showTree) { MoodTreeView() }
            .sheet(isPresented: $showMap) { MoodMapView() }
            .sheet(isPresented: $showBoxBreath) { BoxBreathView() }
            .sheet(isPresented: $showGifsView) { GifsView() }

            // AddMood logic
            .sheet(isPresented: $showAddMood, onDismiss: {
                if supportTriggered {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showAngerSupportAlert = true
                        supportTriggered = false
                    }
                }
                if sadnessSupportTriggered {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showSadnessSupportAlert = true
                        sadnessSupportTriggered = false
                    }
                }
            }) {
                AddMoodView(
                    onHighAnger: { supportTriggered = true },
                    onHighSadness: { sadnessSupportTriggered = true }
                )
            }

            // Alerts
            .alert("Support for Anger", isPresented: $showAngerSupportAlert) {
                Button("Try Box Breathing") {
                    showBoxBreath = true
                }
                Button("No, thanks", role: .cancel) {}
            } message: {
                Text("Tell yourself: “I’m angry right now, and that’s okay.”\nPhysically remove yourself from the situation.\nDo you want to try Box Breathing now?")
            }

            .alert("Feeling Sad?", isPresented: $showSadnessSupportAlert) {
                Button("Yes, show me GIFs!") {
                    showGifsView = true
                }
                Button("No, thanks", role: .cancel) {}
            } message: {
                Text("Do you want to watch funny GIFs?")
            }

            // Support menu action sheet
            .actionSheet(isPresented: $showSupportMenu) {
                ActionSheet(
                    title: Text("Support Tools"),
                    message: Text("Choose how you'd like to feel better 💙"),
                    buttons: [
                        .default(Text("Box Breathing")) { showBoxBreath = true },
                        .default(Text("Funny GIFs")) { showGifsView = true },
                        .cancel()
                    ]
                )
            }
        }
    }
}
