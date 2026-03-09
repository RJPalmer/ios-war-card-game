enum Rank: Int, CaseIterable, Comparable {
    case two = 2
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case jack
    case queen
    case king
    case ace = 14   // Ace high for War comparisons

    /// Comparable conformance (used when comparing cards during a turn)
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Short code used for sprite / texture names (e.g., "AH", "10S")
    var shortCode: String {
        switch self {
        case .ace: return "A"
        case .king: return "K"
        case .queen: return "Q"
        case .jack: return "J"
        case .ten: return "10"
        case .nine: return "9"
        case .eight: return "8"
        case .seven: return "7"
        case .six: return "6"
        case .five: return "5"
        case .four: return "4"
        case .three: return "3"
        case .two: return "2"
        }
    }

    /// Human‑readable display name for UI
    var displayName: String {
        switch self {
        case .ace: return "Ace"
        case .king: return "King"
        case .queen: return "Queen"
        case .jack: return "Jack"
        case .ten: return "10"
        case .nine: return "9"
        case .eight: return "8"
        case .seven: return "7"
        case .six: return "6"
        case .five: return "5"
        case .four: return "4"
        case .three: return "3"
        case .two: return "2"
        }
    }
}
