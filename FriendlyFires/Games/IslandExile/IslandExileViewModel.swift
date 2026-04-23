import Foundation
import Observation
import MultipeerConnectivity

@Observable
final class IslandExileViewModel: PacketHandler {
    // Note: MultipeerSession, GamePacket, PlayerDTO imported via target membership
    let multipeerSession: MultipeerSession
    let players: [PlayerDTO]
    let localPlayerID: UUID
    let isHost: Bool

    var gameState: GamePhase = .roleReveal
    var playerRoles: [UUID: Role] = [:]
    var remainingPlayers: [UUID] = []
    var challenges: [IslandChallenge] = defaultIslandChallenges.shuffled()
    var currentChallengeIndex: Int = 0
    var exileVotes: [UUID: ExileVote] = [:]
    var lastExiledPlayer: (id: UUID, name: String, role: Role)?

    enum GamePhase {
        case roleReveal       // Secret roles shown
        case challenge        // Host reads challenge
        case discussion       // Players discuss
        case voting           // Players vote to exile
        case reveal           // Who was exiled + role
        case gameOver
    }

    init(
        multipeerSession: MultipeerSession,
        players: [PlayerDTO],
        localPlayerID: UUID,
        isHost: Bool
    ) {
        self.multipeerSession = multipeerSession
        self.players = players
        self.localPlayerID = localPlayerID
        self.isHost = isHost
        self.remainingPlayers = players.map { $0.id }
    }

    func startGame() {
        guard isHost else { return }
        assignRoles()
    }

    private func assignRoles() {
        // Assign roles: Schemers (half), Loyalists (quarter), Wildcard, Survivalist
        var roles: [Role] = []
        let schemeCount = max(1, players.count / 2)
        let loyalCount = max(1, players.count / 4)

        roles.append(contentsOf: Array(repeating: .schemer, count: schemeCount))
        roles.append(contentsOf: Array(repeating: .loyalist, count: loyalCount))
        if players.count > schemeCount + loyalCount {
            roles.append(.wildcard)
        }
        while roles.count < players.count {
            roles.append(.survivalist)
        }

        roles.shuffle()

        for (index, player) in players.enumerated() {
            playerRoles[player.id] = roles[index % roles.count]

            // Send role to player
            let payload = AssignRolePayload(playerID: player.id, role: playerRoles[player.id]!)
            let packet = GamePacket(
                type: .roundStarted,
                sender: localPlayerID,
                senderName: "Host",
                payload: payload
            )
            multipeerSession.sendToPeer(packet, peerID: MCPeerID(displayName: player.displayName))
        }

        gameState = .roleReveal
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.advanceRound()
        }
    }

    func advanceRound() {
        guard isHost else { return }

        if !exileVotes.isEmpty && remainingPlayers.count > 3 {
            // Count votes and exile
            let voteCount = Dictionary(grouping: Array(exileVotes.values), by: { $0.targetID })
            if let exiledID = voteCount.max(by: { $0.value.count < $1.value.count })?.key {
                exilePlayer(exiledID)
            }
            return
        }

        if remainingPlayers.count <= 3 {
            gameState = .gameOver
            broadcastGameEnd()
            return
        }

        if currentChallengeIndex < challenges.count {
            let challenge = challenges[currentChallengeIndex]
            gameState = .challenge
            broadcastChallenge(challenge)
            currentChallengeIndex += 1
        }
    }

    private func exilePlayer(_ playerID: UUID) {
        let role = playerRoles[playerID] ?? .survivalist
        remainingPlayers.removeAll { $0 == playerID }
        gameState = .reveal

        let payload = RevealExilePayload(
            exiledPlayerID: playerID,
            exiledPlayerName: "",
            exiledPlayerRole: role,
            voteCount: exileVotes.count
        )
        let packet = GamePacket(
            type: .revealResults,
            sender: localPlayerID,
            senderName: "Host",
            payload: payload
        )
        multipeerSession.send(packet)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.advanceRound()
        }
    }

    private func broadcastChallenge(_ challenge: IslandChallenge) {
        let payload = BroadcastExilePayload(
            challengeID: challenge.id,
            challengeText: challenge.text,
            remainingPlayers: remainingPlayers.count
        )
        let packet = GamePacket(
            type: .roundStarted,
            sender: localPlayerID,
            senderName: "Host",
            payload: payload
        )
        multipeerSession.send(packet)
    }

    private func broadcastGameEnd() {
        let packet = GamePacket(
            type: .gameEnded,
            sender: localPlayerID,
            senderName: "Host"
        )
        multipeerSession.send(packet)
    }

    func submitExileVote(_ targetID: UUID, reason: String) {
        let vote = ExileVote(voterID: localPlayerID, targetID: targetID, reason: reason)
        let payload = SubmitExileVotePayload(voterID: localPlayerID, targetID: targetID, reason: reason)
        let packet = GamePacket(
            type: .submitVote,
            sender: localPlayerID,
            senderName: "",
            payload: payload
        )
        multipeerSession.send(packet)
    }

    // MARK: - PacketHandler

    func processPacket(_ packet: GamePacket) {
        switch packet.type {
        case .roundStarted:
            if let payload: AssignRolePayload = packet.decodePayload(AssignRolePayload.self) {
                playerRoles[payload.playerID] = payload.role
                gameState = .roleReveal
            }

        case .submitVote:
            if let payload: SubmitExileVotePayload = packet.decodePayload(SubmitExileVotePayload.self) {
                let vote = ExileVote(voterID: payload.voterID, targetID: payload.targetID, reason: payload.reason)
                exileVotes[payload.voterID] = vote

                if isHost && exileVotes.count == remainingPlayers.count {
                    advanceRound()
                }
            }

        case .revealResults:
            if let payload: RevealExilePayload = packet.decodePayload(RevealExilePayload.self) {
                lastExiledPlayer = (payload.exiledPlayerID, payload.exiledPlayerName, payload.exiledPlayerRole)
                gameState = .reveal
            }

        case .gameEnded:
            gameState = .gameOver

        default:
            break
        }
    }
}

// Helper for MultiPeerSession sendToPeer
import MultipeerConnectivity
