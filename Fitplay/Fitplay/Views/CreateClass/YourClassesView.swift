//
//  ClassesView.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import Kingfisher
import SwiftUI

struct ClassesView: View {
    
    /// Initializing New Class Manager Object
    @EnvironmentObject var manager: DataManager
    
    @State var fullScreen = false
    
    //    @State var workouts = [Category.Workout]()
    
    @GestureState var isDragging = false
    
    @State var edit = false
    
    @AppStorage("accent") var accent = "#007AFF"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                VStack(alignment: .leading, spacing: 0) {
                    /// If the user has not created any classes or there is no user
                    let noClasses = manager.user?.classes.isEmpty == true || manager.user == nil
                    
                    VStack(spacing: 4) {
                        Text("Your Classes")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .font(Fonts.title)
                        
                        if noClasses {
                            Text("You have not created any classes yet. To do that press the add button.")
                                .font(.system(size: 16))
                                .lineSpacing(3)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding([.top, .leading])
                    
                    
                    VStack(spacing: 0) {
                        Color(.systemBackground)
                            .cornerRadius(40, corners: [.bottomLeft])
                            .background(Color(.lightGray).opacity(0.5))
                            .frame(maxHeight: noClasses ? .infinity : 40)
                        ZStack {
                            Color(.lightGray).opacity(0.5)
                                .cornerRadius(40, corners: [.topRight, .bottomLeft])
                            
                            if !noClasses {
                                ScrollView(.vertical, showsIndicators: false) {
                                                                        let classes = manager.user?.classes ?? []
                                    VStack {
                                        ForEach(Array(zip(classes.indices, classes)), id: \.0) { index, select in
                                            cell(index, select: select)
                                        }
                                    }
                                    .padding(.vertical, 50)
                                }
                            }
                        }
                        .frame(maxHeight: noClasses ? 120 : nil)
                    }
                    .overlay(alignment: noClasses ? .bottom : .top) {
                        Button {
                            withAnimation { manager.add.toggle() }
                        } label: {
                            VStack {
                                Image(systemName: "plus.app.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                                    .padding(20)
                                    .background(Color(hex: accent), in: Circle())
                                
                                Text("Create Class")
                                    .font(.system(size: 11, weight: .light))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, noClasses ? 70 : 0)
                    }
                    
                    Button {
                        fullScreen.toggle()
                    } label: {
                        Bottom(showArrow: true)
                            .environmentObject(manager)
                            .background(Color(.lightGray).opacity(0.5))
                    }
                }
                .zIndex(0)
                .edgesIgnoringSafeArea(.bottom)
                .fullScreenCover(isPresented: $fullScreen) {
                    Workout()
                        .environmentObject(manager)
                }
                
                NewWorkout()
                    .environmentObject(manager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                    .zIndex(2)
                    .frame(height: manager.add ? nil : 0)
                    .opacity(manager.add ? 1 : 0)
                
                EditCategory(edit: $edit, display: true)
                    .environmentObject(manager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                    .zIndex(3)
                    .frame(height: manager.editWorkouts ? nil : 0)
                    .opacity(manager.editWorkouts ? 1 : 0)
            }
        }
        .navigationTitle("")
        .accentColor(.primary)
        .fullScreenCover(isPresented: $edit) {
            if let index = manager.editIndex {
                ClassDetailsEditView(index: index, edit: $fullScreen)
                    .environmentObject(manager)
            }
        }
    }
    
    func cell(_ index: Int, select: Category) -> some View {
        ZStack {
            
            Color.red
                .cornerRadius(10)
            
            HStack {
                
                Spacer()
                
                Button {
                    remove(at: index)
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .frame(width: 65)
                }
            }
            
            let playing = manager.isCurrentlyPlaying(for: select.id)
            
            HStack {
                Button {
                    withAnimation {
                        self.manager.playing = select
                        manager.isPlaying.toggle()
                        manager.toggleTimer(select.duration)
                    }
                } label: {
                    Image(systemName: playing ? "pause.fill" : "play.fill")
                        .font(.system(size: 25))
                        .foregroundColor(playing ? .white : Color(hex: "#CE8E57"))
                        .padding()
                        .background(
                            Circle()
                                .stroke(Color(hex: "#CE8E57"), lineWidth: 2)
                        )
                        .background(
                            Circle()
                                .fill(Color(hex: "#CE8E57").opacity(playing ? 1 : 0))
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(select.title)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 18, weight: .regular, design: .default))
                    
                    var hasWorkouts = select.workouts.count > 0
                    
                    let subtitle = hasWorkouts ? select.workouts.prefix(3).map(\.exercise).joined(separator: ", ") : select.description
                    
                    Text(subtitle)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(Color(.lightGray))
                    
                }
                
                Spacer()
                
                VStack {
                    Text(select.duration == 0 ? "0:00" : select.duration.asString(style: .positional))
                        .font(.system(size: 13))
                        .foregroundColor(Color(.lightGray))
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.vertical)
            }
            .padding(.horizontal)
            .frame(height: 75)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10))
            .offset(x: select.offset)
            .gesture(
                DragGesture()
                    .updating($isDragging) { value, state, _ in
                        state = true
                        onChanged(value: value, index: index)
                    }
                    .onEnded { (value) in
                        onEnd(value: value, index: index)
                    }
            )
        }
        .onDrag {
            manager.currentDraggingPage = select
            return NSItemProvider(contentsOf: URL(string: "\(select.id)")!)!
        }
        .onDrop(of: [.url], delegate: ClassesDropDelegate(image: select, data: manager))
        .padding(.horizontal)
        .padding(.top)
        .onTapGesture {
            manager.editIndex = index
            edit.toggle()
        }
    }
    
    func remove(at index: Int) {
        manager.editIndex = nil
        withAnimation { manager.user?.classes.remove(at: index) }
        manager.update()
    }
    
    func onChanged(value: DragGesture.Value, index: Int){
        
        if value.translation.width < 0 && isDragging {
            manager.user?.classes[index].offset = value.translation.width
        }
    }
    
    func onEnd(value: DragGesture.Value,index: Int) {
        withAnimation {
            if -value.translation.width >= 50 {
                manager.user?.classes[index].offset = -65
            } else {
                manager.user?.classes[index].offset = 0
            }
        }
    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
        ClassesView()
            .environmentObject(DataManager())
    }
}

struct EditCategory: View {
    
    /// Inheriting Class Manager
    @EnvironmentObject var manager: DataManager
            
    @State var show = false
    @State var showAnimated = false
    
    @Binding var edit: Bool
    
    let display: Bool
    
    func options(_ index: Int) -> [Category.Workout] {
        if (manager.user?.classes[index].options ?? []).isEmpty {
            return manager.options.first(where: { $0.options.map(\.exercise).contains(where: { e in
                (manager.user?.classes[index].workouts ?? []).contains(where: { $0.exercise == e })
            }) })?.options ?? []
        } else {
            return manager.user?.classes[index].options ?? []
        }
    }
    
    @ViewBuilder
    var body: some View {
        if let index = manager.editIndex {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text(manager.user?.classes[index].title ?? "")
                        .font(.title.bold())
                    
                    Text("\(options(index).count) Total Moves")
                        .foregroundColor(Color(.systemBackground))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 8)
                        .background(Capsule().fill(.primary))
                    
                    Spacer()
                }
                .padding([.top, .horizontal])
                
                HStack(alignment: .top) {
                    Text("Pick moves to add to your class")
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(Color(.lightGray))
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Show Equipment")
                        Toggle("", isOn: $show)
                            .onChange(of: show) { _ in
                                withAnimation { showAnimated = show }
                            }
                    }
                }
                .padding(.top, 9)
                .padding(.horizontal)
                .padding(.bottom, 5)
                
                HStack {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12))
                    
                    Text("Selected: (\(manager.user?.classes[index].workouts.count ?? 0))")
                    
                    Spacer()
                    
                    if display && manager.user?.classes[index].workouts.isEmpty == false {
                        Button {
                            manager.update(manager.user?.classes[index].id ?? "")
                            withAnimation {
                                manager.editWorkouts = false
                                manager.add = false
                            }
                            if display {
                                manager.editIndex = index
                                edit.toggle()
                            }
                        } label: {
                            Text("Add Selected")
                            
                            Image(systemName: "plus.app.fill")
                                .imageScale(.large)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 7)
                
                ScrollView {
                    VStack {}.frame(height: 10)
                    ForEach(options(index)) { workout in
                        let s = manager.user?.classes[index].workouts.contains(workout) ?? false
                        Button {
                            withAnimation {
                                if let workoutIndex = manager.user?.classes[index].workouts.firstIndex(where: { $0.id == workout.id }) {
                                    manager.user?.classes[index].workouts.remove(at: workoutIndex)
                                } else {
                                    manager.user?.classes[index].workouts.append(workout)
                                }
                            }
                        } label: {
                            HStack {
                                if s {
                                    Image(systemName: "checkmark")
                                        .font(.title3.bold())
                                }
                                
                                Text(workout.exercise)
                                    .font(.title)
                                    .padding(.leading)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Spacer()
                                
                                if showAnimated && !workout.equipment.isEmpty {
                                    Text(workout.equipment)
                                        .font(.system(size: 14))
                                        .lineLimit(1)
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 7)
                                        .background(Capsule().fill(Color(s ? .white : .lightGray).opacity(s ? 0.6 : 0.3)))
                                }
                            }
                            .padding(.horizontal)
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        Color(s ? .lightGray : .white)
                                            .opacity(s ? 0.3 : 0)
                                    )
                                )
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

extension Double {
    func asString(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = style
        return formatter.string(from: self) ?? ""
    }
}
