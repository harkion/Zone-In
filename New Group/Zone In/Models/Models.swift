//
//  Models.swift
//  Zone In
//
//  Created by Fahri Can on 04/04/2026.
//

import Foundation
import CoreGraphics

enum GameState: Equatable {
    case idle
    case countdown(Int)
    case playing
    case finished
}

struct GameConfig {
    static let gameDuration: TimeInterval = 30
    static let countdownSeconds: Int = 3
    static let targetSize: CGFloat = 88
    static let horizontalPadding: CGFloat = 60
    static let topSpawnInset: CGFloat = 180
    static let bottomSpawnInset: CGFloat = 180
    static let maxSavedScores: Int = 50
}

struct ScoreEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let playerName: String
    let score: Int
    let wrongTaps: Int
    let date: Date

    init(
        id: UUID = UUID(),
        playerName: String,
        score: Int,
        wrongTaps: Int,
        date: Date = .now
    ) {
        self.id = id
        self.playerName = playerName
        self.score = score
        self.wrongTaps = wrongTaps
        self.date = date
    }
}

struct RemoteScoreRequest: Codable {
    let playerName: String
    let score: Int
    let wrongTaps: Int
}

struct RemoteLeaderboardEntry: Identifiable, Codable, Hashable {
    let id = UUID()
    let playerName: String
    let score: Int
    let wrongTaps: Int?
    let date: String?

    enum CodingKeys: String, CodingKey {
        case playerName
        case score
        case wrongTaps
        case date
    }
}
