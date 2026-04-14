# 🧱 Space Bricks

> **Space Bricks** is a tribute to the classic **Arkanoid** — a fully playable brick-breaker built in **PowerBuilder 2025** with **two rendering engines**: a native DataWindow version and an HTML5 Canvas version running inside a WebBrowser control. A main menu lets you choose between them.

![PowerBuilder](https://img.shields.io/badge/PowerBuilder-2025%20(R25)-blue)
![License](https://img.shields.io/badge/license-MIT-green)

![Space Bricks in action](screenshoot.gif)

---

## ✨ Why?

After building a [Snake game](../Pb_Snake_Dw) entirely inside a DataWindow, I wanted to push PowerBuilder further with an Arkanoid/Breakout-style game that requires real physics: continuous ball movement, angle-based paddle rebounds, and per-pixel collision detection.

The result is two versions of the same game:

- **Native PB** — the game runs on a DataWindow with dynamically created rectangles and ovals, a `Timer` event, and `Modify()` for rendering. Everything is PowerBuilder, no external tech.
- **HTML5** — the same game reimplemented in plain JavaScript with Canvas 2D, running inside PB's `WebBrowser` control via `NavigateToString()`. Smooth 60 FPS pixel-perfect animation.

A launcher window (`w_main`) lets you pick which version to play.

## 🎮 How to play

| Key | Action |
|---|---|
| ⬅️ ➡️ | Move the paddle |
| `Space` | Launch ball / Pause / Resume |
| `Restart` button | New game |

- Break all **7 rows of colored bricks** (7 bricks per row = 49 total).
- The ball bounces off walls, bricks, and the paddle.
- Paddle angle matters: hit the edges for sharper angles, the center for straight bounces.
- You have **3 lives**. Miss the ball and lose one.

## 🧠 How it works

### Native PB version (`w_arcanoid`)

The DataWindow `dw_arcanoid` uses a **single row** with a **single detail band** of 1870 PBU height — the entire playfield in one band. The `cells` column is a `char(800)` string where each character encodes one grid cell (21 columns × 34 rows = 714 characters).

At startup, `wf_init_grid()` creates:
- **49 brick rectangles** at absolute positions, with visibility and color bound to DataWindow expressions reading from the `cells` string
- **1 paddle rectangle**, repositioned with `Modify("paddle.x = '…'")`
- **1 ball oval**, repositioned with `Modify("ball.x = '…' ball.y = '…'")`

The ball moves in PBU coordinates (not cell-by-cell), giving smoother animation. Collision detection uses AABB overlap with minimum-overlap bounce direction — the same algorithm as the HTML version.

### HTML version (`w_arcanoid_html`)

The function `wf_get_html()` returns the complete game as a single HTML string. The window loads it with `wb_1.NavigateToString(ls_html)`. The game uses:
- Plain JavaScript (no frameworks, no CDN)
- Canvas 2D for rendering at ~60 FPS with `requestAnimationFrame`
- Delta-time based movement for consistent speed
- The same AABB collision + min-overlap bounce algorithm

### Launcher (`w_main`)

A WebBrowser shows a welcome screen with two clickable cards. JavaScript calls `window.webBrowser.ue_nativo()` or `window.webBrowser.ue_html()` via PB's `RegisterEvent` mechanism. The user events open the chosen game window and close the launcher.

## 📁 Project layout

```
Pb_Arcanoid/
├── pb_arcanoid.pbl/
│   ├── pb_arcanoid.sra       ← application object, opens w_main
│   ├── w_main.srw            ← launcher: pick Native PB or HTML
│   ├── w_arcanoid.srw        ← native PB game (DataWindow + Timer)
│   ├── dw_arcanoid.srd       ← DataWindow definition (single band)
│   └── w_arcanoid_html.srw   ← HTML5 game (WebBrowser + Canvas)
├── pb_arcanoid.pbproj
├── Pb_Arcanoid.pbsln
├── LICENSE
└── README.md
```

## 🚀 Build & run

1. Open `Pb_Arcanoid.pbsln` in **PowerBuilder 2025 (release 25)**.
2. Build the solution.
3. Run — the launcher opens, pick your version.

No database connection, no external assets.

## 🔄 Native vs HTML comparison

| | Native PB | HTML5 |
|---|---|---|
| **Rendering** | DataWindow `Modify()` | Canvas 2D |
| **FPS** | ~25 (Timer 40ms) | ~60 (requestAnimationFrame) |
| **Ball movement** | PBU coordinates | Pixel coordinates + delta time |
| **Collision** | AABB + min-overlap | AABB + min-overlap |
| **Paddle control** | `keydown()` in Timer | `addEventListener` keydown/keyup |
| **Smoothness** | Good | Excellent |

## 🙏 Credits

The DataWindow rendering technique was inspired by the [Snake game](../Pb_Snake_Dw) in this same repository, which in turn drew from **René Ullrich**'s [*Three Simple Games*](https://community.appeon.com/codeexchange/powerbuilder/114-three-simple-games) on Appeon CodeExchange.

This project was developed by **Claude Code** following my ideas and direction.

## 📜 License

[MIT](LICENSE) © 2026 Ramón San Félix Ramón
