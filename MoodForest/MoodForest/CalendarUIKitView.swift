//
//  CalendarUIKitView.swift
//  MoodForest
//
//  Created by Mariia Rybak on 09.05.2025.
//

import SwiftUI
import UIKit

struct CalendarUIKitView: UIViewRepresentable {
    @Binding var selectedDate: Date

    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        return datePicker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = selectedDate
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CalendarUIKitView

        init(_ parent: CalendarUIKitView) {
            self.parent = parent
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.selectedDate = sender.date
        }
    }
}

//#Preview {
//    CalendarUIKitView()
//}
