import Foundation
import SwiftUI
import Combine
import MultipeerConnectivity


struct BackgroundEffect :View {
    let scaleEffect: CGFloat
    let rotationAngle : Double
    var body: some View {
        GeometryReader{geo in
            VStack {
                VStack{
                    ForEach(0...Int((geo.size.width * 1.25/scaleEffect)), id:\.self){_ in
                        HStack{
                            ForEach(0...Int((geo.size.width/scaleEffect)), id:\.self){_ in
                                
                                    SquareThing()
                                        .frame(width: scaleEffect, height: scaleEffect)
                                        .rotationEffect(Angle(degrees:45))
                                    Image(systemName: "drop")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: scaleEffect * 1.5, height: scaleEffect * 1.5)
                                        .offset(x: 0, y: -(scaleEffect * 0.75))
                                        .padding(scaleEffect * 0.75)
                                        
                                
                            }
                            .foregroundColor(.gray)
                            
                            
                        }
                        .rotationEffect(Angle(degrees: rotationAngle), anchor: .leading)
                    }
                    .offset(x: -geo.size.height/2)
                }
            }
        }
    }
}
struct SquareThing: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        let gap = 0.0625
        //bottom right
        path.addRect(CGRect(x: gap*width, y: gap*height, width: 0.1*width, height: 0.75*height))
        path.addRect(CGRect(x: gap*width, y: gap*height, width: 0.75*width, height: 0.1*height))
        
        path.addRect(CGRect(x: -gap*width, y: gap*height, width: -0.1*width, height: 0.75*height))
        path.addRect(CGRect(x: -gap*width, y: gap*height, width: -0.75*width, height: 0.1*height))
        
        path.addRect(CGRect(x: gap*width, y: -gap*height, width: 0.1*width, height: -0.75*height))
        path.addRect(CGRect(x: gap*width, y: -gap*height, width: 0.75*width, height: -0.1*height))
        
        path.addRect(CGRect(x: -gap*width, y: -gap*height, width: -0.1*width, height: -0.75*height))
        path.addRect(CGRect(x: -gap*width, y: -gap*height, width: -0.75*width, height: -0.1*height))
        /*
        path.addRect(CGRect(x: 0, y:0, width: 5, height: 200))
        path.addRect(CGRect(x: 0, y:0, width: 5, height: -200))
        path.addRect(CGRect(x: 0, y:0, width: 200, height: 5))
        path.addRect(CGRect(x: 0, y:0, width: -200, height: 5))
         */
    
        return path
    }
}
struct HackPattern : View{
    let timer = Timer.publish(every: 0.5, on:.main, in: .common)
        .autoconnect()
        .eraseToAnyPublisher()
    let scale : CGFloat = 60
    let sparcity : Double = 0.1
    var body: some View{
        GeometryReader{geo in
            VStack(spacing:0){
                ForEach(0...Int(geo.size.height/scale), id: \.self){_ in
                    HStack(spacing: 0){
                        ForEach(0...Int(geo.size.width/scale), id: \.self){_ in
                            SinglePixel(sparcity: 0.05, timer: timer)
                                .frame(width: scale, height: scale)
                        }
                    }
                }
            }
        }
    }
}

struct SinglePixel: View{
    @State var illuminated : Bool = false
    let sparcity : Double
    var timer : AnyPublisher<Date,Never>
    var body: some View{
        Rectangle()
            .foregroundColor(illuminated ? .gray : .black)
            .onReceive(timer){timer in
                if Int.random(in: (0...Int(100 * sparcity))) == 1{
                        illuminated = true
                    }
                    else{
                        illuminated = false
                    }
                
            }
    }
}
struct SingleRow : View {
    @State var toggled = true
    @State var userID : MCPeerID
    @State var ally = false
    @Binding var selected : [MCPeerID]
    var body: some View{
        GeometryReader{geo in
            HStack{
                Rectangle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(toggled ? .orange : .gray)
                    .overlay{
                        if toggled{
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .foregroundColor(.white)
                        }
                        Rectangle().stroke(lineWidth: 3)
                    }
                
                HStack{
                    ScrollView(.horizontal){
                        HStack{
                            Text(ally ? "ally" : "???")
                                .padding()
                            Rectangle()
                                .frame(width: 2)
                                .padding([.top, .bottom], 10)
                            Text(userID.displayName)
                            Rectangle()
                                .frame(width: 2)
                                .padding([.top, .bottom], 10)
                            Text("FDMA")
                            Spacer()
                        }
                        
                    }
                    .frame(height: geo.size.height)
                    .background(Rectangle().stroke(lineWidth: 3))
                }
                .background(toggled ? .orange.opacity(0.5) : .clear)
                Spacer()
            }
            .padding()
            .frame(width: geo.size.width)
            .disabled(ally)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)){
                    let position : Int? = selected.firstIndex(of: userID)
                    if position != nil{
                        selected.remove(at: position!)
                        toggled = false
                    }
                    else{
                        selected.append(userID)
                        toggled = true
                    }
                }
            }
        }
    }
}

/*
struct ViewProvider_Previews: PreviewProvider {
    static var previews: some View {
        SingleRow(userID: MCPeerID(displayName: "certified ID moment"))
            .frame(width: 400, height: 50)
    }
}
*/
