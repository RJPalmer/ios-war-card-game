//
//  Card.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/10/26.
//

import Foundation

struct Card: Comparable {
    let suit: Suit
    let rank: Rank

    // Comparable conformance — War only cares about rank
    static func < (lhs: Card, rhs: Card) -> Bool {
        lhs.rank < rhs.rank
    }
}
