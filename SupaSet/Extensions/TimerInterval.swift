//
//  TimerInter.swift
//  SupaSet
//
//  Created by Rishi Garg on 12/23/24.
//

import Foundation

extension TimeInterval {
    func formatAsTimerString() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
