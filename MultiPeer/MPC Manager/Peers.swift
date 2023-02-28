
import SwiftUI

import MultipeerConnectivity

/// This is the View Model for PeersView
class PeersVm: ObservableObject {

    public static let shared = PeersVm()

    /// myName and one second counter
    @Published var peersTitle = ""

    /// list of connected peers and their counter
    @Published var peersList = ""
    @Published var peers = []
    
    @Published var beingCalled = false

    public var peersController: PeersController
    private var peerCounter = [String: Int]()
    private var peerStreamed = [String: Bool]()

    init() {
        peersController = PeersController.shared
        peersController.peersDelegates.append(self)
    }
    deinit {
        peersController.remove(peersDelegate: self)
    }

    
}
extension PeersVm: PeersControllerDelegate {

    func didChange() {

        var peerList = ""

        for (name,state) in peersController.peerState {
            peerList += "\n \(state.icon()) \(name)"

            if let count = peerCounter[name]  {
                peerList += ": \(count)"
            }
            if let streamed = peerStreamed[name] {
                peerList += streamed ? "💧" : "⚡️"
            }
        }
        self.peersList = peerList
    }


    func received(data: Data, viaStream: Bool) {

        do {
            let message = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : Any]

            // filter for internal 1 second counter
            // other delegates may capture other messages

            if  let peerName = message["peerName"] as? String,
                let count = message["count"] as? Int {

                peersController.fixConnectedState(for: peerName)

                peerCounter[peerName] = count
                peerStreamed[peerName] = viaStream
                didChange()
            }
            if let recievedMessage = message["callStatus"] as? Bool{
                beingCalled = recievedMessage
                DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                    self.beingCalled = false
                }
            }
        }
        catch {

        }
    }

}
