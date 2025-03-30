import SwiftUI

// MARK: - Supporting Views
struct StartView: View {
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(.red)
            
            Text("Emergency Preparedness\nTraining")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Learn life-saving skills in just 3 minutes!")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Button(action: onStart) {
                Text("Start Training")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(.top)
        }
        .padding()
    }
}
