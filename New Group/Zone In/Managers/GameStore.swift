//
//  GameStore.swift
//  Zone In
//
//  Created by Fahri Can on 04/04/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class GameStore: ObservableObject {
    @Published var gameState: GameState = .idle
    @Published var score: Int = 0
    @Published var wrongTaps: Int = 0
    @Published var timeRemaining: TimeInterval = GameConfig.gameDuration
    @Published var targetPosition: CGPoint = CGPoint(x: 180, y: 320)
    @Published var playerName: String = "Player"
    @Published var localHighScores: [ScoreEntry] = []
    @Published var remoteLeaderboard: [RemoteLeaderboardEntry] = []
    @Published var isLoadingLeaderboard = false

    private var gameTimer: Timer?
    private var countdownTimer: Timer?

    private let localScoresKey = "zonein.local.scores"
    private let playerNameKey = "zonein.player.name"

    init() {
        loadLocalScores()
        loadPlayerName()
        AudioManager.shared.preloadSounds()

        Task {
            await refreshRemoteLeaderboard()
        }
    }

    deinit {
        gameTimer?.invalidate()
        countdownTimer?.invalidate()
    }

    func startCountdown(screenSize: CGSize) {
        stopTimers()
        resetRoundState()

        var secondsLeft = GameConfig.countdownSeconds
        gameState = .countdown(secondsLeft)

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { return }
            secondsLeft -= 1

            if secondsLeft > 0 {
                self.gameState = .countdown(secondsLeft)
            } else {
                timer.invalidate()
                self.startGame(screenSize: screenSize)
            }
        }
    }

    func startGame(screenSize: CGSize) {
        stopTimers()
        score = 0
        wrongTaps = 0
        timeRemaining = GameConfig.gameDuration
        gameState = .playing
        moveTarget(in: screenSize)

        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self else { return }
            self.timeRemaining -= 0.1

            if self.timeRemaining <= 0 {
                self.timeRemaining = 0
                timer.invalidate()
                self.finishGame()
            }
        }
    }

    func tapTarget(screenSize: CGSize) {
        guard gameState == .playing else { return }
        score += 1
        AudioManager.shared.play("tap")
        moveTarget(in: screenSize)
    }

    func registerWrongTap() {
        guard gameState == .playing else { return }
        wrongTaps += 1
        AudioManager.shared.play("wrong")
    }

    func finishGame() {
        stopTimers()
        gameState = .finished
        AudioManager.shared.play("finish")
        saveLocalScore()

        Task {
            await submitScoreToServer()
            await refreshRemoteLeaderboard()
        }
    }

    func resetToIdle() {
        stopTimers()
        resetRoundState()
        gameState = .idle
    }

    func savePlayerName() {
        let cleaned = sanitizedPlayerName
        playerName = cleaned
        UserDefaults.standard.set(cleaned, forKey: playerNameKey)
    }

    func refreshRemoteLeaderboard() async {
        isLoadingLeaderboard = true
        let scores = await NetworkManager.shared.fetchLeaderboard()
        remoteLeaderboard = scores.sorted { lhs, rhs in
            if lhs.score == rhs.score {
                return (lhs.wrongTaps ?? Int.max) < (rhs.wrongTaps ?? Int.max)
            }
            return lhs.score > rhs.score
        }
        isLoadingLeaderboard = false
    }

    private func submitScoreToServer() async {
        await NetworkManager.shared.submitScore(
            playerName: sanitizedPlayerName,
            score: score,
            wrongTaps: wrongTaps
        )
    }

    private func moveTarget(in screenSize: CGSize) {
        let minX = GameConfig.horizontalPadding
        let maxX = max(GameConfig.horizontalPadding, screenSize.width - GameConfig.horizontalPadding)

        let minY = GameConfig.topSpawnInset
        let maxY = max(GameConfig.topSpawnInset, screenSize.height - GameConfig.bottomSpawnInset)

        targetPosition = CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }

    private func resetRoundState() {
        score = 0
        wrongTaps = 0
        timeRemaining = GameConfig.gameDuration
    }

    private func stopTimers() {
        gameTimer?.invalidate()
        countdownTimer?.invalidate()
        gameTimer = nil
        countdownTimer = nil
    }

    private var sanitizedPlayerName: String {
        let trimmed = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Player" : String(trimmed.prefix(20))
    }

    private func saveLocalScore() {
        let entry = ScoreEntry(
            playerName: sanitizedPlayerName,
            score: score,
            wrongTaps: wrongTaps
        )

        localHighScores.insert(entry, at: 0)
        localHighScores.sort { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.wrongTaps < rhs.wrongTaps
            }
            return lhs.score > rhs.score
        }

        localHighScores = Array(localHighScores.prefix(GameConfig.maxSavedScores))
        persistLocalScores()
    }

    private func persistLocalScores() {
        do {
            let data = try JSONEncoder().encode(localHighScores)
            UserDefaults.standard.set(data, forKey: localScoresKey)
        } catch {
            print("Saving local scores failed: \(error.localizedDescription)")
        }
    }

    private func loadLocalScores() {
        guard let data = UserDefaults.standard.data(forKey: localScoresKey) else { return }

        do {
            localHighScores = try JSONDecoder().decode([ScoreEntry].self, from: data)
        } catch {
            print("Loading local scores failed: \(error.localizedDescription)")
        }
    }

    private func loadPlayerName() {
        if let saved = UserDefaults.standard.string(forKey: playerNameKey), !saved.isEmpty {
            playerName = saved
        }
    }
}
