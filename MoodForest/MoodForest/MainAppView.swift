import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var showProfile = false
    @State private var showCalendar = false
    @State private var showAddMood = false
    @State private var showHistory = false
    @State private var showTree = false
    @State private var showMap = false
    @State private var refreshTrigger = false


    


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

                HStack(spacing: 40) {
                    // ➕ Add Mood Button
                    Button {
                        showAddMood = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                    }

                    // 📅 Calendar Button
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

                    // 🌳 Mood Tree Button
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

            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showCalendar) {
                CalendarView()
            }
            .sheet(isPresented: $showAddMood) {
                AddMoodView()
            }
            .sheet(isPresented: $showHistory) {
                MoodHistoryView()
            }
            .sheet(isPresented: $showTree) {
                MoodTreeView()
            }
            .sheet(isPresented: $showMap) {
                            MoodMapView() // 🗺️ New view
                        }
            
        }
    }
}
