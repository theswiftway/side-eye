import Foundation
import Observation

@Observable
final class RankingsViewModel: PacketHandler {
    let multipeerSession: MultipeerSession
    let players: [PlayerDTO]
    let localPlayerID: UUID
    let isHost: Bool

    var currentQuestionIndex: Int = 0
    var questions: [RankingQuestion] = defaultRankingQuestions.shuffled().prefix(5).map { $0 }
    var currentQuestion: RankingQuestion? {
        currentQuestionIndex < questions.count ? questions[currentQuestionIndex] : nil
    }

    var currentBallots: [UUID: RankingBallot] = [:]
    var currentResults: QuestionResults?
    var gameState: GamePhase = .ranking
    var roundsCompleted: Int = 0

    enum GamePhase {
        case ranking      // Players submitting rankings
        case reveal       // Showing results
        case nextRound    // Between rounds
        case gameOver     // All rounds done
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
        advanceQuestion()
    }

    func advanceQuestion() {
        guard isHost else { return }

        if currentQuestionIndex > 0 {
            // Compute and broadcast results of previous question
            if !currentBallots.isEmpty,
               let question = questions[safe: currentQuestionIndex - 1] {
                let results = QuestionResults(
                    question: question,
                    ballots: Array(currentBallots.values)
                )
                broadcastResults(results)
                currentResults = results
                gameState = .reveal

                // Schedule next advance
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
                    self?.proceedToNextRound()
                }
                return
            }
        }

        // Move to next question
        if currentQuestionIndex >= questions.count {
            gameState = .gameOver
            broadcastGameEnd()
            return
        }

        currentBallots.removeAll()
        gameState = .ranking
        broadcastQuestionStart()
        currentQuestionIndex += 1
    }

    private func proceedToNextRound() {
        gameState = .nextRound
        roundsCompleted += 1
        advanceQuestion()
    }

    private func broadcastQuestionStart() {
        guard let question = currentQuestion else { return }
        let packet = GamePacket(
            type: .roundStarted,
            sender: localPlayerID,
            senderName: "Host",
            payload: question
        )
        multipeerSession.send(packet)
    }

    private func broadcastResults(_ results: QuestionResults) {
        let topThree = results.averageRanks
            .sorted { $0.value < $1.value }
            .prefix(3)
            .map { ($0.key, $0.value) }

        let payload = RevealResultsPayload(
            questionID: results.question.id,
            averageRanks: results.averageRanks,
            topThree: Array(topThree)
        )

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

    // MARK: - Guest Actions

    func submitRanking(_ rankings: [UUID: Int]) {
        guard let question = currentQuestion else { return }

        let ballot = RankingBallot(
            playerID: localPlayerID,
            playerName: "",
            questionID: question.id,
            rankings: rankings
        )

        let payload = SubmitRankingPayload(
            playerID: localPlayerID,
            playerName: "",
            questionID: question.id,
            rankings: rankings
        )

        let packet = GamePacket(
            type: .submitRanking,
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
            if let question: RankingQuestion = packet.decodePayload(RankingQuestion.self) {
                self.questions = [question]
                self.currentQuestionIndex = 0
                self.gameState = .ranking
                self.currentBallots.removeAll()
            }

        case .submitRanking:
            if let payload: SubmitRankingPayload = packet.decodePayload(SubmitRankingPayload.self) {
                let ballot = RankingBallot(
                    playerID: payload.playerID,
                    playerName: packet.senderName,
                    questionID: payload.questionID,
                    rankings: payload.rankings
                )
                currentBallots[payload.playerID] = ballot

                // Host auto-advances when all players submitted
                if isHost && currentBallots.count == players.count {
                    advanceQuestion()
                }
            }

        case .revealResults:
            if let payload: RevealResultsPayload = packet.decodePayload(RevealResultsPayload.self) {
                let results = QuestionResults(
                    question: RankingQuestion(text: "Results", category: ""),
                    ballots: Array(currentBallots.values)
                )
                currentResults = results
                gameState = .reveal
            }

        case .gameEnded:
            gameState = .gameOver

        default:
            break
        }
    }
}

// MARK: - Array Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
