import Foundation
import Observation
import UIKit

@Observable
final class GameSelectionViewModel: PacketHandler {
    var selectedGame: GameType?
    var multipeerSession: MultipeerSession?

    init() {
        multipeerSession = MultipeerSession(displayName: UIDevice.current.name)
        multipeerSession?.onPacketReceived = { [weak self] packet in
            self?.processPacket(packet)
        }
    }

    func selectGame(_ game: GameType) {
        selectedGame = game
        let packet = GamePacket(
            type: .gameSelected,
            sender: UUID(),
            senderName: multipeerSession?.displayName ?? "Unknown",
            payload: game.rawValue
        )
        multipeerSession?.send(packet)
    }

    func processPacket(_ packet: GamePacket) {
        switch packet.type {
        case .gameSelected:
            if let gameString: String = packet.decodePayload(String.self) {
                selectedGame = GameType(rawValue: gameString)
            }
        default:
            break
        }
    }
}
