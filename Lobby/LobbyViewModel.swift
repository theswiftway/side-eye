import Foundation
import Observation
import MultipeerConnectivity

@Observable
final class LobbyViewModel: PacketHandler {
    let sessionState: GameSessionState
    let multipeerSession: MultipeerSession
    let packetRouter: PacketRouter
    var localPlayerID: UUID
    var isHost: Bool
    var players: [PlayerDTO] = []
    var selectedGame: GameType?

    init(
        sessionState: GameSessionState,
        multipeerSession: MultipeerSession,
        localPlayerID: UUID,
        isHost: Bool
    ) {
        self.sessionState = sessionState
        self.multipeerSession = multipeerSession
        self.packetRouter = PacketRouter()
        self.localPlayerID = localPlayerID
        self.isHost = isHost

        // Register self as handler for lobby packets
        packetRouter.register(
            self,
            for: [.playerJoined, .playerLeft, .lobbyStateUpdate, .gameSelected]
        )

        // Wire up multipeer callbacks
        self.multipeerSession.onPacketReceived = { [weak self] packet in
            self?.packetRouter.route(packet)
        }
    }

    // MARK: - Host Actions

    func selectGame(_ game: GameType) {
        guard isHost else { return }
        selectedGame = game

        let packet = GamePacket(
            type: .gameSelected,
            sender: localPlayerID,
            senderName: "Host",
            payload: game
        )
        multipeerSession.send(packet)
    }

    func startGame() {
        guard isHost else { return }
        let packet = GamePacket(
            type: .gameStarted,
            sender: localPlayerID,
            senderName: "Host"
        )
        multipeerSession.send(packet)
    }

    // MARK: - PacketHandler

    func processPacket(_ packet: GamePacket) {
        switch packet.type {
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

        case .lobbyStateUpdate:
            if let state: LobbyStatePacket = packet.decodePayload(LobbyStatePacket.self) {
                players = state.players
                selectedGame = state.selectedGameType
            }

        case .gameSelected:
            if let game: GameType = packet.decodePayload(GameType.self) {
                selectedGame = game
            }

        default:
            break
        }
    }
}
