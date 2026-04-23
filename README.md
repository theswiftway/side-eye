# 🔥 FriendlyFires — iOS Multiplayer Party Game App

**Status**: Phase 1-3a Complete ✅ | Build Verified ✅ | Ready for Phase 3b+

A sophisticated iOS party game app for 1–10 players playing offline via MultipeerConnectivity. 5 edgy, mature-themed games with MVVM architecture, type-safe networking, and SpriteKit animations.

---

## 📊 Project Status

| Phase | Status | Files | Description |
|-------|--------|-------|-------------|
| **Phase 1** | ✅ Complete | 11 | Core networking (MultipeerSession), models, lobby |
| **Phase 2** | ✅ Complete | 7 | Reusable UI components, game shell |
| **Phase 3a** | ✅ Complete | 4 | The Rankings game (full implementation) |
| **Phase 3b** | ⏳ Ready | — | Hot Takes Court, Moral Price Tag, Red Flags, Island Exile |
| **Phase 4** | 📋 Planned | — | Polish, assets, onboarding |

---

## 🎮 5 Games

1. **The Rankings** ✅ — Anonymous heat-map polls ("Who'd survive the apocalypse?")
2. **Hot Takes Court** — Spicy opinion submission + voting + reveal
3. **Moral Price Tag** — Escalating moral dilemmas with dollar amounts
4. **Island Exile** — Survivor-style social deduction with secret roles
5. **Red Flags** — Dating show parody with green/red flag cards

---

## 🏗️ Architecture

**Pattern**: MVVM + SwiftUI + SpriteKit
- **ViewModel** (`@Observable`): Game logic, packet handling, state sync
- **View**: Pure SwiftUI, binds to ViewModel
- **Scene**: SpriteKit for reveal animations (optional per game)

**Networking**: MultipeerConnectivity (WiFi + Bluetooth automatic failover)
- Host = advertiser; Guests = browsers
- Type-safe `GamePacket` protocol (Codable)
- PacketRouter distributes messages to game ViewModels

**State**: Host-authoritative
- Host owns game logic, broadcasts state
- Guests submit actions, receive broadcasts
- Atomic synchronization via packets

---

## 📁 Directory Structure

```
FriendlyFires/
├── project.yml                # XcodeGen configuration
├── nool.toml                  # Semantic VC config
├── Info.plist                 # App metadata
├── PROGRESS.md                # Build checklist
├── NOOL_WORKFLOW.md           # Semantic VC guide
│
├── App/
│   ├── FriendlyFiresApp.swift      # @main, SwiftData
│   └── RootView.swift              # Launch screen
│
├── Core/
│   ├── Network/
│   │   ├── MultipeerSession.swift  # MCSession wrapper (@Observable)
│   │   ├── GamePacket.swift        # Protocol + payloads
│   │   └── PacketRouter.swift      # Message dispatch
│   └── Models/
│       ├── Player.swift
│       ├── GameSession.swift
│       └── GameType.swift           # 5 games enum
│
├── Lobby/
│   ├── LobbyViewModel.swift
│   └── LobbyView.swift
│
├── GameSelection/
│   ├── GameSelectionViewModel.swift
│   └── GameSelectionView.swift
│
├── Games/
│   └── Rankings/                    # ✅ Complete
│       ├── RankingsModels.swift
│       ├── RankingsViewModel.swift
│       ├── RankingsView.swift
│       └── RankingsScene.swift      # SpriteKit heat-map
│   ├── HotTakesCourt/               # 📋 Ready
│   ├── MoralPriceTag/
│   ├── IslandExile/
│   └── RedFlags/
│
├── UI/
│   ├── Components/
│   │   ├── PlayerChip.swift
│   │   ├── VoteBar.swift
│   │   └── TimerRing.swift
│   └── Theme/
│       ├── AppTheme.swift           # Design tokens
│       └── Animations.swift
│
├── Tests/
│   └── FriendlyFiresTests.swift     # Placeholder
│
└── Resources/
    └── [JSON banks for questions, dilemmas, cards]
```

---

## 🛠️ Setup & Build

### Prerequisites
- Xcode 15+
- Swift 5.9+
- XcodeGen (`brew install xcodegen`)

### Generate Xcode Project
```bash
cd FriendlyFires
xcodegen generate
```

### Build
```bash
xcodebuild build \
  -project FriendlyFires.xcodeproj \
  -scheme FriendlyFires \
  -destination "generic/platform=iOS"
```

### Run Tests
```bash
# Create a test scheme, then:
xcodebuild test \
  -project FriendlyFires.xcodeproj \
  -scheme FriendlyFires \
  -destination "platform=iOS Simulator,name=iPhone 15"
```

---

## 🔐 Semantic Version Control (Nool)

All work tracked via **nool** — semantic mutations with intent, causal history, and blast-radius checks.

```bash
# View repository status
nool status

# See all Knots (changes)
nool log
nool dag

# Search by intent
nool search "networking"

# Check impact before committing
nool query blast-radius <knot_id>

# Solidify (sign and finalize)
nool solidify --full --sync

# Web console
nool console  # http://127.0.0.1:4001
```

See [NOOL_WORKFLOW.md](NOOL_WORKFLOW.md) for full guide.

---

## 🎯 Architecture Highlights

### PacketHandler Protocol
Every game ViewModel implements `PacketHandler`, enabling the router to dispatch packets by type:
```swift
protocol PacketHandler {
    func processPacket(_ packet: GamePacket)
}
```

### Type-Safe Networking
Payloads are Codable structs, decoded on-demand:
```swift
let payload: SubmitRankingPayload = packet.decodePayload(SubmitRankingPayload.self)
```

### Reusable Components
PlayerChip, VoteBar, TimerRing are pure SwiftUI, composable:
```swift
PlayerChip(player: player, isSelected: false, isHost: true)
```

### Design System
Unified colors, typography, spacing via `AppTheme`:
```swift
Text("Title").font(AppTheme.titleFont).foregroundColor(AppTheme.primary)
```

---

## 📈 Build Verification

**Latest Build**: ✅ Succeeded  
**Swift Compilation**: ✅ No errors  
**Xcode Project**: ✅ Generated via XcodeGen  

```
** BUILD SUCCEEDED ** [0.619 sec]
```

---

## 🚀 Next Steps

1. **Complete Phase 3b** (4 remaining games):
   ```bash
   nool propose --intent "Hot Takes Court implementation" \
     --path FriendlyFires/Games/HotTakesCourt/ \
     --thread "Phase 3b: Hot Takes & Moral Price Tag" \
     --full --solidify
   ```

2. **Run integration tests** (host + 2 guests on simulators)

3. **Polish & assets** (Unsplash royalty-free backgrounds, SF Symbols)

4. **Release** with `nool release v1.0.0`

---

## 📝 License

Internal project — FriendlyFires, 2026.

---

## 🙋 Questions?

- **Networking**: See `Core/Network/MultipeerSession.swift`
- **Game flow**: See `Games/Rankings/RankingsViewModel.swift`
- **UI patterns**: See `UI/Components/` and `UI/Theme/AppTheme.swift`
- **Nool workflow**: See `NOOL_WORKFLOW.md`
