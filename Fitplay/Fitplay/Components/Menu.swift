//
//  Menu.swift
//  Fitplay
//
//  Created by Scorpus on 3/23/23.
//

import SwiftUI

struct CustomMenu: View {
    @Environment(\.verticalSizeClass) var size
//    @Binding var isCalenderSelected:Bool
    @EnvironmentObject var data: DataManager
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                HStack {
                    Button {
                        withAnimation { data.isCalendar = false }
                    } label: {
                        VStack {
                            Image(systemName: "house")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25,height: 25)
                                .frame(width: 150,height: 60)
                                .offset(y:15)
                            
                            Text("Home")
                                .font(.system(size: 10, weight: .light))
                        }
                        .foregroundColor( !data.isCalendar ? Color(hex: "#E6863B") : Color(hex: "#7E7E7E"))
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation { data.isCalendar = true }
                    } label: {
                        VStack {
                            Image(systemName: "calendar")
                                .resizable()
                                .frame(width: 20,height: 20)
                                .frame(width: 150,height: 60)
                                .offset(y:15)
                            
                            Text("Calendar")
                                .font(.system(size: 10, weight: .light))
                        }
                        .foregroundColor( data.isCalendar ? Color(hex: "#E6863B") : Color(hex: "#7E7E7E"))

                    }
                }
                
//                if data.user?.classes.isEmpty == true {
//                    Button {
//                        withAnimation { data.add.toggle() }
//                    } label: {
//                        Image(systemName: "plus.square.fill")
//                            .resizable()
//                            .frame(width: 20,height: 20)
//                            .foregroundColor(.white)
//                            .frame(width: 60,height: 60)
//                            .background(Color(hex: "#4275DC"))
//                            .cornerRadius(30, corners: .allCorners)
//                            .offset(y:-30)
//                    }
//                }
            }
            .frame(width:proxy.frame(in: .global).width,height:120)
            .background(.regularMaterial, in: CustomShape(centerX: proxy.frame(in: .global).midX)
            )
            .cornerRadius(25, corners: [.topLeft,.topRight])
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
        }
    }
}

struct Menu_Previews: PreviewProvider {
    static var previews: some View {
        CustomMenu()
            .environmentObject(DataManager())
    }
}
struct CustomShape: Shape {
    var centerX : CGFloat
    var animatableData: CGFloat{
        get{return centerX}
        set{centerX = newValue}
    }
    
    func path(in rect: CGRect) -> Path {
        return Path{path in
            path.move(to: CGPoint(x: 30, y: 30))
            path.addQuadCurve(to: CGPoint(x: 0, y: 60), control: CGPoint(x: 0, y: 30))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: rect.width, y: 60))
            path.addQuadCurve(to: CGPoint(x: rect.width-30, y: 30), control: CGPoint(x: rect.width, y: 30))
            path.move(to: CGPoint(x: centerX + 60, y: 30))
            path.addQuadCurve(to: CGPoint(x: centerX - 60, y: 30), control: CGPoint(x: centerX, y: 100))
        }
        
    }
}
