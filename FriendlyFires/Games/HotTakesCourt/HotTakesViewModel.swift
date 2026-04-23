import Foundation
import Observation

@Observable
final class HotTakesViewModel: PacketHandler {
    let multipeerSession: MultipeerSession
    let players: [PlayerDTO]
    let localPlayerID: UUID
    let isHost: Bool

    var gameState: GamePhase = .submission
    var currentRound: TakesRound = TakesRound(takes: [])
    var submittedTakes: [UUID: Take] = [:]
    var playerVotes: [UUID: TakeVote] = [:]
    var results: [Take] = []
    var roundsCompleted: Int = 0
    let totalRounds: Int = 3

    enum GamePhase {
        case submission     // Players typing opinions
        case voting         // Players voting hot/cold
        case reveal         // Showing results + who said what
        case nextRound      // Between rounds
        case gameOver       // Game finished
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
    }

    // MARK: - Host Actions

    func startGame() {
        guard isHost else { return }
        advanceRound()
    }

    func advanceRound() {
        guard isHost else { return }

        if roundsCompleted > 0 && !submittedTakes.isEmpty {
            // Tally votes and reveal
            var roundResults = currentRound
            for (_, vote) in playerVotes {
                roundResults.addVote(vote)
            }
            results = roundResults.sortedResults
            gameState = .reveal

            // After delay, proceed
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
                self?.proceedToNextRound()
            }
            return
        }

        if roundsCompleted >= totalRounds {
            gameState = .gameOver
            broadcastGameEnd()
            return
        }

        // Start new round
        submittedTakes.removeAll()
        playerVotes.removeAll()
        currentRound = TakesRound(takes: [])
        gameState = .submission
        roundsCompleted += 1
        broadcastSubmissionPhase()
    }

    private func proceedToNextRound() {
        gameState = .nextRound
        advanceRound()
    }

    private func broadcastSubmissionPhase() {
        let packet = GamePacket(
            type: .roundStarted,
            sender: localPlayerID,
            senderName: "Host",
            payload: "submission_phase"
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

    // MARK: - Guest Actions

    func submitTake(_ text: String) {
        let take = Take(playerID: localPlayerID, playerName: "", text: text)

        let payload = SubmitTakePayload(
            playerID: localPlayerID,
            playerName: "",
            text: text
        )

        let packet = GamePacket(
            type: .submitAction,
            sender: localPlayerID,
            senderName: "",
            payload: payload
        )
        multipeerSession.send(packet)
    }

    func submitVote(_ takeID: UUID, isHot: Bool) {
        let voteType: TakeVote.VoteType = isHot ? .hot : .cold
        let vote = TakeVote(voterID: localPlayerID, takeID: takeID, vote: voteType)

        let payload = SubmitVotePayload(
            voterID: localPlayerID,
            takeID: takeID,
            vote: voteType
        )

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
            gameState = .submission
            submittedTakes.removeAll()
            playerVotes.removeAll()

        case .submitAction:
            if let payload: SubmitTakePayload = packet.decodePayload(SubmitTakePayload.self) {
                let take = Take(
                    playerID: payload.playerID,
                    playerName: packet.senderName,
                    text: payload.text
                )
                submittedTakes[payload.playerID] = take

                if isHost {
                    // Host broadcasts takes when all submitted
                    if submittedTakes.count == players.count {
                        broadcastTakesForVoting()
                    }
                }
            }

        case .submitVote:
            if let payload: SubmitVotePayload = packet.decodePayload(SubmitVotePayload.self) {
                let vote = TakeVote(
                    voterID: payload.voterID,
                    takeID: payload.takeID,
                    vote: payload.vote
                )
                playerVotes[payload.voterID] = vote

                if isHost && playerVotes.count == (players.count - 1) {
                    // All votes in, reveal results
                    advanceRound()
                }
            }

        case .revealResults:
            if let payload: RevealTakesPayload = packet.decodePayload(RevealTakesPayload.self) {
                results = payload.results
                gameState = .reveal
            }

        case .gameEnded:
            gameState = .gameOver

        default:
            break
        }
    }

    private func broadcastTakesForVoting() {
        let takes = Array(submittedTakes.values).shuffled()
        currentRound = TakesRound(takes: takes)
        gameState = .voting

        let payload = BroadcastTakesPayload(takes: takes)
        let packet = GamePacket(
            type: .stateUpdate,
            sender: localPlayerID,
            senderName: "Host",
            payload: payload
        )
        multipeerSession.send(packet)
    }
}
