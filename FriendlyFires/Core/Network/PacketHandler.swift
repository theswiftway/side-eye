import Foundation

protocol PacketHandler: AnyObject {
    func processPacket(_ packet: GamePacket)
}
