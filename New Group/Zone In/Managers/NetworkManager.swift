//
//  NetworkManager.swift
//  Zone In
//
//  Created by Fahri Can on 04/04/2026.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    private let submitScoreURLString = "https://your-domain.com/submit_score.php"
    private let leaderboardURLString = "https://your-domain.com/get_leaderboard.php"

    func submitScore(playerName: String, score: Int, wrongTaps: Int) async {
        guard let url = URL(string: submitScoreURLString) else {
            print("Invalid submit URL")
            return
        }

        let payload = RemoteScoreRequest(playerName: playerName, score: score, wrongTaps: wrongTaps)

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(payload)

            let (_, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Score submit failed")
                return
            }
        } catch {
            print("Submit score error: \(error.localizedDescription)")
        }
    }

    func fetchLeaderboard() async -> [RemoteLeaderboardEntry] {
        guard let url = URL(string: leaderboardURLString) else {
            print("Invalid leaderboard URL")
            return []
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Leaderboard fetch failed")
                return []
            }

            if let decoded = try? JSONDecoder().decode([RemoteLeaderboardEntry].self, from: data) {
                return decoded
            }

            return []
        } catch {
            print("Fetch leaderboard error: \(error.localizedDescription)")
            return []
        }
    }
}
