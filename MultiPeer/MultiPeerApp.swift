import SwiftUI

@main
struct MultiPeerApp: App {
    var body: some Scene {
        WindowGroup {
            PeersView(peersVm: PeersVm())
        }
    }
}
