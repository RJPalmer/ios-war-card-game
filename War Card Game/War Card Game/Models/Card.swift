struct Card: Comparable, Hashable {
    let suit: Suit
    let rank: Rank

    /// Explicit battle value for War (Ace high).
    /// Since Rank.rawValue already defines Ace = 14, we can safely use it directly.
    var warValue: Int {
        rank.rawValue
    }

    /// Texture name used to load the correct card image from a sprite sheet or atlas.
    /// Example: "AH" (Ace of Hearts), "10S" (Ten of Spades)
    var textureName: String {
        "\(rank.shortCode)\(suit.shortCode)"
    }

    /// Human-readable card description useful for debugging or UI labels.
    /// Example: "Ace of Spades"
    var displayName: String {
        "\(rank.displayName) of \(suit.displayName)"
    }

    /// Comparable conformance.
    /// Card comparison in War is based on the computed `warValue`.
    static func < (lhs: Card, rhs: Card) -> Bool {
        lhs.warValue < rhs.warValue
    }
}
