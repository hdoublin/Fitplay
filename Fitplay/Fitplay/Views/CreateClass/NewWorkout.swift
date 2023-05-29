//
//  NewWorkout.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 3/30/23.
//

import SwiftUI

struct NewWorkout: View {
    
    /// Inheriting Class Manager Object
    @EnvironmentObject var manager: DataManager
    
    @AppStorage("dark_mode") var dark = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Workout Category")
                .font(.title.bold())
                .padding([.top, .leading])
            
            Text("Choose your category to select moves")
                .font(.system(size: 17, weight: .light, design: .default))
                .foregroundColor(Color(.lightGray))
                .padding(.top, 9)
                .padding(.leading)
                .padding(.bottom, 5)
            
            ScrollView {
                VStack {}.frame(height: 10)
                ForEach(manager.options.filter({ manager.searchText.isEmpty || $0.title.contains(manager.searchText) })) { c in
                    let index = manager.user?.classes.firstIndex(where: { $0.id == c.id })
                    HStack {
                        
                        Button {
//                            withAnimation {
//                                if let index, manager.selected?.id == c.id {
//                                    manager.editIndex = nil
//                                    manager.user?.classes.remove(at: index)
//                                } else {
//                                    if let index = manager.user?.classes.firstIndex(where: { $0.id == manager.selected?.id }) {
//                                        manager.user?.classes.remove(at: index)
//                                    }
//                                    var c = c
//                                    c.title = "Name Class"
//                                    c.id = UUID().uuidString
//                                    manager.user?.classes.append(c)
//                                    manager.selected = c
//                                }
//                            }
                            
                            withAnimation {
                                if let index, manager.selected?.id == c.id {
                                    manager.editIndex = nil
                                    manager.user?.classes.remove(at: index)
                                } else {
                                    if let index = manager.user?.classes.firstIndex(where: { $0.id == manager.selected?.id }) {
                                        manager.user?.classes.remove(at: index)
                                    }
                                    var c = c
                                    c.title = "Name Class"
                                    manager.user?.classes.append(c)
                                    manager.selected = c
//                                    manager.update(c.id)
                                }
                            }
                            
//                            manager.update(c.id)
                        } label: {
                            VStack {
                                if index != nil, manager.selected?.id == c.id {
                                    Image(systemName: "checkmark")
                                        .font(.title3.bold())
                                }
                                Rectangle()
                                    .frame(height: 1)
                                    .padding(.horizontal)
                            }
                            .frame(width: 100, height: 100)
                            .background(
                                Color(dark ? .secondarySystemBackground : .systemBackground)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.2), radius: 10)
                            )
                            .padding(.leading)
                        }
                        
                        cellButton(c: c, index: index)
                    }
                    .frame(height: 100)
                    .padding(.vertical, 6)
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .zIndex(1)
    }
    
    func cellButton(c: Category, index: Int?) -> some View {
        Button {
            withAnimation {
                if let index, manager.selected?.id == c.id {
                    manager.editIndex = index
                    manager.editWorkouts = true
                } else {
                    if let index = manager.user?.classes.firstIndex(where: { $0.id == manager.selected?.id }) {
                        manager.user?.classes.remove(at: index)
                    }
                    var c = c
                    c.title = "Name Class"
                    manager.user?.classes.append(c)
                    manager.selected = c
//                    manager.update(c.id)
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(c.title)
                        .font(.title2)
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                        .layoutPriority(1)
                    
                    #warning("Text For Description")
//                                    Text(c.description)
//                                        .foregroundColor(Color(.lightGray))
//                                        .font(.callout)
//                                        .padding(.top, 2)
//                                        .minimumScaleFactor(0.8)
//                                        .lineLimit(1)
//                                        .layoutPriority(1)
                }
                .padding(.leading)
                
                Spacer()
                
                Text("\(c.options.count) workouts")
                    .font(.system(size: 14))
                    .lineLimit(1)
                    .padding(.horizontal)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(
                                Color(index != nil && c.id == manager.selected?.id ? .white : .lightGray)
                                    .opacity(index != nil && c.id == manager.selected?.id ? 0.6 : 0.3)
                            )
                    )
                    .padding(.trailing)
            }
            .frame(maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        Color(index != nil && c.id == manager.selected?.id ? .lightGray : .white)
                            .opacity(index != nil && c.id == manager.selected?.id ? 0.3 : 0)
                    )
                    .padding(.trailing, 5)
            )
        }
    }
}

struct NewWorkout_Previews: PreviewProvider {
    static var previews: some View {
        NewWorkout()
            .environmentObject(DataManager())
    }
}
