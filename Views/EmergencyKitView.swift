import SwiftUI

struct EmergencyKitView: View {
    let items: [EmergencyItem]
    @ObservedObject var gameState: GameState
    let onItemCollected: (EmergencyItem) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select the necessary items for your emergency kit.")
                .font(.title3)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(items) { item in
                    ItemCard(item: item, onCollected: onItemCollected)
                }
            }
        }
    }
}
