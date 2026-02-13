<div align="center">

# Project 4 - *Memory Game*

**Bryan Puckett** | COP4655 - Mobile Application Development | FIU Spring 2026

</div>

---

**Memory Game** is a SwiftUI card-matching game where players flip cards to find matching pairs. Choose from four unique game modes, each with its own personality and rules, and race against the clock or play at your own pace.

| | |
|---|---|
| **Time Spent** | 5 hours |
| **Platform** | iOS (SwiftUI) |

---

## Demo

<div align="center">

![Memory Game Demo](Demo%20gif.gif)

</div>

---

## Required Features

- [x] App loads to display a grid of cards initially placed face-down
- [x] Users can tap cards to toggle their display between the back and the face
- [x] Tapping a second card that is not identical flips both back down
- [x] When two matching cards are found, they both disappear from view
- [x] User can reset the game and start a new game via a button

## Stretch Features

- [x] User can select number of pairs to play with (2, 4, 6, 8, 10, or 12 pairs)
- [x] App allows for user to scroll to see pairs out of view
- [x] UI polish with colored buttons, gradient card backs, and capsule-shaped buttons
- [x] 4 unique game modes, each with its own personality-driven prompt sheet:
  - **Free Play** - relaxed, no timer pressure, stopwatch tracks your time
  - **Challenge** - countdown timer, race against the clock
  - **Impossible** - on any mismatch, all unmatched cards shuffle positions
  - **Genie** - on any mismatch, all matched pairs reset and the entire board reshuffles (optional timer or unlimited play)
- [x] Custom wheel-based timer picker so users can set any time they want (minutes and seconds)
- [x] Win screen with mode-specific congratulations message and time stats
- [x] Lose screen when time runs out with card flip reveal, shaking emojis, and mode-specific taunt
- [x] Setup screen to choose game mode and card pairs before starting
- [x] Cards flash green on match and red on mismatch for instant visual feedback

---

## Notes

- Built entirely with SwiftUI using @State for all game logic
- Each game mode has a unique prompt sheet with its own personality and tone
- Impossible and Genie modes add creative twists to the classic memory game formula

---

## License

    Copyright 2026 Bryan Puckett

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
