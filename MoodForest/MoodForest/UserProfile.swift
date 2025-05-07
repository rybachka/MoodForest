//
//  UserProfile.swift
//  MoodForest
//
//  Created by Mariia Rybak on 07.05.2025.
//

import Foundation

struct UserProfile: Codable {
    let uid: String
    let firstName: String
    let nickname: String
    let birthday: Date?
    let email: String
}
