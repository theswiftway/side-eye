import Foundation
import Observation

@Observable
final class MoralPriceTagViewModel: PacketHandler {
    let multipeerSession: MultipeerSession
    let players: [PlayerDTO]
    let localPlayerID: UUID
    let isHost: Bool

    var gameState: GamePhase = .dilemma
    var currentDilemma: Dilemma?
    var dilemmas: [Dilemma] = defaultDilemmas.shuffled().prefix(5).map { $0 }
    var currentRoundIndex: Int = 0
    var playerCommits: [UUID: PlayerCommit] = [:]
    var scores: [UUID: SelloutScore] = [:]
    let totalRounds: Int = 5

    enum GamePhase {
        case dilemma       // Host choosing dilemma
        case commit        // Players deciding yes/no
        case reveal        // Showing all commits
        case nextRound
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

        // Initialize scores
        for player in players {
            scores[player.id] = SelloutScore(playerID: player.id, playerName: player.displayName)
        }
    }

    func startGame() {
        guard isHost else { return }
        advanceRound()
    }

    func advanceRound() {
        guard isHost else { return }

        if currentRoundIndex > 0 && !playerCommits.isEmpty {
            // Reveal previous round
            if let dilemma = currentDilemma {
                broadcastReveal(dilemma)
                gameState = .reveal

                // Record scores
                for commit in playerCommits.values {
                    scores[commit.playerID]?.recordCommit(wouldDo: commit.wouldDo, amount: dilemma.amount)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                    self?.proceedToNextRound()
                }
            }
            return
        }

        if currentRoundIndex >= totalRounds {
            gameState = .gameOver
            broadcastGameEnd()
            return
        }

        if currentRoundIndex < dilemmas.count {
            currentDilemma = dilemmas[currentRoundIndex]
            playerCommits.removeAll()
            gameState = .commit
            broadcastDilemma()
        }

        currentRoundIndex += 1
    }

    private func proceedToNextRound() {
        gameState = .nextRound
        advanceRound()
    }

    private func broadcastDilemma() {
        guard let dilemma = currentDilemma else { return }
        let payload = BroadcastDilemmaPayload(dilemma: dilemma, roundNumber: currentRoundIndex)
        let packet = GamePacket(
            type: .roundStarted,
            sender: localPlayerID,
            senderName: "Host",
            payload: payload
        )
        multipeerSession.send(packet)
    }

    private func broadcastReveal(_ dilemma: Dilemma) {
        let payload = RevealCommitsPayload(dilemma: dilemma, commits: Array(playerCommits.values))
        let packet = GamePacket(
            type: .revealResults,
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

    func submitCommit(wouldDo: Bool, justification: String) {
        guard let dilemma = currentDilemma else { return }
        let commit = PlayerCommit(
            playerID: localPlayerID,
            playerName: "",
            dilemmaID: dilemma.id,
            wouldDo: wouldDo,
            justification: justification
        )

        let payload = SubmitCommitPayload(
            playerID: localPlayerID,
            playerName: "",
            dilemmaID: dilemma.id,
            wouldDo: wouldDo,
            justification: justification
        )

        let packet = GamePacket(
            type: .submitAction,
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
            if let payload: BroadcastDilemmaPayload = packet.decodePayload(BroadcastDilemmaPayload.self) {
                currentDilemma = payload.dilemma
                gameState = .commit
            }

        case .submitAction:
            if let payload: SubmitCommitPayload = packet.decodePayload(SubmitCommitPayload.self) {
                let commit = PlayerCommit(
                    playerID: payload.playerID,
                    playerName: packet.senderName,
                    dilemmaID: payload.dilemmaID,
                    wouldDo: payload.wouldDo,
                    justification: payload.justification
                )
                playerCommits[payload.playerID] = commit

                if isHost && playerCommits.count == players.count {
                    advanceRound()
                }
            }

        case .revealResults:
            if let payload: RevealCommitsPayload = packet.decodePayload(RevealCommitsPayload.self) {
                playerCommits = Dictionary(uniqueKeysWithValues: payload.commits.map { ($0.playerID, $0) })
                gameState = .reveal
            }

        case .gameEnded:
            gameState = .gameOver

        default:
            break
        }
    }
}
