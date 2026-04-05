//
//  SettingsView.swift
//  Zone In
//
//  Created by Fahri Can on 04/04/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        NavigationStack {
            Form {
                Section("Player") {
                    TextField("Player name", text: $gameStore.playerName)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled(true)

                    Button("Save Name") {
                        gameStore.savePlayerName()
                    }
                }

                Section("Game Info") {
                    LabeledContent("Platform", value: "iOS")
                    LabeledContent("Framework", value: "SwiftUI")
                    LabeledContent("Countdown", value: "3 seconds")
                    LabeledContent("Wrong taps", value: "Tracked with ❌")
                    LabeledContent("Game duration", value: "30 seconds")
                }

                Section("Backend") {
                    Text("When your PHP files are ready, replace the URLs in NetworkManager.swift.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}
