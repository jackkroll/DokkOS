//It work? :O

import SwiftUI
import MultipeerConnectivity

struct PeersView: View {
    @ObservedObject var peersVm: PeersVm
    var peersTitle: String { peersVm.peersTitle }
    var peersList: String { peersVm.peersList }
    @State var selectedPeers : [MCPeerID] = []
    
    var body: some View {
        ZStack{
            BackgroundEffect(scaleEffect: 20, rotationAngle: -33)
            GeometryReader{ geo in
                VStack{
                ForEach(peersVm.peersController.session.connectedPeers, id: \.self){peer in
                        SingleRow(userID: peer, selected: $selectedPeers)
                            .frame(width: geo.size.width , height: 50)
                }
                    Spacer()
                    
                    BottomBar(selectedPeers: $selectedPeers, peersVm: peersVm)
                        .frame(width: geo.size.width , height: 175)
                        //.ignoresSafeArea(.all)
                        
                    //.disabled(!(selectedPeers.count > 0))
                }
                .preferredColorScheme(.dark)
                .sheet(isPresented: $peersVm.beingCalled){
                    ZStack{
                        HackPattern()
                        VStack{
                            Text("까불지마")
                        }
                    }
                }
            }
        }
    }
}
struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        PeersView(peersVm: PeersVm())
    }
}

struct Hack_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            HackPattern()
            VStack{
                Text("까불지마")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.all)
    }
}


