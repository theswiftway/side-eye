import Foundation
import MultipeerConnectivity
import Observation

typealias OnPacketReceived = (GamePacket) -> Void
typealias OnPeerConnected = (MCPeerID) -> Void
typealias OnPeerDisconnected = (MCPeerID) -> Void

@Observable
final class MultipeerSession: NSObject, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    let serviceType = "friendlyfires"
    let displayName: String
    var session: MCSession?
    var advertiser: MCNearbyServiceAdvertiser?
    var browser: MCNearbyServiceBrowser?
    var peerID: MCPeerID

    var onPacketReceived: OnPacketReceived?
    var onPeerConnected: OnPeerConnected?
    var onPeerDisconnected: OnPeerDisconnected?

    var connectedPeers: [MCPeerID] = []

    init(displayName: String) {
        self.displayName = displayName
        self.peerID = MCPeerID(displayName: displayName)
        super.init()

        self.session = MCSession(peer: peerID)
        self.session?.delegate = self
    }

    func startHosting() {
        guard let session = session else { return }
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
    }

    func send(_ packet: GamePacket) {
        guard let session = session, let data = try? JSONEncoder().encode(packet) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }

    func sendToPeer(_ packet: GamePacket, peerID: MCPeerID) {
        guard let session = session, let data = try? JSONEncoder().encode(packet) else { return }
        try? session.send(data, toPeers: [peerID], with: .reliable)
    }

    // MARK: - MCSessionDelegate

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                self.onPeerConnected?(peerID)
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
                self.onPeerDisconnected?(peerID)
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let packet = try? JSONDecoder().decode(GamePacket.self, from: data) else { return }
        DispatchQueue.main.async {
            self.onPacketReceived?(packet)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}

    // MARK: - MCNearbyServiceAdvertiserDelegate

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, self.session)
    }

    func advertiserDidNotStartAdvertising(_ advertiser: MCNearbyServiceAdvertiser, error: Error) {}

    // MARK: - MCNearbyServiceBrowserDelegate

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let session = session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}
    func browserDidNotStartBrowsing(_ browser: MCNearbyServiceBrowser, error: Error) {}
}
