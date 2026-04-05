//
//  GameView.swift
//  Zone In
//
//  Created by Fahri Can on 04/04/2026.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.18),
                        Color.purple.opacity(0.18),
                        Color.pink.opacity(0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    gameStore.registerWrongTap()
                }

                VStack(spacing: 16) {
                    header
                    Spacer()
                    centerArea(screenSize: geo.size)
                    Spacer()
                    bottomSummary
                }
                .padding()

                if gameStore.gameState == .playing {
                    TargetButton {
                        gameStore.tapTarget(screenSize: geo.size)
                    }
                    .position(gameStore.targetPosition)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text("Zone In")
                .font(.largeTitle.bold())

            HStack(spacing: 12) {
                statCard(title: "Score", value: "\(gameStore.score)")
                statCard(title: "Wrong", value: " X \(gameStore.wrongTaps)")
                statCard(title: "Time", value: String(format: "%.1f", gameStore.timeRemaining))
            }
        }
    }

    @ViewBuilder
    private func centerArea(screenSize: CGSize) -> some View {
        switch gameStore.gameState {
        case .idle:
            VStack(spacing: 14) {
                Text("Tap the moving target as many times as you can before time runs out.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button {
                    gameStore.startCountdown(screenSize: screenSize)
                } label: {
                    Text("Start Game")
                        .font(.headline)
                        .frame(maxWidth: 220)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))

        case .countdown(let number):
            VStack(spacing: 10) {
                Text("Get Ready")
                    .font(.title2.bold())

                Text("\(number)")
                    .font(.system(size: 84, weight: .black, design: .rounded))
            }
            .padding(30)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28))

        case .playing:
            Text("Go!")
                .font(.title.bold())
                .padding(.horizontal, 26)
                .padding(.vertical, 12)
                .background(.regularMaterial)
                .clipShape(Capsule())

        case .finished:
            VStack(spacing: 12) {
                Text("Time's Up")
                    .font(.title.bold())

                Text("Final Score: \(gameStore.score)")
                    .font(.title3.weight(.semibold))

                Text("Wrong Taps: ❌ \(gameStore.wrongTaps)")
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button("Play Again") {
                        gameStore.startCountdown(screenSize: screenSize)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Reset") {
                        gameStore.resetToIdle()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(24)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28))
        }
    }

    private var bottomSummary: some View {
        VStack(spacing: 8) {
            if let localBest = gameStore.localHighScores.first {
                Text("Best Local Score: \(localBest.playerName) - \(localBest.score)")
                    .font(.subheadline)
            } else {
                Text("No local scores yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 12)
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
