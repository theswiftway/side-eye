import Foundation
import MultipeerConnectivity
import SwiftUI
import Observation

@Observable
final class MultipeerSession: NSObject {
    private let serviceType = "friendlyfire"
    private let myPeerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    @ObservationIgnored
    var onPacketReceived: ((GamePacket) -> Void)?

    @ObservationIgnored
    var onPeerConnected: ((MCPeerID) -> Void)?

    @ObservationIgnored
    var onPeerDisconnected: ((MCPeerID) -> Void)?

    var connectedPeers: [MCPeerID] = []
    var isHosting: Bool = false
    var availablePeers: [MCPeerID] = []

    init(displayName: String) {
        self.myPeerID = MCPeerID(displayName: displayName)
        super.init()
    }

    // MARK: - Host Mode

    func startHosting(sessionName: String) {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        self.session = session
        self.isHosting = true

        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: ["sessionName": sessionName],
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    // MARK: - Guest Mode

    func startBrowsing() {
        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        self.session = session
        self.isHosting = false

        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func invitePeer(_ peerID: MCPeerID) {
        guard let browser else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    // MARK: - Communication

    func send(_ packet: GamePacket) {
        guard let session else { return }
        guard !session.connectedPeers.isEmpty else { return }

        do {
            let data = try JSONEncoder().encode(packet)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending packet: \(error)")
        }
    }

    func sendToPeer(_ packet: GamePacket, peerID: MCPeerID) {
        guard let session else { return }

        do {
            let data = try JSONEncoder().encode(packet)
            try session.send(data, toPeers: [peerID], with: .reliable)
        } catch {
            print("Error sending packet to peer: \(error)")
        }
    }

    // MARK: - Cleanup

    func stop() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
        advertiser = nil
        browser = nil
        session = nil
        connectedPeers = []
        availablePeers = []
    }

    deinit {
        stop()
    }
}

// MARK: - MCSessionDelegate

extension MultipeerSession: MCSessionDelegate {
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                self.onPeerConnected?(peerID)
            case .connecting:
                break
            case .notConnected:
                self.connectedPeers.removeAll { $0.displayName == peerID.displayName }
                self.onPeerDisconnected?(peerID)
            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let packet = try JSONDecoder().decode(GamePacket.self, from: data)
            DispatchQueue.main.async {
                self.onPacketReceived?(packet)
            }
        } catch {
            print("Error decoding packet: \(error)")
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not used for this project
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not used for this project
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?) {
        // Not used for this project
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        // Host accepts all invitations
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availablePeers.removeAll { $0.displayName == peerID.displayName }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Browser error: \(error)")
    }
}
