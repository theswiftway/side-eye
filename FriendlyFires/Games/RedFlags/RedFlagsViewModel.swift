import Foundation
import Observation
import MultipeerConnectivity

@Observable
final class RedFlagsViewModel: PacketHandler {
    // Note: MultipeerSession, GamePacket, PlayerDTO imported via target membership
    let multipeerSession: MultipeerSession
    let players: [PlayerDTO]
    let localPlayerID: UUID
    let isHost: Bool

    var gameState: GamePhase = .pitching
    var pitches: [DatePitch] = []
    var currentBachelorIndex: Int = 0
    var playerCards: [UUID: (green: [FlagCard], red: FlagCard)] = [:]
    var chosenPitch: DatePitch?
    var roundsCompleted: Int = 0

    enum GamePhase {
        case pitching      // Players building pitches
        case reveal        // Showing all pitches
        case choosing      // Bachelor choosing
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
    }

    func startGame() {
        guard isHost else { return }
        dealCards()
    }

    private func dealCards() {
        // Deal 2 green + 1 red to each player
        let allGreen = defaultGreenFlags.shuffled()
        let allRed = defaultRedFlags.shuffled()

        for (index, player) in players.enumerated() {
            let greens = Array(allGreen.prefix(2 + index % 2))
            let red = allRed[index % allRed.count]
            playerCards[player.id] = (greens, red)
        }

        advanceRound()
    }

    func advanceRound() {
        guard isHost else { return }

        if roundsCompleted > 0 && !pitches.isEmpty {
            // Show pitches, let current bachelor choose
            gameState = .choosing
            broadcastPitches()

            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) { [weak self] in
                self?.proceedToNextRound()
            }
            return
        }

        if roundsCompleted >= players.count {
            gameState = .gameOver
            broadcastGameEnd()
            return
        }

        currentBachelorIndex = roundsCompleted
        gameState = .pitching
        roundsCompleted += 1
        broadcastPitchingPhase()
    }

    private func proceedToNextRound() {
        gameState = .nextRound
        advanceRound()
    }

    private func broadcastPitchingPhase() {
        let packet = GamePacket(
            type: .roundStarted,
            sender: localPlayerID,
            senderName: "Host"
        )
        multipeerSession.send(packet)
    }

    private func broadcastPitches() {
        let payload = BroadcastPitchesPayload(pitches: pitches)
        let packet = GamePacket(
            type: .stateUpdate,
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

    func submitPitch(greenFlags: [FlagCard], redFlag: FlagCard, text: String) {
        let pitch = DatePitch(
            playerID: localPlayerID,
            playerName: "",
            greenFlags: greenFlags,
            redFlag: redFlag,
            additionalText: text
        )

        let payload = SubmitPitchPayload(
            playerID: localPlayerID,
            playerName: "",
            greenFlags: greenFlags,
            redFlag: redFlag,
            additionalText: text
        )

        let packet = GamePacket(
            type: .submitAction,
            sender: localPlayerID,
            senderName: "",
            payload: payload
        )
        multipeerSession.send(packet)
    }

    func choosePitch(_ pitch: DatePitch) {
        guard isHost else { return }
        chosenPitch = pitch

        let payload = ChooseDatePayload(chosenPitchID: pitch.id, bachelorID: players[currentBachelorIndex].id)
        let packet = GamePacket(
            type: .submitVote,
            sender: localPlayerID,
            senderName: "Host",
            payload: payload
        )
        multipeerSession.send(packet)
    }

    // MARK: - PacketHandler

    func processPacket(_ packet: GamePacket) {
        switch packet.type {
        case .roundStarted:
            gameState = .pitching
            pitches.removeAll()

        case .submitAction:
            if let payload: SubmitPitchPayload = packet.decodePayload(SubmitPitchPayload.self) {
                let pitch = DatePitch(
                    playerID: payload.playerID,
                    playerName: packet.senderName,
                    greenFlags: payload.greenFlags,
                    redFlag: payload.redFlag,
                    additionalText: payload.additionalText
                )
                pitches.append(pitch)

                if isHost && pitches.count == (players.count - 1) {
                    advanceRound()
                }
            }

        case .stateUpdate:
            if let payload: BroadcastPitchesPayload = packet.decodePayload(BroadcastPitchesPayload.self) {
                pitches = payload.pitches
                gameState = .reveal
            }

        case .submitVote:
            if let payload: ChooseDatePayload = packet.decodePayload(ChooseDatePayload.self) {
                if let chosen = pitches.first(where: { $0.id == payload.chosenPitchID }) {
                    chosenPitch = chosen
                    gameState = .nextRound
                }
            }

        case .gameEnded:
            gameState = .gameOver

        default:
            break
        }
    }
}
