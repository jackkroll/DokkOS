import UIKit
import MultipeerConnectivity

public protocol PeersControllerDelegate: AnyObject {
    func didChange()
    func received(data: Data, viaStream: Bool)
}

public typealias PeerName = String

public class PeersController: NSObject {

    public static var shared = PeersController()



    ///        Bonjour services
    ///        _xxxxx._ucp
    ///        _xxxxx._tcp
    ///
    let serviceType = "multipeer-test"

    private let myPeerID = MCPeerID(displayName: UIDevice.current.identifierForVendor?.uuidString.description ?? "NoDeviceIdentifier")
    private let startTime = Date().timeIntervalSince1970

    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    public var peerState = [PeerName: MCSessionState]()
    public var hasPeers = false
    public var peersDelegates = [any PeersControllerDelegate]()
    public func remove(peersDelegate: any PeersControllerDelegate) {
        peersDelegates = peersDelegates.filter { return $0 !== peersDelegate }
    }
    public lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerID)
        session.delegate = self
        return session
    }()
    public lazy var myName: PeerName = {
        return session.myPeerID.displayName
    }()

    override init() {
        super.init()
        startAdvertising()
        startBrowsing()
    }
    deinit {
        stopServices()
        session.disconnect()
        session.delegate = nil
    }

    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    func startAdvertising() {
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    private func stopServices() {
        advertiser?.stopAdvertisingPeer()
        advertiser?.delegate = nil

        browser?.stopBrowsingForPeers()
        browser?.delegate = nil
    }
    private func elapsedTime() -> TimeInterval {
        Date().timeIntervalSince1970 - startTime
    }

    func logPeer(_ body: PeerName) {
        let logTime = String(format: "%.2f", elapsedTime())
        print("⚡️ \(logTime) \(myName): \(body)")
    }
}

extension PeersController {

    public func sendMessage(_ message: [String : Any],
                            viaStream: Bool, peersToSend: [MCPeerID]) {
        if session.connectedPeers.isEmpty {
            print("🚫", terminator: "")
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
            sendMessage(data, viaStream: viaStream, peersToSend: peersToSend)
        } catch {
            logPeer("sendMessage error: \(error.localizedDescription)")
            return
        }
    }
    public func sendMessage(_ data: Data,
                            viaStream: Bool, peersToSend : [MCPeerID]) {
        do {
            if viaStream {
                for peerID in peersToSend {
                    let peerName = peerID.displayName
                    let streamName = "\(elapsedTime()): \"\(peerName)\""

                    if let outputStream = try? session.startStream(withName: streamName, toPeer: peerID) {
                        outputStream.delegate = self
                        outputStream.schedule(in: .main,  forMode: .common)
                        outputStream.open()
                        let count = outputStream.write(data.bytes, maxLength: data.bytes.count)
                        outputStream.close()
                        logPeer("💧send: toPeer: \"\(peerName)\" bytes: \(count)")
                    }
                }
            } else {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
                logPeer("⚡️send toPeers")
            }
        } catch {
            logPeer("sendMessage error: \(error.localizedDescription)")
        }
    }

    func fixConnectedState(for peerName: String) {
        peerState[peerName] = .connected
    }

}
