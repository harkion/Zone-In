//
//  TargetButton.swift
//  Zone In
//
//  Created by Fahri Can on 04/04/2026.
//

import SwiftUI

struct TargetButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.95))
                    .frame(width: GameConfig.targetSize, height: GameConfig.targetSize)

                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: GameConfig.targetSize * 0.68, height: GameConfig.targetSize * 0.68)

                Circle()
                    .fill(Color.white)
                    .frame(width: GameConfig.targetSize * 0.22, height: GameConfig.targetSize * 0.22)
            }
            .shadow(radius: 12)
        }
        .buttonStyle(.plain)
    }
}
