import SwiftUI

struct TimerView: View {
    let timeRemaining: Int
    
    var body: some View {
        HStack {
            Image(systemName: "timer")
            Text("\(timeRemaining/60):\(String(format: "%02d", timeRemaining%60))")
        }
        .font(.title2)
        .foregroundStyle(timeRemaining < 30 ? .red : .primary)
    }
}

struct ScoreView: View {
    let score: Int
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            Text("\(score)")
        }
        .font(.title2)
    }
}
