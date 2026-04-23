import Foundation
import Observation

@Observable
final class GameSelectionViewModel: PacketHandler {
    let sessionState: GameSessionState
    let multipeerSession: MultipeerSession
    var selectedGame: GameType?
    var players: [PlayerDTO] = []
    var isHost: Bool
    var canStart: Bool {
        guard let game = selectedGame else { return false }
        return players.count >= game.minPlayers
    }

    init(
        sessionState: GameSessionState,
        multipeerSession: MultipeerSession,
        isHost: Bool,
        players: [PlayerDTO]
    ) {
        self.sessionState = sessionState
        self.multipeerSession = multipeerSession
        self.isHost = isHost
        self.players = players
    }

    func selectGame(_ game: GameType) {
        guard isHost else { return }
        selectedGame = game

        let packet = GamePacket(
            type: .gameSelected,
            sender: sessionState.hostID,
            senderName: "Host",
            payload: game
        )
        multipeerSession.send(packet)
    }

    func startGame() {
        guard isHost, selectedGame != nil else { return }
        let packet = GamePacket(
            type: .gameStarted,
            sender: sessionState.hostID,
            senderName: "Host"
        )
        multipeerSession.send(packet)
    }

    // MARK: - PacketHandler

    func processPacket(_ packet: GamePacket) {
        switch packet.type {
        case .gameSelected:
            if let game: GameType = packet.decodePayload(GameType.self) {
                selectedGame = game
            }

        case .playerJoined:
            if let player: PlayerDTO = packet.decodePayload(PlayerDTO.self) {
                if !players.contains(where: { $0.id == player.id }) {
                    players.append(player)
                }
            }

        case .playerLeft:
            if let playerID: UUID = packet.decodePayload(UUID.self) {
                players.removeAll { $0.id == playerID }
            }

        default:
            break
        }
    }
}
