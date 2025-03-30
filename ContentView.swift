import SwiftUI
import AudioToolbox

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var currentStep = 0
    @State private var timeRemaining: Int = 180 // 3 minutes
    @State private var showTimer = true
    @State private var isGameActive = false
    @State private var showBadgeAlert = false
    @State private var lastEarnedBadge: Badge?
    @State private var items: [EmergencyItem] = [
        EmergencyItem(name: "Water", icon: "drop.fill"),
        EmergencyItem(name: "Flashlight", icon: "flashlight.on.fill"),
        EmergencyItem(name: "First Aid Kit", icon: "cross.case.fill"),
        EmergencyItem(name: "Non-perishable Food", icon: "leaf.fill"),
        EmergencyItem(name: "Battery Radio", icon: "radio.fill"),
        EmergencyItem(name: "Batteries", icon: "minus.plus.batteryblock.fill"),
        EmergencyItem(name: "Important Documents", icon: "doc.fill"),
        EmergencyItem(name: "Cash", icon: "banknote.fill"),
        EmergencyItem(name: "Charged Phone", icon: "phone.fill"),
        EmergencyItem(name: "Medications", icon: "pills.fill"),
        EmergencyItem(name: "Weather Radio", icon: "radio.fill"),
        EmergencyItem(name: "Multi-tool", icon: "wrench.fill")
    ]
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var steps: [EmergencyStep] {
        [
            EmergencyStep(
                title: "Welcome to Emergency Training",
                subtitle: "Become a Safety Hero! 🦸",
                mainContent: AnyView(WelcomeView(gameState: gameState)),
                buttonText: "Start Training",
                points: 10,
                requiredTime: 20
            ),
            EmergencyStep(
                title: "Pack Your Emergency Kit",
                subtitle: "Gather items to your backpack! 🎒",
                mainContent: AnyView(
                    EmergencyKitView(
                        items: items,
                        gameState: gameState,
                        onItemCollected: { item in
                            withAnimation {
                                if let index = items.firstIndex(where: { $0.id == item.id }) {
                                    items[index].isCollected = true
                                    gameState.score += 5
                                    checkAndAwardBadge()
                                }
                            }
                        }
                    )
                ),
                buttonText: "Items Packed",
                points: 30,
                requiredTime: 45
            ),
            EmergencyStep(
                title: "Emergency Numbers Quiz",
                subtitle: "Test your knowledge! 📱",
                mainContent: AnyView(
                    EmergencyQuizView(
                        gameState: gameState,
                        onCorrectAnswer: {
                            gameState.score += 10
                            checkAndAwardBadge()
                        }
                    )
                ),
                buttonText: "Complete Quiz",
                points: 25,
                requiredTime: 35
            ),
            EmergencyStep(
                title: "Safe Meeting Points",
                subtitle: "Find your way to safety! 🏃‍♂️",
                mainContent: AnyView(
                    SafetyMapView(
                        gameState: gameState,
                        onLocationMarked: {
                            gameState.score += 15
                            checkAndAwardBadge()
                        }
                    )
                ),
                buttonText: "Locations Marked",
                points: 20,
                requiredTime: 40
            ),
            EmergencyStep(
                title: "Emergency Signals",
                subtitle: "Learn emergency signals! 🚨",
                mainContent: AnyView(
                    EmergencySignalsView(
                        gameState: gameState,
                        onSignalLearned: {
                            gameState.score += 8
                            checkAndAwardBadge()
                        }
                    )
                ),
                buttonText: "Signals Learned",
                points: 15,
                requiredTime: 40
            )
        ]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.1), .red.opacity(0.1)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            if !isGameActive {
                if gameState.isTrainingComplete {
                    TrainingCompleteView(score: gameState.score) {
                        resetGame()
                    }
                } else {
                    StartView(onStart: startGame)
                }
            } else {
                mainGameView
            }
        }
        .onReceive(timer) { _ in
            if isGameActive && timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    endGame()
                }
            }
        }
        .alert("You have earned a new badge!", isPresented: $showBadgeAlert) {
            Button("Wonderful!", role: .cancel) {}
        } message: {
            if let badge = lastEarnedBadge {
                Text("You have earned the \(badge.name) badge!")
            }
        }
    }
    
    private var mainGameView: some View {
        VStack(spacing: 16) {
            HStack {
                if showTimer {
                    TimerView(timeRemaining: timeRemaining)
                }
                Spacer()
                ScoreView(score: gameState.score)
            }
            .padding()
            
            ProgressBar(current: currentStep, total: steps.count)
                .frame(height: 8)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                Text(steps[currentStep].title)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text(steps[currentStep].subtitle)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom)
            
            ScrollView {
                steps[currentStep].mainContent
                    .padding()
            }
            
            NavigationButton(
                text: steps[currentStep].buttonText,
                action: advanceToNextStep
            )
            .padding()
        }
    }
    
    private func startGame() {
        withAnimation {
            isGameActive = true
            timeRemaining = 180
            currentStep = 0
            gameState.score = 0
            gameState.isTrainingComplete = false
            resetItems()
            SoundManager.shared.playSound(SoundEffect.emergency)
        }
    }
    
    private func resetGame() {
        withAnimation {
            gameState.score = 0
            gameState.currentBadges.removeAll()
            gameState.completedTasks.removeAll()
            gameState.isTrainingComplete = false
            resetItems()
            startGame()
        }
    }
    
    private func resetItems() {
        items = items.map { item in
            var newItem = item
            newItem.isCollected = false
            return newItem
        }
    }
    
    private func advanceToNextStep() {
        withAnimation {
            SoundManager.shared.playSound(SoundEffect.correct)
            if currentStep < steps.count - 1 {
                gameState.score += steps[currentStep].points
                currentStep += 1
                checkAndAwardBadge()
            } else {
                endGame()
            }
        }
    }
    
    private func endGame() {
        withAnimation {
            isGameActive = false
            gameState.isTrainingComplete = true
            SoundManager.shared.playSound(SoundEffect.complete)
        }
    }
    
    private func checkAndAwardBadge() {
        let badgeCriteria = [
            (badge: Badge(name: "Quick Learner", icon: "bolt.fill", description: "Scored 50 points"), requiredScore: 50),
            (badge: Badge(name: "Safety Expert", icon: "shield.fill", description: "Scored 100 points"), requiredScore: 100),
            (badge: Badge(name: "Prepared Hero", icon: "star.fill", description: "Scored 150 points"), requiredScore: 150),
            (badge: Badge(name: "Disaster Master", icon: "trophy.fill", description: "Scored 200 points"), requiredScore: 200)
        ].sorted { $0.requiredScore < $1.requiredScore }
        
        for criteria in badgeCriteria {
            if gameState.score >= criteria.requiredScore &&
                !gameState.currentBadges.contains(where: { $0.name == criteria.badge.name }) {
                gameState.currentBadges.insert(criteria.badge)
                lastEarnedBadge = criteria.badge
                showBadgeAlert = true
                SoundManager.shared.playSound(SoundEffect.complete)
                break // Award only one badge per check
            }
        }
    }
}

struct NavigationButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title3)
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(.red)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
    }
}

struct ItemCard: View {
    let item: EmergencyItem
    let onCollected: (EmergencyItem) -> Void
    
    var body: some View {
        VStack {
            Image(systemName: item.icon)
                .font(.system(size: 30))
            Text(item.name)
                .font(.caption)
        }
        .padding()
        .background(item.isCollected ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture {
            if !item.isCollected {
                onCollected(item)
            }
        }
    }
}

// MARK: - Emergency Numbers Quiz
struct EmergencyQuizView: View {
    @ObservedObject var gameState: GameState
    let onCorrectAnswer: () -> Void
    @State private var selectedAnswers = [Int: Int]()
    
    let emergencyNumbers = [
        EmergencyNumber(
            number: "911",
            description: "Main Emergency Number",
            options: ["811", "911", "211", "511"],
            correctAnswer: 1
        ),
        EmergencyNumber(
            number: "211",
            description: "Community Resources",
            options: ["211", "311", "411", "511"],
            correctAnswer: 0
        ),
        EmergencyNumber(
            number: "311",
            description: "Non-Emergency City Services",
            options: ["211", "311", "411", "511"],
            correctAnswer: 1
        )
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(emergencyNumbers.indices, id: \.self) { index in
                VStack(alignment: .leading, spacing: 10) {
                    Text(emergencyNumbers[index].description)
                        .font(.headline)
                    
                    HStack {
                        ForEach(emergencyNumbers[index].options.indices, id: \.self) { optionIndex in
                            Button(action: {
                                handleAnswer(questionIndex: index, selectedOption: optionIndex)
                            }) {
                                Text(emergencyNumbers[index].options[optionIndex])
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(getButtonColor(questionIndex: index, optionIndex: optionIndex))
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(selectedAnswers[index] != nil)
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    private func handleAnswer(questionIndex: Int, selectedOption: Int) {
        selectedAnswers[questionIndex] = selectedOption
        if selectedOption == emergencyNumbers[questionIndex].correctAnswer {
            SoundManager.shared.playSound(SoundEffect.correct)
            onCorrectAnswer()
        } else {
            SoundManager.shared.playSound(SoundEffect.wrong)
        }
    }
    
    private func getButtonColor(questionIndex: Int, optionIndex: Int) -> Color {
        guard let selected = selectedAnswers[questionIndex] else { return .blue }
        if optionIndex == emergencyNumbers[questionIndex].correctAnswer {
            return .green
        }
        return selected == optionIndex ? .red : .blue
    }
}

struct QuestionCard: View {
    let question: String
    let isAnswered: Bool
    let onAnswer: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(question)
                .font(.headline)
            
            if !isAnswered {
                Button("Answer", action: onAnswer)
                    .buttonStyle(.bordered)
            } else {
                Text("Answered ✓")
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct SafetyMapView: View {
    @ObservedObject var gameState: GameState
    let onLocationMarked: () -> Void
    @State private var markedLocations: Set<UUID> = []
    @State private var selectedEmergencyType: EmergencyType = .tornado
    
    var filteredLocations: [MeetingPoint] {
        MeetingPoint.defaultPoints.filter { $0.emergencyType == selectedEmergencyType }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("• First choose disaster")
                    .font(.title3)
                Text("• Second mark safe meeting points")
                    .font(.title3)
            }
            
            Picker("Emergency Type", selection: $selectedEmergencyType) {
                ForEach([EmergencyType.tornado, .earthquake, .hurricane, .flood], id: \.self) { type in
                    HStack {
                        Text(type.name)
                    }.tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            
            ForEach(filteredLocations) { location in
                LocationRow(
                    location: location,
                    isMarked: markedLocations.contains(location.id),
                    onMark: {
                        markedLocations.insert(location.id)
                        onLocationMarked()
                    }
                )
            }
        }
    }
}

struct LocationRow: View {
    let location: MeetingPoint
    let isMarked: Bool
    let onMark: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
                Text(location.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isMarked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Button("Mark", action: onMark)
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(getBackgroundColor(for: location.emergencyType).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func getBackgroundColor(for type: EmergencyType) -> Color {
        switch type {
        case .tornado: return .purple
        case .earthquake: return .orange
        case .hurricane: return .blue
        case .flood: return .teal
        }
    }
}

struct EmergencySignalsView: View {
    @ObservedObject var gameState: GameState
    let onSignalLearned: () -> Void
    @State private var currentSignal = 0
    
    let signals = [
        ("SOS Signal", "... --- ...  |  3 short, 3 long, 3 short whistles"),
        ("Help Signal", "Wave both arms"),
        ("All Clear", "Wave one arm"),
        ("Need Medical", "Tap head")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Learn Emergency Signals")
                .font(.title3)
            
            ForEach(signals.indices, id: \.self) { index in
                SignalCard(
                    title: signals[index].0,
                    signal: signals[index].1,
                    isLearned: index < currentSignal,
                    canLearn: currentSignal == index,
                    onLearn: {
                        withAnimation {
                            currentSignal += 1
                            onSignalLearned()
                            SoundManager.shared.playSound(SoundEffect.correct)
                        }
                    }
                )
            }
        }
    }
}

struct SignalCard: View {
    let title: String
    let signal: String
    let isLearned: Bool
    let canLearn: Bool
    let onLearn: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            if isLearned {
                VStack {
                    Text(signal)
                        .foregroundStyle(.secondary)
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            } else if canLearn {
                Button("Learn Signal") {
                    onLearn()
                }
                .buttonStyle(.bordered)
                .transition(.scale)
            } else {
                Text("Complete previous signal first")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .font(.title2)
            Text(text)
                .font(.body)
        }
    }
}

struct ProgressBar: View {
    let current: Int
    let total: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                
                Rectangle()
                    .fill(.blue)
                    .frame(width: geometry.size.width * CGFloat(current + 1) / CGFloat(total))
                    .animation(.spring(), value: current)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Training Completion View
struct TrainingCompleteView: View {
    let score: Int
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 100))
                .foregroundColor(.green)
            
            Text("Disaster training completed!")
                .font(.title)
                .bold()
            
            Text("Your total score: \(score)")
                .font(.title2)
            
            Button(action: {
                SoundManager.shared.playSound(SoundEffect.emergency)
                onRestart()
            }) {
                Text("Train yourself again :)")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(.top, 30)
        }
        .padding()
        .onAppear {
            SoundManager.shared.playSound(SoundEffect.complete)
        }
    }
}

// MARK: - Sound Manager
@MainActor
class SoundManager {
    static let shared = SoundManager()
    
    func playSound(_ soundID: SystemSoundID) {
        AudioServicesPlaySystemSound(soundID)
    }
}
