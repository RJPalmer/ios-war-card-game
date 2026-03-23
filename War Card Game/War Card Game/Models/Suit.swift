//
//  Suit.swift
//  War Card Game
//

import Foundation

/// Represents the four suits in a standard 52-card deck.
enum Suit: String, CaseIterable, Codable {
    case hearts
    case diamonds
    case clubs
    case spades
    
    /// Unicode symbol used for display.
    var symbol: String {
        switch self {
        case .hearts: return "♥"
        case .diamonds: return "♦"
        case .clubs: return "♣"
        case .spades: return "♠"
        }
    }
    
    /// Short code often used for filenames or sprite atlas keys.
    /// Example: "AH" for Ace of Hearts.
    var shortCode: String {
        switch self {
        case .hearts: return "H"
        case .diamonds: return "D"
        case .clubs: return "C"
        case .spades: return "S"
        }
    }
    
    /// Human-readable name.
    var displayName: String {
        rawValue.capitalized
    }
    
    /// Indicates whether the suit is red or black.
    var isRed: Bool {
        switch self {
        case .hearts, .diamonds:
            return true
        case .clubs, .spades:
            return false
        }
    }
}
