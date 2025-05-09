//
//  CalendarView.swift
//  MoodForest
//
//  Created by Mariia Rybak on 09.05.2025.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            Text("Select a date:")
                .font(.title2)
                .padding()

            CalendarUIKitView(selectedDate: $selectedDate)
                .frame(maxHeight: 400)

            Text("Selected: \(formattedDate(selectedDate))")
                .padding()

            Spacer()
        }
        .navigationTitle("Calendar")
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}



//#Preview {
//    CalendarView()
//}
