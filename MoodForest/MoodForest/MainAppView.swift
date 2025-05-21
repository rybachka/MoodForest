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
    @State private var supportTriggered = false
    @State private var sadnessSupportTriggered = false
    @State private var fearSupportTriggered = false

    @State private var showAngerSupportAlert = false
    @State private var showSadnessSupportAlert = false
    @State private var showFearSupportAlert = false

    @State private var showBoxBreath = false
    @State private var showGifsView = false
    @State private var showSupportMenu = false
    
    @State private var anxietySupportTriggered = false
    @State private var showAnxietySupportAlert = false
    @State private var lonelinessSupportTriggered = false
    @State private var showLonelinessSupportAlert = false

    @State private var disappointmentSupportTriggered = false
    @State private var showDisappointmentSupportAlert = false

    @State private var guiltSupportTriggered = false
    @State private var showGuiltSupportAlert = false
    
    @State private var tirednessSupportTriggered = false
    @State private var showTirednessSupportAlert = false
    @State private var showRestView = false




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
            .sheet(isPresented: $showRestView) {
                RestView()
            }


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
                if fearSupportTriggered {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showFearSupportAlert = true
                        fearSupportTriggered = false
                    }
                }
                if anxietySupportTriggered {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showAnxietySupportAlert = true
                            anxietySupportTriggered = false
                        }
                    }
                if lonelinessSupportTriggered {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showLonelinessSupportAlert = true
                            lonelinessSupportTriggered = false
                        }
                    }
                if disappointmentSupportTriggered {
                    showDisappointmentSupportAlert = true
                    disappointmentSupportTriggered = false
                }
                if guiltSupportTriggered {
                    showGuiltSupportAlert = true
                    guiltSupportTriggered = false
                }
                if tirednessSupportTriggered {
                    showTirednessSupportAlert = true
                    tirednessSupportTriggered = false
                }

            }) {
                AddMoodView(
                    onHighAnger: { supportTriggered = true },
                    onHighSadness: { sadnessSupportTriggered = true },
                    onHighFear: { fearSupportTriggered = true },
                    onHighAnxiety: { anxietySupportTriggered = true },
                    onHighLoneliness: { lonelinessSupportTriggered = true },
                    onHighDisappointment: { disappointmentSupportTriggered = true },
                    onHighGuilt: { guiltSupportTriggered = true },
                    onHighTiredness: { tirednessSupportTriggered = true }
                )
            }

            // Alerts
            .alert("Support for Anger", isPresented: $showAngerSupportAlert) {
                Button("Try Box Breathing") {
                    showBoxBreath = true
                }
                Button("No, thanks", role: .cancel) {}
            } message: {
                Text("""
                Tell yourself: “I’m angry right now, and that’s okay.”
                Physically remove yourself from the situation.

                Do you want to try Box Breathing now?
                """)
            }

            .alert("Feeling Sad?", isPresented: $showSadnessSupportAlert) {
                Button("Yes, show me GIFs!") {
                    showGifsView = true
                }
                Button("No, thanks", role: .cancel) {}
            } message: {
                Text("Do you want to watch funny GIFs?")
            }

            .alert("Support for Fear", isPresented: $showFearSupportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Fear is powerful, but it doesn’t define you.\nYou’ve made it through so much already. 💪")
            }
            
            .alert("Support for Anxiety", isPresented: $showAnxietySupportAlert) {
                Button("Try Box Breathing") {
                    showBoxBreath = true
                }
                Button("No, thanks", role: .cancel) {}
            } message: {
                Text("Breathe. One moment at a time — you are safe, and you are stronger than this feeling.\n\nDo you want to try Box Breathing now?")
            }
            
            .alert("Support for Loneliness", isPresented: $showLonelinessSupportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You are never truly alone.\nYou yourself are the most valuable thing you have.")
            }
            
            .alert("Support for Disappointment", isPresented: $showDisappointmentSupportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("This moment doesn’t erase your worth or your effort.\nYou are still moving forward.")
            }

            .alert("Support for Guilt", isPresented: $showGuiltSupportAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You’re allowed to make mistakes.\nGrowth comes from understanding, not punishment.")
            }
            
            .alert("Support for Tiredness", isPresented: $showTirednessSupportAlert) {
                Button("Yes, take me to rest") {
                    showRestView = true
                }
                Button("No, thanks", role: .cancel) {}
            } message: {
                Text("Rest is not weakness. You deserve to pause, breathe, and heal.\n\nDo you want to relax with your eyes closed to the sound of the rain?")
            }





            // Support menu
            .actionSheet(isPresented: $showSupportMenu) {
                ActionSheet(
                    title: Text("Support Tools"),
                    message: Text("Choose how you'd like to feel better 💙"),
                    buttons: [
                        .default(Text("Box Breathing")) { showBoxBreath = true },
                        .default(Text("Funny GIFs")) { showGifsView = true },
                        .default(Text("Rain Rest")) { showRestView = true },
                        .cancel()
                    ]
                )
            }
        }
    }
}
