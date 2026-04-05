//
//  AudioManager.swift
//  Zone In
//
//  Created by Fahri Can on 04/04/2026.
//

import Foundation
import AVFoundation

final class AudioManager {
    static let shared = AudioManager()

    private var players: [String: AVAudioPlayer] = [:]

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error.localizedDescription)")
        }
    }

    func preloadSounds() {
        ["tap", "wrong", "finish"].forEach { loadSound(named: $0) }
    }

    private func loadSound(named name: String) {
        guard players[name] == nil else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Missing sound file: \(name).mp3")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.volume = 1.0
            players[name] = player
        } catch {
            print("Failed to load sound \(name): \(error.localizedDescription)")
        }
    }

    func play(_ name: String) {
        guard let player = players[name] else {
            loadSound(named: name)
            players[name]?.currentTime = 0
            players[name]?.play()
            return
        }

        player.stop()
        player.currentTime = 0
        player.prepareToPlay()
        player.play()
    }
}
