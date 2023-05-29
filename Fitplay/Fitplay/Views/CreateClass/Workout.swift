//
//  Workout.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 3/28/23.
//

import Kingfisher
import SwiftUI

struct Workout: View {
    
    /// Inheriting Class Manager Object
    @EnvironmentObject var classes: DataManager
        
    @Environment(\.dismiss) var dismiss
    
    @State var showLyrics = false
    
    @State var percent: Float = 60
    
    @AppStorage("accent") var accent = "#007AFF"
    @AppStorage("dark_mode") var dark = false
    
    @ViewBuilder
    var body: some View {
        if let playing = classes.playing {
            VStack(spacing: 0) {
                
                if let image = playing.image {
                    KFImage(image)
                        .resizable()
                        .frame(width: width, height: 400)
                        .overlay(Color.black.opacity(0.5))
                        .cornerRadius(50, corners: [.bottomLeft])
                } else {
                    Image("working")
                        .resizable()
                        .frame(width: width, height: 400)
                        .overlay(Color.black.opacity(0.5))
                        .cornerRadius(50, corners: [.bottomLeft])
                }
                
                ZStack {
                    Color(.systemBackground)
                    
                    VStack {
                        HStack {
                            Text("\(classes.progressed < 60 ? "00:" : "")\(classes.progressed.asString(style: .positional))")
                            
                            Spacer()
                            
                            Text(playing.duration.asString(style: .positional))
                        }
                        .foregroundColor(Color(.lightGray))
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.gray)
                                    .frame(height: 10)
                                HStack(spacing: 0) {
                                    Capsule().fill(Color(hex: accent))
                                        .frame(width: geometry.size.width * CGFloat(self.percent / 100), height: 10)
                                    
                                    Circle()
                                        .fill(Color(hex: accent))
                                        .frame(height: 20)
                                        .offset(x: -5)
                                }
                                .onChange(of: classes.progressed) { v in
                                    print(v)
                                    withAnimation { self.percent = Float(v / playing.duration * 100)  }
                                }
                                .onAppear {
                                    self.percent = Float(classes.progressed / playing.duration * 100)
                                }
                            }
                            .cornerRadius(12)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        self.percent = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)
                                        classes.progressed = Double((percent / 100)) * playing.duration
                                    }
                            )
                        }
                    }
                    .padding(.top)
                    .frame(width: width * 0.7)
                }
                .cornerRadius(50, corners: [.topRight])
                .background(
                    Group {
                        if let image = playing.image {
                            KFImage(image)
                                .resizable()
                                .rotationEffect(.init(degrees: 180))
                        } else {
                            Image("working")
                                .resizable()
                                .rotationEffect(.init(degrees: 180))
                        }
                    }
                )
                .frame(height: 100)
                
                VStack(alignment: .leading) {
                    Text(playing.title)
                        .font(.system(size: 25, weight: .heavy, design: .default))
                    
                    Text(playing.workouts.map { $0.exercise }.prefix(3).joined(separator: ", "))
                        .padding(.leading)
                        .foregroundColor(Color(.gray))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                
                HStack(spacing: 15) {
                    Spacer()
                    
                    Button {
                        if classes.progressed - 10 < 0 {
                            withAnimation { classes.progressed = 0 }
                        } else {
                            withAnimation { classes.progressed -= 10 }
                        }
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 30))
                    }
                    .foregroundColor(.primary)
                    
                    Button {
                        withAnimation {
                            classes.isPlaying.toggle()
                            classes.toggleTimer(playing.duration)
                        }
                    } label: {
                        Image(systemName: classes.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .padding(25)
                            .background(Color(hex: "#CE8E57"))
                            .clipShape(Circle())
                    }
                    
                    Button {
                        if classes.progressed + 10 > playing.duration {
                            withAnimation { classes.progressed = playing.duration }
                        } else {
                            withAnimation { classes.progressed += 10 }
                        }
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 30))
                    }
                    .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.bottom, 30)
                .frame(height: 130)
                .background(Color(.systemBackground))
                .cornerRadius(150, corners: [.bottomLeft, .bottomRight])
                .background(dark ? Color(.secondarySystemBackground) : Color(.lightGray))
                .overlay(
                    HStack {
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "square.and.arrow.up.on.square.fill")
                                .imageScale(.large)
                                .foregroundColor(.primary)
                        }

                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "plus.circle")
                                .imageScale(.large)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 25), alignment: .bottom)
                
                dark ? Color(.secondarySystemBackground) : Color(.lightGray)
            }
            .overlay {
                VStack(spacing: 0) {
                    HStack {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .font(.system(size: 20))
                            }

                            Spacer()
                        }
                        Spacer()
                        Text("Now Playing")
                            .font(.system(size: 20, weight: .regular, design: .default))
                        Spacer()
                        HStack {
                            Spacer()
                            ZStack {
                                Rectangle()
                                    .fill(Color(.systemBackground))
                                    .cornerRadius(1000, corners: [.topLeft, .bottomLeft])
                                
                                Circle()
                                    .stroke(Color(.lightGray), lineWidth: 5)
                                    .padding()
                                Circle()
                                    .trim(from: 0, to: classes.progressed / playing.duration)
                                    .stroke(Color(hex: accent), lineWidth: 5)
                                    .padding()
                                    .rotationEffect(.init(degrees: 270))
                                
                                Text(classes.progressed.asString(style: .positional))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: accent))
                            }
                            .frame(width: 90, height: 90)
                        }
                    }
                    .padding(.top, 20)
                    .foregroundColor(.white)
                    .padding(.leading)
                    
                    VStack(alignment: .leading) {
                        Text(playing.title)
                            .font(.system(size: 25, weight: .heavy, design: .default))
                        
                        Text(playing.workouts.map { $0.exercise }.prefix(3).joined(separator: ", "))
                            .padding(.leading, 20)
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    ZStack {
                        Color(showLyrics ? .lightGray : .systemBackground)
                            .frame(height: showLyrics ? height * 0.8 : 100)
                            .cornerRadius(showLyrics ? 10 : 50, corners: [.topLeft, .topRight])
                        
                        VStack(spacing: 0) {
                            Button {
                                withAnimation { showLyrics.toggle() }
                            } label: {
                                VStack {
                                    Image(systemName: "chevron.up")
                                        .foregroundColor(Color(hex: accent))
                                        .font(.system(size: 21))
                                        .rotationEffect(.init(degrees: showLyrics ? 180 : 0))
                                    
                                    Text("Notes")
                                        .foregroundColor(.primary)
                                        .padding(.top, 5)
                                }
                            }
                            .padding(.top, 20)
                            .padding(.top, showLyrics ? nil : 0)
                            
                            Group {
                                ScrollView(showsIndicators: false) {
                                    VStack {
                                        ForEach(playing.text) { t in
                                            Text(t.text)
                                                .font(.system(size: 25, weight: .bold))
                                                .foregroundColor(t.start < classes.progressed && t.end > classes.progressed ? .black : Color(.darkGray).opacity(0.5))
                                                .padding(.vertical, 8)
                                        }
                                    }
                                }
                                .frame(height: height * 0.6)
                                .frame(maxWidth: .infinity)
                                .background(Color(.lightGray))
                                .cornerRadius(50, corners: .bottomLeft)
                                .background(alignment: .bottom) {
                                    Color(.systemBackground)
                                        .frame(height: 200)
                                }
                               
                                Bottom(showAlways: true)
                                    .environmentObject(classes)
                            }
                            .opacity(showLyrics ? 1 : 0)
                            .frame(height: showLyrics ? nil : 0)
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct Workout_Previews: PreviewProvider {
    static var previews: some View {
        Workout()
            .environmentObject(DataManager())
    }
}

struct Bottom: View {
    
    /// Inheriting Class Manager Object
    @EnvironmentObject var classes: DataManager
    
    let editing: Bool
    
    let showAlways: Bool
    
    init(editing: Bool = false, showArrow: Bool = false, showAlways: Bool = false) {
        self.editing = editing
        self.showArrow = showArrow
        self.showAlways = showAlways
    }
    
    let showArrow: Bool
    
    @AppStorage("accent") var accent = "#007AFF"
    
    @ViewBuilder
    var body: some View {
        if let playing = classes.playing, (classes.isPlaying == true || showAlways) {
            VStack {
                if showArrow {
                    Image(systemName: "chevron.up")
                        .foregroundColor(Color(hex: accent))
                }
                HStack {
                    ZStack {
                        
                        if let image = playing.image {
                            KFImage(image)
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 60, height: 60)
                        } else {
                            Image("woman")
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 60, height: 60)
                        }
                        
                        Circle()
                            .stroke(.gray, lineWidth: 5)
                            .rotationEffect(.init(degrees: 270))
                        Circle()
                            .trim(from: 0, to: classes.progressed / playing.duration)
                            .stroke(Color(hex: accent), lineWidth: 5)
                            .rotationEffect(.init(degrees: 270))
                    }
                    .frame(width: 65, height: 65)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(playing.title)
                            .font(.title2)
                        Text(playing.workouts.map { $0.exercise }.prefix(3).joined(separator: ", "))
                            .font(.callout)
                    }
                    .foregroundColor(.primary.opacity(0.5))
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            classes.isPlaying.toggle()
                            classes.toggleTimer(playing.duration)
                        }
                    } label: {
                        Image(systemName: editing ? "plus.app.fill" : classes.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "#CE8E57"))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: showArrow ? 120 : 100)
            .background(Color(.systemBackground))
            .cornerRadius(50, corners: [.topRight])
            .ignoresSafeArea()
        }
    }
}

struct TimeString: Identifiable {
    var id = UUID().uuidString
    var text: String = ""
    var start: TimeInterval
    var end: TimeInterval
}
