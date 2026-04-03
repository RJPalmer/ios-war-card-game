# 🃏 War Card Game

A modern iOS implementation of the classic card game **War**, built using **Swift** and **SpriteKit**. This project focuses on clean architecture, smooth animations, and efficient sprite rendering.

---

## 📖 Overview

War is a simple card game where two players compete by drawing cards from their decks. The player with the higher card wins the round and collects both cards. In the event of a tie, a “war” is triggered, adding additional stakes to the round.

This app recreates the experience with:
- Animated card flips and transitions
- Sprite sheet–based card rendering
- Turn-based gameplay
- Clean separation of game logic and UI

---

## 🛠 Tech Stack

- **Language:** Swift  
- **Frameworks:** SpriteKit, UIKit  
- **Architecture:** MVVM (Model-View-ViewModel)  
- **Rendering:** Sprite sheet slicing via `CardTextureManager`

---

## 🚀 Installation & Setup

### Prerequisites
- macOS
- Xcode (latest stable version recommended)
- iOS Simulator or physical iOS device

---

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/war-card-game.git
   cd war-card-game
   ```

2. **Open the project**
   ```bash
   open "War Card Game.xcodeproj"
   ```

3. **Build and run**
   * Select a simulator (e.g., iPhone Pro Max)
   * Press ⌘ + R in Xcode

## 🎮 How to Play

### Basic Rules

  1. Tap Play Turn
  2. Both player and CPU draw a card
  3. The higher card wins the round
  4. Winner collects both cards
  5. If cards are equal:
     * A War is triggered
     * Additional cards are drawn to determine the winner

### Objective

Win all the cards in the deck or finish the game with more cards than your opponent.

### 🕹 Controls / UI
  * **Play Turn Button**
    * Advances the game by one round
    * Triggers card animations
  * **Restart Button**
    * Resets the game when it ends
    * Appears only after game over
  * **Game Screen**
    * Displays player and CPU cards
    * Shows animations for flips and transitions

## 🧱 Project Structure
```code
War Card Game/
├── GameScene.swift
├── GameViewModel.swift
├── GameEngine.swift
├── CardTextureManager.swift
├── Models/
│   ├── Card.swift
│   ├── Rank.swift
│   └── Suit.swift
```

## 🔑 Key Components

### GameScene
* Handles SpriteKit rendering and animations
* Manages UI elements (buttons, card nodes)
* Responds to user input

### GameViewModel
* Bridges UI and game logic
* Maintains observable state
* Updates UI based on engine output

### GameEngine
* Core game logic
* Determines round winners
* Handles “war” scenarios
* Tracks game progression and game-over state

### CardTextureManager
* Slices sprite sheet into individual card textures
* Uses caching for performance
* Ensures pixel-accurate rendering

## 🧪 Debug Features
* Card Debug Labels (DEBUG builds only)
* Displays rank and suit on cards
* Helps verify correct texture mapping
* Texture Debug Logging
* Logs rank, suit, and texture coordinates
* Useful for diagnosing sprite issues

## ⚠️ Known Issues
* Sprite sheet alignment may require per-suit adjustments
* Minor texture bleeding may occur depending on source image
* Assumes consistent padding in sprite sheet layout

## 🔮 Future Improvements
* 🔊 Sound effects (card flips, wins, war events)
* 🎨 UI polish and smoother animations
* 📊 Score tracking and statistics
* 👥 Multiplayer support
* ⚙️ Game settings (themes, animation speed)

⸻

## 📸 Screenshots

(Add screenshots here)

⸻

## 📌 Notes

This project emphasizes:
* Clean MVVM architecture
* Separation of concerns
* Efficient SpriteKit rendering
* Debuggable and maintainable code

⸻

📄 License

This project is open source and available under the MIT License.
