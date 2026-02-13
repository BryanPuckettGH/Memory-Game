//
//  ContentView.swift
//  MemoryGame
//

import SwiftUI

struct ContentView: View {

    // MARK: - Constants

    private let emojis = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🦁", "🐯", "🐸"]
    private let pairOptions = [2, 4, 6, 8, 10, 12]

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // MARK: - Types

    enum GameMode: Equatable {
        case freePlay
        case challenge(seconds: Int)
        case impossible(seconds: Int)
        case genie(seconds: Int?)  // nil = unlimited
    }

    enum GamePhase: Equatable {
        case setup
        case playing
        case won
        case lost
    }

    enum ActiveSheet: Identifiable, Equatable {
        case freePlay
        case challenge
        case impossible
        case genie

        var id: Int {
            switch self {
            case .freePlay: return 0
            case .challenge: return 1
            case .impossible: return 2
            case .genie: return 3
            }
        }
    }

    // MARK: - State

    @State private var cards: [Card] = []
    @State private var numberOfPairs: Int = 6
    @State private var firstSelectedIndex: Int? = nil
    @State private var gameId: Int = 0

    @State private var gameMode: GameMode = .freePlay
    @State private var gamePhase: GamePhase = .setup

    @State private var elapsedSeconds: Int = 0
    @State private var remainingSeconds: Int = 0
    @State private var timerActive: Bool = false
    @State private var timer: Timer? = nil

    @State private var isShaking: Bool = false

    // Sheet for mode prompts
    @State private var activeSheet: ActiveSheet? = nil

    // Custom timer input (minutes and seconds)
    @State private var timerMinutes: Int = 1
    @State private var timerSeconds: Int = 0

    // Genie timer toggle
    @State private var genieUsesTimer: Bool = false

    // MARK: - Computed

    private var allMatched: Bool {
        !cards.isEmpty && cards.allSatisfy { $0.isMatched }
    }

    private var hasTimed: Bool {
        switch gameMode {
        case .freePlay: return false
        case .challenge: return true
        case .impossible: return true
        case .genie(let s): return s != nil
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private var customTimerTotal: Int {
        timerMinutes * 60 + timerSeconds
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if gamePhase == .setup {
                setupView
            } else {
                gameView
            }

            if gamePhase == .won {
                winOverlay
            }

            if gamePhase == .lost {
                loseOverlay
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .freePlay:
                freePlayPrompt
            case .challenge:
                challengePrompt
            case .impossible:
                impossiblePrompt
            case .genie:
                geniePrompt
            }
        }
    }

    // MARK: - Setup View

    private var setupView: some View {
        VStack(spacing: 24) {

            Spacer()

            Text("🧠")
                .font(.system(size: 80))

            Text("Memory Game")
                .font(.largeTitle)
                .bold()

            // Pairs picker
            VStack(spacing: 8) {
                Text("Card Pairs")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Picker("Pairs", selection: $numberOfPairs) {
                    ForEach(pairOptions, id: \.self) { option in
                        Text("\(option)").tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 30)
            }

            // 4 Mode buttons
            VStack(spacing: 12) {
                // Free Play
                Button { activeSheet = .freePlay } label: {
                    modeButton(icon: "leaf.fill", title: "Free Play", color: .green)
                }

                // Challenge
                Button { activeSheet = .challenge } label: {
                    modeButton(icon: "flame.fill", title: "Challenge", color: .orange)
                }

                // Impossible
                Button { activeSheet = .impossible } label: {
                    modeButton(icon: "bolt.fill", title: "Impossible", color: .red)
                }

                // Genie
                Button { activeSheet = .genie } label: {
                    modeButton(icon: "wand.and.stars", title: "Genie", color: .purple)
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            // Footer
            VStack(spacing: 2) {
                Text("Bryan Puckett")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("PID: 5506132")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 10)
        }
    }

    // Reusable mode button label
    private func modeButton(icon: String, title: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.title3)
        .bold()
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.gradient)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Mode Prompt Sheets

    // --- FREE PLAY ---
    private var freePlayPrompt: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🌿")
                .font(.system(size: 60))

            Text("Free Play")
                .font(.largeTitle)
                .bold()

            Text("Take your time. No pressure, no rush.\nJust you and the cards at your own peaceful pace. A timer will track how long you take, just for fun.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            Button {
                activeSheet = nil
                gameMode = .freePlay
                startGame()
            } label: {
                Text("Begin")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green.gradient)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }

    // --- CHALLENGE ---
    private var challengePrompt: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("🔥")
                .font(.system(size: 60))

            Text("Challenge")
                .font(.largeTitle)
                .bold()

            Text("Oh, you think you've got what it takes?\nSet the clock and let's see who runs out first. You or time itself.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Custom time picker
            timerPickerView

            Button {
                let total = customTimerTotal
                if total > 0 {
                    activeSheet = nil
                    gameMode = .challenge(seconds: total)
                    startGame()
                }
            } label: {
                Text("Let's Go")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange.gradient)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 40)
            .disabled(customTimerTotal == 0)

            Spacer()
        }
        .padding()
        .presentationDetents([.large])
    }

    // --- IMPOSSIBLE ---
    private var impossiblePrompt: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("💀")
                .font(.system(size: 60))

            Text("Impossible")
                .font(.largeTitle)
                .bold()

            Text("Oh, you think you're tough?\nEvery time you miss a match, I'm shuffling the entire board. Good luck remembering anything. Let's see if you can beat me.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Custom time picker
            timerPickerView

            Button {
                let total = customTimerTotal
                if total > 0 {
                    activeSheet = nil
                    gameMode = .impossible(seconds: total)
                    startGame()
                }
            } label: {
                Text("Bring It On")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red.gradient)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 40)
            .disabled(customTimerTotal == 0)

            Spacer()
        }
        .padding()
        .presentationDetents([.large])
    }

    // --- GENIE ---
    private var geniePrompt: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("🧞")
                .font(.system(size: 60))

            Text("Genie Mode")
                .font(.largeTitle)
                .bold()

            Text("Your wish is my command... to make you suffer.\nMiss a match? I wipe all your progress and reshuffle the whole board. Your matched pairs? Gone. Timer keeps going. Think you can outsmart a genie?")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            // Timer toggle
            Toggle(isOn: $genieUsesTimer) {
                Text("Use a Timer")
                    .font(.headline)
            }
            .padding(.horizontal, 40)

            if genieUsesTimer {
                timerPickerView
            }

            Button {
                activeSheet = nil
                if genieUsesTimer && customTimerTotal > 0 {
                    gameMode = .genie(seconds: customTimerTotal)
                } else {
                    gameMode = .genie(seconds: nil)
                }
                startGame()
            } label: {
                Text("Make My Wish")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.purple.gradient)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 40)
            .disabled(genieUsesTimer && customTimerTotal == 0)

            Spacer()
        }
        .padding()
        .presentationDetents([.large])
    }

    // MARK: - Reusable Timer Picker

    private var timerPickerView: some View {
        VStack(spacing: 8) {
            Text("Set Your Time")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                Picker("Minutes", selection: $timerMinutes) {
                    ForEach(0..<60, id: \.self) { m in
                        Text("\(m)").tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 120)
                .clipped()

                Text("min")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Seconds", selection: $timerSeconds) {
                    ForEach(0..<60, id: \.self) { s in
                        Text(String(format: "%02d", s)).tag(s)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80, height: 120)
                .clipped()

                Text("sec")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(customTimerTotal > 0 ? "Total: \(formatTime(customTimerTotal))" : "Pick a time above")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Game View

    private var gameView: some View {
        VStack(spacing: 12) {

            // Top bar
            HStack {
                Button {
                    stopTimer()
                    gamePhase = .setup
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                }

                Spacer()

                // Mode label
                Text(modeLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // Timer display
                HStack(spacing: 6) {
                    Image(systemName: timerIcon)
                        .foregroundStyle(timerColor)
                    Text(timerText)
                        .font(.title2)
                        .bold()
                        .monospacedDigit()
                        .foregroundStyle(timerColor)
                }

                Spacer()

                Button {
                    resetGame()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.headline)
                }
            }
            .padding(.horizontal)

            // Card grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index], isShaking: isShaking && !cards[index].isMatched) {
                            cardTapped(at: index)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .id(gameId)
            .animation(.bouncy, value: cards)

            // Footer
            VStack(spacing: 2) {
                Text("Bryan Puckett")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("PID: 5506132")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 4)
        }
        .padding(.top)
    }

    private var modeLabel: String {
        switch gameMode {
        case .freePlay: return "Free Play"
        case .challenge: return "Challenge"
        case .impossible: return "Impossible"
        case .genie: return "Genie Mode"
        }
    }

    private var timerIcon: String {
        if hasTimed {
            return "timer"
        }
        return "clock"
    }

    private var timerColor: Color {
        if hasTimed {
            if remainingSeconds <= 10 { return .red }
            if remainingSeconds <= 30 { return .orange }
        }
        return .primary
    }

    private var timerText: String {
        if hasTimed {
            return formatTime(remainingSeconds)
        }
        return formatTime(elapsedSeconds)
    }

    // MARK: - Win Overlay

    private var winOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 70))

                Text(winTitle)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)

                Text(winSubtitle)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                Button {
                    gamePhase = .setup
                } label: {
                    Text("Play Again")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Color.green.gradient)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 10)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal, 30)
        }
    }

    private var winTitle: String {
        switch gameMode {
        case .freePlay: return "Great Job!"
        case .challenge: return "You Beat the Clock!"
        case .impossible: return "No Way... You Did It?!"
        case .genie: return "You Outsmarted the Genie!"
        }
    }

    private var winSubtitle: String {
        switch gameMode {
        case .freePlay:
            return "You finished in \(formatTime(elapsedSeconds)). Nice and peaceful."
        case .challenge:
            return "Done with \(formatTime(remainingSeconds)) to spare!"
        case .impossible:
            return "Finished in \(formatTime(elapsedSeconds)).\nI... didn't think that was possible."
        case .genie(let s):
            if s != nil {
                return "Done with \(formatTime(remainingSeconds)) left.\nThe genie bows to you."
            }
            return "Finished in \(formatTime(elapsedSeconds)).\nThe genie bows to you."
        }
    }

    // MARK: - Lose Overlay

    private var loseOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(loseEmoji)
                    .font(.system(size: 70))

                Text(loseTitle)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.white)

                Text(loseSubtitle)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                Button {
                    isShaking = false
                    gamePhase = .setup
                } label: {
                    Text("Try Again")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Color.orange.gradient)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .padding(.top, 10)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal, 30)
        }
    }

    private var loseEmoji: String {
        switch gameMode {
        case .impossible: return "💀"
        case .genie: return "🧞"
        default: return "😬"
        }
    }

    private var loseTitle: String {
        switch gameMode {
        case .impossible: return "Told You So."
        case .genie: return "The Genie Wins."
        default: return "Time's Up!"
        }
    }

    private var loseSubtitle: String {
        switch gameMode {
        case .impossible: return "The board doesn't forget.\nBut you sure did."
        case .genie: return "Your wishes have been denied.\nBetter luck next time."
        default: return "Better luck next time!"
        }
    }

    // MARK: - Game Logic

    private func cardTapped(at index: Int) {
        if gamePhase != .playing { return }
        if cards[index].isFaceUp || cards[index].isMatched { return }

        cards[index].isFaceUp = true

        if let firstIndex = firstSelectedIndex {
            // Second card flipped
            if cards[firstIndex].content == cards[index].content {
                // Match! Instantly turn green, then fade out
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true

                // Allow next move right away, check win after fade
                firstSelectedIndex = nil

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    if allMatched {
                        stopTimer()
                        gamePhase = .won
                    }
                }
            } else {
                // Mismatch! Instantly turn red, then flip back
                let first = firstIndex
                let second = index
                cards[first].isMismatched = true
                cards[second].isMismatched = true

                firstSelectedIndex = nil

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    cards[first].isFaceUp = false
                    cards[first].isMismatched = false
                    cards[second].isFaceUp = false
                    cards[second].isMismatched = false

                    // For shuffle modes, close any card the player tapped
                    // while waiting, so the shuffle doesn't break pairs
                    if case .impossible = gameMode {
                        closeStrayCards()
                        shuffleUnmatched()
                    }

                    if case .genie = gameMode {
                        closeStrayCards()
                        genieReset()
                    }
                }
            }
        } else {
            // First card - close any stray face-up cards
            for i in 0..<cards.count {
                if cards[i].isFaceUp && !cards[i].isMatched && i != index {
                    cards[i].isFaceUp = false
                    cards[i].isMismatched = false
                }
            }
            firstSelectedIndex = index
        }
    }

    // Close any face-up non-matched cards and reset selection
    // Called before shuffle to prevent race conditions from fast tapping
    private func closeStrayCards() {
        firstSelectedIndex = nil
        for i in 0..<cards.count {
            if cards[i].isFaceUp && !cards[i].isMatched {
                cards[i].isFaceUp = false
                cards[i].isMismatched = false
            }
        }
    }

    // Impossible mode: shuffle the emoji content among non-matched positions
    // This keeps pairs intact, every emoji still appears exactly twice
    private func shuffleUnmatched() {
        // Gather indices of unmatched cards
        var unmatchedIndices: [Int] = []
        for i in 0..<cards.count {
            if !cards[i].isMatched {
                unmatchedIndices.append(i)
            }
        }

        // Collect the contents at those positions and shuffle them
        var contents = unmatchedIndices.map { cards[$0].content }
        contents.shuffle()

        // Reassign shuffled contents back to the unmatched positions
        for (i, cardIndex) in unmatchedIndices.enumerated() {
            cards[cardIndex] = Card(
                id: cards[cardIndex].id,
                content: contents[i],
                isFaceUp: false,
                isMatched: false
            )
        }
        gameId += 1
    }

    // Genie mode: un-match everything, reshuffle entire board
    private func genieReset() {
        let contents = cards.map { $0.content }
        var newCards: [Card] = []
        for (i, content) in contents.enumerated() {
            newCards.append(Card(id: i, content: content, isFaceUp: false, isMatched: false))
        }
        cards = newCards.shuffled()
        gameId += 1
    }

    private func startGame() {
        let selected = Array(emojis.prefix(numberOfPairs))
        var newCards: [Card] = []
        var idCounter = 0
        for emoji in selected {
            newCards.append(Card(id: idCounter, content: emoji))
            idCounter += 1
            newCards.append(Card(id: idCounter, content: emoji))
            idCounter += 1
        }
        cards = newCards.shuffled()
        firstSelectedIndex = nil
        gameId += 1
        isShaking = false
        elapsedSeconds = 0

        // Set remaining seconds based on mode
        switch gameMode {
        case .challenge(let s):
            remainingSeconds = s
        case .impossible(let s):
            remainingSeconds = s
        case .genie(let s):
            if let s = s { remainingSeconds = s }
        default:
            break
        }

        gamePhase = .playing
        startTimer()
    }

    private func resetGame() {
        stopTimer()
        startGame()
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        timerActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !timerActive { return }

            elapsedSeconds += 1

            if hasTimed {
                remainingSeconds -= 1
                if remainingSeconds <= 0 {
                    remainingSeconds = 0
                    timeRanOut()
                }
            }
        }
    }

    private func stopTimer() {
        timerActive = false
        timer?.invalidate()
        timer = nil
    }

    private func timeRanOut() {
        stopTimer()

        // Flip all remaining cards face up
        for i in 0..<cards.count {
            if !cards[i].isMatched {
                cards[i].isFaceUp = true
            }
        }

        // Shake then show lose screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShaking = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            gamePhase = .lost
        }
    }
}

#Preview {
    ContentView()
}
