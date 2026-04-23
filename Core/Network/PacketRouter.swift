import Foundation

protocol PacketHandler {
    func processPacket(_ packet: GamePacket)
}

class PacketRouter {
    private var handlers: [PacketType: PacketHandler] = [:]

    func register(_ handler: PacketHandler, for packetTypes: [PacketType]) {
        for type in packetTypes {
            handlers[type] = handler
        }
    }

    func unregister(_ packetTypes: [PacketType]) {
        for type in packetTypes {
            handlers.removeValue(forKey: type)
        }
    }

    func route(_ packet: GamePacket) {
        if let handler = handlers[packet.type] {
            handler.processPacket(packet)
        } else {
            print("No handler registered for packet type: \(packet.type)")
        }
    }
}
