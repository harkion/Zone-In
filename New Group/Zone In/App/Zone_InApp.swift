//
//  Zone_InApp.swift
//  Zone In
//
//  Created by Fahri Can on 04/04/2026.
//

import SwiftUI

@main
struct Zone_InApp: App {
    @StateObject private var gameStore = GameStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameStore)
        }
    }
}
