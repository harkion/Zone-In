//
//  LeaderboardView.swift
//  Zone In
//
//  Created by Fahri Can on 04/04/2026.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        NavigationStack {
            List {
                Section("Online Leaderboard") {
                    if gameStore.isLoadingLeaderboard {
                        HStack {
                            ProgressView()
                            Text("Loading leaderboard...")
                        }
                    } else if gameStore.remoteLeaderboard.isEmpty {
                        Text("No online scores found yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(gameStore.remoteLeaderboard.enumerated()), id: \.element.id) { index, item in
                            HStack {
                                Text("#\(index + 1)")
                                    .font(.headline)
                                    .frame(width: 42, alignment: .leading)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.playerName)
                                        .font(.headline)
                                    if let date = item.date, !date.isEmpty {
                                        Text(date)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(item.score)")
                                        .font(.title3.bold())
                                    if let wrong = item.wrongTaps {
                                        Text("❌ \(wrong)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Section("Local Scores") {
                    if gameStore.localHighScores.isEmpty {
                        Text("No local scores saved yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(Array(gameStore.localHighScores.enumerated()), id: \.element.id) { index, item in
                            HStack {
                                Text("#\(index + 1)")
                                    .font(.headline)
                                    .frame(width: 42, alignment: .leading)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.playerName)
                                        .font(.headline)
                                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(item.score)")
                                        .font(.title3.bold())
                                    Text("❌ \(item.wrongTaps)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await gameStore.refreshRemoteLeaderboard()
                        }
                    }
                }
            }
        }
    }
}
