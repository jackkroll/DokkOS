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
                VStack(alignment:.center){
                    HStack{
                        Spacer()
                        ForEach(peersVm.peersController.session.connectedPeers, id: \.self){peer in
                            SingleRow(userID: peer, selected: $selectedPeers)
                                .frame(width: geo.size.width , height: 50)
                                .padding(3)
                            Spacer()
                        }
                    }
                    Text("Send")
                        .frame(width: geo.size.width * 0.9, height: 60)
                        .foregroundColor(.black)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .background(selectedPeers.count > 0 ? .orange : .gray)
                        .cornerRadius(15)
                        .padding()
                        .onTapGesture {
                            print("Yes")
                            Task{
                                print("Functioning")
                                peersVm.peersController.sendMessage(["callStatus": true], viaStream: true, peersToSend: selectedPeers)
                            }
                            
                        }
                    //.disabled(!(selectedPeers.count > 0))
                    
                    Spacer()
                    Text("Your ID: \(UIDevice.current.identifierForVendor?.uuidString.description ?? "Idfk")")
                }
                .preferredColorScheme(.dark)
                .padding()
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


