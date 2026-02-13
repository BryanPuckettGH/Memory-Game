//
//  CardView.swift
//  MemoryGame
//

import SwiftUI

// Card data model
struct Card: Equatable {
    let id: Int
    let content: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    var isMismatched: Bool = false
}

struct CardView: View {

    let card: Card
    var isShaking: Bool = false
    var onTapped: (() -> Void)?

    private var borderColor: Color {
        if card.isMatched { return .green }
        if card.isMismatched { return .red }
        return .blue
    }

    var body: some View {
        ZStack {
            if card.isFaceUp || card.isMatched {
                // Face-up card (or matched, stays visible during fade)
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 3)
                    Text(card.content)
                        .font(.system(size: 40))
                        .offset(x: isShaking ? -6 : 0)
                        .animation(
                            isShaking
                                ? .easeInOut(duration: 0.08).repeatCount(10, autoreverses: true)
                                : .default,
                            value: isShaking
                        )
                }
            } else {
                // Face-down card: show the blue back
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.gradient)
            }
        }
        .frame(height: 90)
        .opacity(card.isMatched ? 0 : 1)
        .animation(.easeOut(duration: 0.35), value: card.isMatched)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
        .onTapGesture {
            onTapped?()
        }
    }
}

#Preview {
    HStack {
        CardView(card: Card(id: 0, content: "🐶"))
        CardView(card: Card(id: 1, content: "🐶", isFaceUp: true))
        CardView(card: Card(id: 2, content: "🐶", isFaceUp: true, isMatched: true))
        CardView(card: Card(id: 3, content: "🐶", isFaceUp: true, isMismatched: true))
    }
    .padding()
}
