import Foundation

final class PacketRouter {
    private var handlers: [PacketType: PacketHandler] = [:]

    func register(handler: PacketHandler, for types: [PacketType]) {
        for type in types {
            handlers[type] = handler
        }
    }

    func route(_ packet: GamePacket) {
        handlers[packet.type]?.processPacket(packet)
    }
}
