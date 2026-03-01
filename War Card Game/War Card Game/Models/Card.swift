struct Card: Comparable, Hashable {
    let suit: Suit
    let rank: Rank

    /// Explicit battle value for War (Ace high)
    var warValue: Int {
        switch rank {
        case .ace:
            return 14
        default:
            return rank.rawValue + 1
        }
    }

    // Comparable conformance — War compares using explicit warValue
    static func < (lhs: Card, rhs: Card) -> Bool {
        lhs.warValue < rhs.warValue
    }
}
