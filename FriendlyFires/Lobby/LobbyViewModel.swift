import Foundation
import Observation
import UIKit

@Observable
final class LobbyViewModel: PacketHandler {
    var players: [PlayerDTO] = []
    var isHost: Bool = false
    var multipeerSession: MultipeerSession?

    init() {
        multipeerSession = MultipeerSession(displayName: UIDevice.current.name)
        multipeerSession?.onPacketReceived = { [weak self] packet in
            self?.processPacket(packet)
        }
    }

    func startBrowsing() {
        multipeerSession?.startBrowsing()
        isHost = false
        addLocalPlayer()
    }

    func startHosting() {
        multipeerSession?.startHosting()
        isHost = true
        addLocalPlayer()
    }

    private func addLocalPlayer() {
        guard let session = multipeerSession else { return }
        let player = Player(displayName: session.displayName, avatarColorIndex: Int.random(in: 0..<10), isHost: isHost)
        let localPlayer = PlayerDTO(from: player)
        if !players.contains(where: { $0.displayName == localPlayer.displayName }) {
            players.append(localPlayer)
        }
    }

    func selectGame(_ gameType: GameType) {
        let packet = GamePacket(
            type: .gameSelected,
            sender: UUID(),
            senderName: multipeerSession?.displayName ?? "Unknown",
            payload: gameType.rawValue
        )
        multipeerSession?.send(packet)
    }

    func processPacket(_ packet: GamePacket) {
        switch packet.type {
        case .playerJoined:
            if let player: PlayerDTO = packet.decodePayload(PlayerDTO.self) {
                if !players.contains(where: { $0.id == player.id }) {
                    players.append(player)
                }
            }
        default:
            break
        }
    }
}
