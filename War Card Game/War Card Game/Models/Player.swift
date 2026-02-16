//
//  Player.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/10/26.
//

import Foundation

<<<<<<< Updated upstream
struct Player {
=======
struct Deque<Element> {
    private var storage: [Element] = []
    private var head: Int = 0
    
    var count: Int {
        storage.count - head
    }
    
    var isEmpty: Bool {
        count == 0
    }
    
    mutating func enqueue(_ element: Element) {
        storage.append(element)
    }
    
    mutating func enqueue(contentsOf elements: [Element]) {
        storage.append(contentsOf: elements)
    }
    
    mutating func dequeue() -> Element? {
        guard head < storage.count else { return nil }
        let element = storage[head]
        head += 1
        
        // Periodically trim storage to prevent memory growth
        if head > 50 {
            storage.removeFirst(head)
            head = 0
        }
        
        return element
    }
    
    mutating func removeAll() {
        storage.removeAll()
        head = 0
    }
}

class Player {
>>>>>>> Stashed changes
    
    private(set) var name: String
    private var deck: Deque<Card>
    
    init(name: String = "", cards: [Card] = []) {
        self.name = name
        var deque = Deque<Card>()
        deque.enqueue(contentsOf: cards)
        self.deck = deque
    }
    
    // MARK: - Public API
    
    var cardCount: Int {
        deck.count
    }
    
    var isEmpty: Bool {
        deck.isEmpty
    }
    
<<<<<<< Updated upstream
    mutating func drawCard() -> Card? {
        deck.dequeue()
    }
    
    mutating func receiveCard(_ newCard: Card) {
        deck.enqueue(newCard)
    }
    mutating func receiveCards(_ newCards: [Card]) {
        cards.append(contentsOf: newCards)
=======
    func drawCard() -> Card? {
        deck.dequeue()
    }
    
    func receiveCard(_ newCard: Card) {
        deck.enqueue(newCard)
    }
    func receiveCards(_ newCards: [Card]) {
        deck.enqueue(contentsOf: newCards)
    }
    func setCards(_ newCards: [Card]) {
        var deque = Deque<Card>()
        deque.enqueue(contentsOf: newCards)
        self.deck = deque
>>>>>>> Stashed changes
    }
}
