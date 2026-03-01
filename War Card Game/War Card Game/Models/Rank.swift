//
//  Rank.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/10/26.
//

import Foundation

enum Rank: Int, CaseIterable, Comparable {
    case ace = 0
    case two
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
   

    // Comparable conformance (important for War comparisons)
    static func < (lhs: Rank, rhs: Rank) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
