# Nool Workflow for FriendlyFires

## Initialize (Done ✅)

```bash
nool init
# Creates semantic-agentic version control
# Initializes .nool/git_mirror/ and Bifrost bridge
```

## Create Intent Threads (Done ✅)

```bash
# Phase 1: Core Infrastructure
nool thread create --name "Phase 1: Core Infrastructure" \
  --desc "MultipeerSession + Lobby + Models + Networking Layer"

# Phase 2: Game Shell
nool thread create --name "Phase 2: Game Shell & UI Components" \
  --desc "Reusable components: PlayerChip, VoteBar, TimerRing, GameSelection"

# Phase 3a: The Rankings Game  
nool thread create --name "Phase 3a: The Rankings Game" \
  --desc "First complete game: Models, ViewModel, View, SpriteKit scene"
```

## Propose Changes (Blueprint)

```bash
# Phase 1 - Networking + Models
nool propose --intent "Core networking: MultipeerSession + GamePacket" \
  --path "FriendlyFires/Core/Network/" \
  --thread "Phase 1: Core Infrastructure" \
  --full --solidify

# Phase 1 - Lobby UI
nool propose --intent "Lobby + GameSession models" \
  --path "FriendlyFires/Lobby/ FriendlyFires/Core/Models/" \
  --thread "Phase 1: Core Infrastructure" \
  --full --solidify

# Phase 2 - UI Components  
nool propose --intent "Reusable UI: PlayerChip, VoteBar, TimerRing, Animations" \
  --path "FriendlyFires/UI/" \
  --thread "Phase 2: Game Shell & UI Components" \
  --full --solidify

# Phase 3a - The Rankings Game
nool propose --intent "Rankings game implementation: Models, ViewModel, View, Scene" \
  --path "FriendlyFires/Games/Rankings/" \
  --thread "Phase 3a: The Rankings Game" \
  --full --solidify
```

## Solidify (Make Permanent)

```bash
# Solidify pending proposals
nool solidify --full

# Solidify + sync to Bifrost mirror
nool solidify --full --sync

# View the Knot DAG
nool log
nool dag
```

## Check Blast Radius (Before Solidify)

```bash
# Analyze impact of changes before finalizing
nool query blast-radius <knot_id1> <knot_id2>

# Example: Before changing GamePacket structure
nool propose --intent "Add compression to GamePacket"
nool query blast-radius HEAD~1  # check impact on all consumers
```

## Learn & Document

```bash
# Record insights after bug fixes or discoveries
nool learn --about "FriendlyFires/Core/Network/MultipeerSession.swift" \
  --kind "root_cause" \
  --content "MCSession peer disconnect must call session.disconnect() before nil"

# Link to a specific knot
nool learn --about "FriendlyFires/Lobby/LobbyViewModel.swift" \
  --kind "dependency_insight" \
  --content "PacketHandler protocol enables packet routing to game VMs" \
  --knot <knot_id>

# Retrieve findings
nool findings FriendlyFires/Core/Network/
```

## Status & Inspection

```bash
# Repository status
nool status

# List all Knots with their intent
nool log

# Search by meaning
nool search "networking"

# Visualize DAG
nool dag

# Export changelog
nool changelog
nool changelog --since <HLC_timestamp>

# Causal chain: why does this Knot exist?
nool why <knot_id> --depth 5
```

## Release & Approval

```bash
# Create a formal release
nool release v1.0.0 --include "Phase 1: Core Infrastructure" \
  --include "Phase 2: Game Shell & UI Components" \
  --include "Phase 3a: The Rankings Game"

# Approve or reject a Knot
nool approve --id <knot_id> --comment "LGTM" --solidify
nool approve --id <knot_id> --reject --comment "Needs tests" --solidify

# Tag a milestone
nool tag v0.1.0-alpha --solidify
```

## Web Console

```bash
nool console
# Opens http://127.0.0.1:4001
# Tabs: DAG Explorer, Intent Feed, Task Board, Token Ledger, Debug Replay
```

## Sync & Collaboration

```bash
# Sync to Git remote via Bifrost Bridge
nool sync https://github.com/org/repo.git

# Import existing Git history
nool import-git main

# P2P encrypted sync (Signal Protocol)
nool sync signal://team-channel
```

## Token Ledger & Agent Economics

```bash
# Token usage by agent
nool token usage --agent <agent_id>

# Budget management
nool token budget-set --agent <agent_id> --limit 5000000 --period 100000
nool token budget-status

# Thread economics
nool thread-economics --thread "Phase 3: Games"
```

## Bug Tracking

```bash
# Report a bug
nool bug report --title "PacketRouter race condition" \
  --severity critical \
  --reproduction "1. Host rapid-fire votes 2. Guest submits simultaneously"

# Link bug to fix
nool bug link <bug_id> --fix <fix_knot_id> --solidify

# Binary search for regressions
nool bisect --good <knot_id> --bad HEAD --test "xcodebuild test"
```

## Task Management

```bash
# Create a task
nool task create --name "Add Hot Takes Court game" \
  --desc "Second game: opinion voting + reveal" \
  --priority 1 --solidify

# Pick a task (claim it)
nool task pick --id <task_id> --solidify

# Finish a task
nool task finish --id <task_id> --solidify

# View your tasks
nool task mine
```

## Project Health Check

```bash
# Release-readiness verification
nool doctor

# Strict mode (treat warnings as blockers)
nool doctor --strict

# Check filesystem hygiene only
nool doctor --fs-only

# JSON output for CI
nool doctor --json
```

---

## Current Project State

**Files Implemented**: 22 + project.yml + Info.plist + Tests/
**Build Status**: ✅ Successful (xcodebuild)
**Xcode Project**: ✅ Generated via XcodeGen

**Next Steps**:
1. For each new game (Hot Takes, Moral Price Tag, Red Flags, Island Exile):
   - Create Knot with `nool propose --full`
   - Check `blast-radius` for impacts
   - Solidify with `nool solidify --full`
   - Use `nool learn` to document architectural patterns

2. Before releases:
   - Run `nool doctor --strict`
   - Gather coverage with `nool changelog`
   - Tag with `nool tag vX.Y.Z`
