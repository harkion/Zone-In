//
//  ContentView.swift
//  Zone In
//
//  Created by Fahri Can on 04/04/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GameView()
                .tabItem {
                    Label("Game", systemImage: "gamecontroller.fill")
                }

            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
