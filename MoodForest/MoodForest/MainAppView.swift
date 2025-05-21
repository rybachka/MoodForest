import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var showProfile = false
    @State private var showCalendar = false
    @State private var showAddMood = false
    @State private var showHistory = false
    @State private var showTree = false
    @State private var showMap = false
    

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
    
    @State private var boredomSupportTriggered = false
    @State private var showBoredomSupportAlert = false
    @State private var showNewsView = false
    @State private var animateText: Bool = false
    @State private var showStressView = false
    @State private var showWhatIFeelView = false


    
    
    //    @State private var showConfusionSupportAlert = false
    //    @State private var showEmptinessSupportAlert = false
    //    @State private var showSurprisedSupportAlert = false
    //    @State private var showMixedFeelingsSupportAlert = false
    //
    //    @State private var confusionSupportTriggered = false
    //    @State private var emptinessSupportTriggered = false
    //    @State private var surprisedSupportTriggered = false
    //    @State private var mixedFeelingsSupportTriggered = false
    //
    //    @State private var apathySupportTriggered = false
    //    @State private var showApathySupportAlert = false
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Image("download")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    .ignoresSafeArea()
                    //.offset(x: -30)
                    .offset(y: +10)
                
               // Color.black.opacity(0.2).ignoresSafeArea() // Darken for contrast
                
                VStack {
                    //Text("Welcome to MoodForest!")
//                    VStack(spacing: 6) {
//                        Text("MoodForest")
//                            .font(.largeTitle)
//                            .bold()
//                        Text("Every feeling matters 💚")
//                            .font(.headline)
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.top, 30)
//                    
//                    
//                    Spacer()
                    
                    //                Text("Today is:")
                    //                    .font(.subheadline)
                    //                    .foregroundColor(.gray)
                    //
                    //                Text(Date(), style: .date)
                    //                    .font(.title2)
                    //                    .bold()
                    
                    // Spacer()
                    VStack {
                        Spacer() // Push content to center vertically
                        
                        Text("How do you feel today?")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .opacity(animateText ? 1 : 0.3)
                            .scaleEffect(animateText ? 1 : 0.9)
                            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: animateText)
                            .onAppear {
                                animateText = true
                            }
                            .padding(.bottom, 15)
                        
                        Button {
                            showAddMood = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.purple)
                        }
                        
                        Spacer() // Push content to center vertically
                    }
                    
                    HStack(spacing: 20) {
                        HomeButton(icon: "calendar", color: .purple) { showCalendar = true }
                        HomeButton(icon: "tree.fill", color: .green) { showTree = true }
                        HomeButton(icon: "map.fill", color: .blue) { showMap = true }
                        // 📋 History
                        HomeButton(icon: "list.bullet.circle.fill", color: .purple) {
                            showHistory = true
                        }
                        
                    }
                    .padding(.bottom, 20)
                    
                    
                    HomeButton(icon: "heart.circle.fill", color: .red) { showSupportMenu = true }
                        .padding(.bottom, 30)
                }
                .padding()
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
                .sheet(isPresented: $showNewsView) {
                    NewsView()
                }
                .sheet(isPresented: $showStressView) { StressView() }
                .sheet(isPresented: $showWhatIFeelView) {
                    WhatIFeelView()
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
                    if boredomSupportTriggered {
                        showBoredomSupportAlert = true
                        boredomSupportTriggered = false
                    }
                    //                if confusionSupportTriggered {
                    //                    showConfusionSupportAlert = true
                    //                    confusionSupportTriggered = false
                    //                }
                    //                if emptinessSupportTriggered {
                    //                    showEmptinessSupportAlert = true
                    //                    emptinessSupportTriggered = false
                    //                }
                    //                if surprisedSupportTriggered {
                    //                    showSurprisedSupportAlert = true
                    //                    surprisedSupportTriggered = false
                    //                }
                    //                if mixedFeelingsSupportTriggered {
                    //                    showMixedFeelingsSupportAlert = true
                    //                    mixedFeelingsSupportTriggered = false
                    //                }
                    
                }) {
                    AddMoodView(
                        onHighAnger: { supportTriggered = true },
                        onHighSadness: { sadnessSupportTriggered = true },
                        onHighFear: { fearSupportTriggered = true },
                        onHighAnxiety: { anxietySupportTriggered = true },
                        onHighLoneliness: { lonelinessSupportTriggered = true },
                        onHighDisappointment: { disappointmentSupportTriggered = true },
                        onHighGuilt: { guiltSupportTriggered = true },
                        onHighTiredness: { tirednessSupportTriggered = true },
                        onHighBoredom: { boredomSupportTriggered = true },
                        //                    onHighConfusion: { confusionSupportTriggered = true },
                        //                    onHighEmptiness: { emptinessSupportTriggered = true },
                        //                    onHighSurprised: { surprisedSupportTriggered = true },
                        //                    onHighMixedFeelings: { mixedFeelingsSupportTriggered = true },
                        
                        
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
                .alert("Feeling Bored?", isPresented: $showBoredomSupportAlert) {
                    Button("Yes, show news") {
                        showNewsView = true
                    }
                    Button("No, thanks", role: .cancel) {}
                } message: {
                    Text("Do you want to read the latest world news?")
                }
                //            .alert("Support for Confusion", isPresented: $showConfusionSupportAlert) {
                //                Button("OK", role: .cancel) {}
                //            } message: {
                //                Text("It’s okay not to have all the answers right now.\nClarity will come — one step at a time.")
                //            }
                //
                //            .alert("Support for Emptiness", isPresented: $showEmptinessSupportAlert) {
                //                Button("OK", role: .cancel) {}
                //            } message: {
                //                Text("I know it feels hollow inside right now, but this space can be filled with light again.")
                //            }
                //
                //            .alert("Support for Surprise", isPresented: $showSurprisedSupportAlert) {
                //                Button("OK", role: .cancel) {}
                //            } message: {
                //                Text("It’s a lot to take in — give yourself time to process.\nYou don’t have to react right away.")
                //            }
                //
                //            .alert("Support for Mixed Feelings", isPresented: $showMixedFeelingsSupportAlert) {
                //                Button("OK", role: .cancel) {}
                //            } message: {
                //                Text("It’s okay to feel more than one thing at once — emotions are complex, and you don’t have to choose just one.")
                //            }
                //
                
                
                
                
                
                
                
                // Support menu
                .actionSheet(isPresented: $showSupportMenu) {
                    ActionSheet(
                        title: Text("Support Tools"),
                        message: Text("Choose how you'd like to feel better 💙"),
                        buttons: [
                            .default(Text("Box Breathing")) { showBoxBreath = true },
                            .default(Text("Funny GIFs")) { showGifsView = true },
                            .default(Text("Rain Rest")) { showRestView = true },
                            .default(Text("World News")) { showNewsView = true },
                            .default(Text("How to Deal with Stress?")) { showStressView = true },
                            .default(Text("What I feel now?")) {
                                showWhatIFeelView = true
                            },


                                .cancel(Text("Cancel"))

                        ]
                    )
                }
            }
        }
        
    }
}
struct HomeButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .frame(width: 60, height: 60)
                .background(color)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }
}
