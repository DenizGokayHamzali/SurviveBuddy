import SwiftUI

struct WelcomeView: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.fill.checkmark")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("Welcome to your emergency training!")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 15) {
                InfoRow(icon: "checkmark.shield.fill", text: "Learn essential safety skills")
                InfoRow(icon: "clock.fill", text: "Complete challenges against time")
                InfoRow(icon: "star.fill", text: "Earn points and badges")
            }
        }
    }
}
