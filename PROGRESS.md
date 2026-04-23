# FriendlyFires Build Progress

## Phase 1 ✅ — Foundation & Networking
- [x] `App/FriendlyFiresApp.swift` — SwiftData + app entry
- [x] `App/RootView.swift` — Launch screen, host/guest selection
- [x] `UI/Theme/AppTheme.swift` — Design tokens, colors, typography
- [x] `Core/Models/Player.swift` — Player model + DTO
- [x] `Core/Models/GameType.swift` — 5 games enum
- [x] `Core/Models/GameSession.swift` — Session state
- [x] `Core/Network/GamePacket.swift` — Packet protocol
- [x] `Core/Network/MultipeerSession.swift` — MCSession wrapper
- [x] `Core/Network/PacketRouter.swift` — Packet routing
- [x] `Lobby/LobbyViewModel.swift` — Host/guest lobby logic
- [x] `Lobby/LobbyView.swift` — Waiting room + game selection UI

**Status**: Core infra complete. Host can advertise, guests can browse (in next phase).
**Blast radius**: None — new files only.

---

## Phase 2 ✅ — Game Shell & Shared Components
- [x] `GameSelection/GameSelectionViewModel.swift` — Post-join game pick logic
- [x] `GameSelection/GameSelectionView.swift` — Full-screen game grid
- [x] `UI/Components/PlayerChip.swift` — Avatar + name display
- [x] `UI/Components/VoteBar.swift` — Vote visualization
- [x] `UI/Components/TimerRing.swift` — Countdown timer with ring animation
- [x] `UI/Theme/Animations.swift` — Common animation utilities
- [ ] Template: `RoundView` & `RevealView` — Generic game screen shells

**Status**: UI components and game selection screen ready. No network changes.
**Blast radius**: None — UI-only, additive changes.

---

## Phase 3 — Games (1 at a time)
- [x] **The Rankings** ✅ — Simplest (poll mechanics)
  - [x] RankingsViewModel.swift
  - [x] RankingsView.swift
  - [x] RankingsScene.swift (heat-map animation)
  - [x] RankingsModels.swift
  
  Features: 5 questions shuffled, slider-based ranking UI, instant result display.
  Architecture proven - all other games follow this pattern.
  
- [ ] **Hot Takes Court** — Text + voting
- [ ] **Moral Price Tag** — Yes/no + reveal
- [ ] **Red Flags** — Card dealing + selection
- [ ] **Island Exile** — Most complex (roles + deduction)

---

## Phase 4 — Polish & Assets
- [ ] Royalty-free assets (Unsplash, SF Symbols)
- [ ] Sound effects (Freesound.org)
- [ ] Haptics
- [ ] Onboarding flow
- [ ] Edge case handling (peer disconnect, host drop)

---

## Nool Integration
Using semantic-agentic version control. Each major knot checked for **blast radius** before solidifying.
Key principle: Check what existing code depends on before changing shared types.

Last checked: Phase 1 — no dependencies yet.
