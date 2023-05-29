//
//  ClassDetailsEditView.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import Kingfisher
import SwiftUI

struct ClassDetailsEditView: View {
    
    /// Inheriting Class Manage Object
    @EnvironmentObject var classes: DataManager
    
    /// Index Of Currently Editing Class (Non Optional)
    let index: Int
        
    /// Dismisses View
    @Environment(\.dismiss) var dismiss
    
    @State var pickImage = false
    @State var pickImageType: UIImagePickerController.SourceType = .photoLibrary
    
    @State var selection = 2
    
    @State var editText = false
    
    @Binding var edit: Bool
    
    @State var oldDate = ""
    
    init(index: Int, edit: Binding<Bool>) {
        self.index = index
        self._edit = edit
        
        UITextView.appearance().backgroundColor = .clear
    }
    
    @FocusState var focused
    
    @AppStorage("dark_mode") var dark = false
    @AppStorage("accent") var accent = "#007AFF"
    
    var totalEquipmentCount: String {
        (classes.user?.classes[index].workouts.filter { !$0.equipment.isEmpty }.map(\.equipmentCount).map { Int($0) ?? 0 } ?? []).reduce(0, +).description
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    VStack {
                        Color(hex: "#404040")
                            .frame(height: height * 0.8)
                        
                        Spacer()
                    }
                    .ignoresSafeArea()
                    
                    if let image = classes.user?.classes[index].image {
                        KFImage(image)
                            .resizable()
                    } else if let image = classes.image {
                        Image(uiImage: image)
                            .resizable()
                    } else {
                        Text("You have not added a photo for your class. To do that press the image button")
                            .foregroundColor(.white)
                            .padding(.horizontal, 50)
                            .font(Fonts.footnote)
                            .padding(.top, 50)
                    }
                }
                .frame(height: height * 0.3)
                .cornerRadius(50, corners: .bottomLeft)
                .background(dark ? Color(.secondarySystemBackground) : Color(hex: "#F0F0F0"))
                .overlay(alignment: .top) {
                    HStack {
                        Button {
                            classes.update(classes.user?.classes[index].id ?? "")
                            
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 40, height: 40)
                                .background(.white.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))

                        }

                        Spacer()
                        
                        Menu {
                            Button {
                                pickImageType = .camera
                                pickImage.toggle()
                            } label: {
                                Label("Camera", systemImage: "camera")
                            }
                            
                            Button {
                                pickImageType = .photoLibrary
                                pickImage.toggle()
                            } label: {
                                Label("Library", systemImage: "photo")
                            }
                        } label: {
                            Image(systemName: "photo")
                                .padding(12)
                                .frame(width: 40, height: 40)
                                .background(.white.opacity(0.3), in: Circle())
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top, 50)
                }
                
                VStack(spacing: 0) {
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            TextField("MM/DD/YYYY", text: Binding {
                                classes.user?.classes[index].dateText ?? ""
                            } set: { v in
                                classes.user?.classes[index].dateText = v
                            })
                                .keyboardType(.numberPad)
                                .frame(width: 120)
                                .onChange(of: classes.user?.classes[index].dateText) { newValue in
                                    let v = newValue ?? ""
                                    if (v.count == 2 || v.count == 5) && v > oldDate {
                                        classes.user?.classes[index].dateText.append("/")
                                    }
                                    oldDate = newValue ?? ""
                                }
                                .font(.system(size: 13, weight: .regular, design: .default))
                                .padding(.top, 15)
                                .padding(.leading, 8)

                            Capsule()
                                .frame(width: 90, height: 5)
                        }
                        
                        if focused {
                            Button {
                                focused = false
                            } label: {
                                Text("Done")
                                    .font(.body.bold())
                            }
                        }
                    }
                    .padding([.top, .leading])
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .focused($focused)
                    
                    if !focused {
                        HStack(alignment: .top) {
                            if editText {
                                
                                TextField(text: Binding {
                                    return classes.user?.classes[index].title ?? "Name Class"
                                } set: { v in
                                    classes.user?.classes[index].title = v
                                }, prompt: Text("Name Class"), label: {
                                    
                                })
                                    .font(.system(size: 30, weight: .bold, design: .default))
                                    .frame(width: 230)
                                    .focused($focused)
                            } else {
                                Text((classes.user?.classes[index].title.isEmpty == true ? "Create A Name" : classes.user?.classes[index].title) ?? "")
                                    .font(.system(size: 30, weight: .bold, design: .default))
                            }
                            
                            Button {
                                withAnimation { editText.toggle() }
                            } label: {
                                Image(systemName: "pencil")
                                    .imageScale(.large)
                                    .foregroundColor(Color(hex: "#D98B4B"))
                            }
                        }
                        .padding(.top)

                        HStack {
                            Group {
                                Spacer()
                                Text(totalEquipmentCount)
                                    .foregroundColor(Color(hex: accent))
                                    .bold()
                                Text("Equipments")
                                Spacer()
                            }
                            
                            Group {
                                Spacer()
                                Text(classes.user?.classes[index].workouts.count.description ?? "0")
                                    .foregroundColor(Color(hex: accent))
                                    .bold()
                                Text("Moves")
                                Spacer()
                            }
                            
                            Group {
                                Spacer()
                                let dur = classes.user?.classes[index].duration
                                Text(dur == 0 ? "0:00" : dur?.asString(style: .positional) ?? "0:00")
                                    .foregroundColor(Color(hex: accent))
                                    .bold()
                                Text("Min")
                                Spacer()
                            }
                        }
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .frame(width: width * 0.9, height: 55)
                        .background(Color(hex: "#535353").opacity(0.4), in: RoundedRectangle(cornerRadius: 15))
                        .padding(.top)
                        
                        HStack {
                            Spacer()
                            Button {
                                withAnimation { selection = 2 }
                            } label: {
                                Text("Moves")
                                    .opacity(selection == 2 ? 1 : 0.4)
                            }
                            Spacer()
                            Button {
                                withAnimation { selection = 0 }
                            } label: {
                                Text("Equipment")
                                    .opacity(selection == 0 ? 1 : 0.4)
                            }
                            Spacer()
                            Button {
                                withAnimation { selection = 1 }
                            } label: {
                                Text("Notes")
                                    .opacity(selection == 1 ? 1 : 0.4)
                            }
                            Spacer()
                        }
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                        .padding(.top)
                    }
                    
                    let c = (classes.user?.classes[index].workouts ?? []).filter { !$0.equipment.isEmpty }
                    
                    TabView(selection: $selection) {
                        ScrollView(showsIndicators: false) {
                            VStack {
                                ForEach(Array(zip(c.indices, c)), id: \.0) { index, workout in
                                    Swipe(
                                        workout: workout,
                                        array: Binding {
                                            classes.user?.classes[self.index].workouts ?? []
                                        } set: { v in
                                            classes.user?.classes[self.index].workouts = v
                                        } ,
                                        index: index,
                                        type: .equipment,
                                        title: classes.user?.classes[self.index].title ?? "",
                                        focused: $focused
                                    )
                                    .environmentObject(classes)
                                    
                                }
                                
                                Button {
                                    classes.editIndex = index
                                    classes.editWorkouts.toggle()
                                } label: {
                                    Text("Add More")
                                        .foregroundColor(.white)
                                        .font(.system(size: 13))
                                        .padding(.horizontal, 30)
                                        .padding(.vertical, 10)
                                        .background(Capsule().fill(Color(hex: accent)))
                                        .padding(.top)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                        .tag(0)
                        
                        VStack {
                            ZStack {
                                
                                if classes.user?.classes[index].description.isEmpty == true {
                                    TextEditor(text: .constant("Ready to take your class to the next level? Create a note for your upcoming workout and be prepared to deliver a killer session! Use our note-taking feature to plan your routine, record modifications, and keep track of time."))
//                                        .font(.system(size: 12, weight: .light))
                                        .foregroundColor(.gray)
                                        .disabled(true)
                                        .padding()
                                }
                                
                                if #available(iOS 16.0, *) {
                                    TextEditor(
                                        text:
                                            Binding {
                                                classes.user?.classes[index].description ?? ""
                                            } set: { v in
                                                classes.user?.classes[index].description = v
                                            }
                                    )
                                    
                                    .padding()
                                    .scrollContentBackground(.hidden)
                                    .focused($focused)
                                } else {
                                    TextEditor(
                                        text:
                                            Binding {
                                                classes.user?.classes[index].description ?? ""
                                            } set: { v in
                                                classes.user?.classes[index].description = v
                                            }
                                    )
//                                    .frame(minHeight: 100)
//                                    .fixedSize(horizontal: false, vertical: true)
                                    .focused($focused)
//                                    .font(.system(size: 12, weight: .light))
                                    .padding()
                                }
                            }
                            .frame(minHeight: 100, maxHeight: 200)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(size: 12, weight: .light))
                            .background(Color(.systemBackground))
                            .padding()
                            
                            Button {
                                classes.update(classes.user?.classes[index].id ?? "")
                            } label: {
                                Text("Save Notes")
                                    .foregroundColor(.white)
                                    .font(.system(size: 12))
                                    .padding(.horizontal)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color(hex: accent)))
                                    .padding(.top)
                            }
                            
                            Spacer()
                        }
                        .tag(1)
                        
                        ScrollView(showsIndicators: false) {
                            
                            let c = (classes.user?.classes[index].workouts ?? [])
                            
                            VStack { }.frame(height: 10)
                            ForEach(Array(zip(c.indices, c)), id: \.0) { index, workout in
                                Swipe(
                                    workout: workout,
                                    array: Binding {
                                        classes.user?.classes[self.index].workouts ?? []
                                    } set: { v in
                                        classes.user?.classes[self.index].workouts = v
                                    },
                                    index: index,
                                    type: .workout,
                                    title: classes.user?.classes[self.index].title ?? "",
                                    focused: $focused
                                )
                                .environmentObject(classes)
                            }
                            Button {
                                classes.editIndex = index
                                classes.editWorkouts.toggle()
                            } label: {
                                Text("Add More")
                                    .foregroundColor(.white)
                                    .font(.system(size: 13))
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(Color(hex: accent)))
                                    .padding(.top)
                            }
                            VStack { }.frame(height: 10)
                        }
                        .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.spring(), value: selection)
                    .padding(.top, 5)
                }
                .frame(width: width)
                .background((dark ? Color(.secondarySystemBackground) : Color(hex: "#F0F0F0")))
                .cornerRadius(50, corners: .topRight)
                .background(
                    Group {
                        if
                            let index = classes.editIndex,
                            let image = classes.user?.classes[index].image {
                            KFImage(image)
                                .resizable()
                                .rotationEffect(.init(degrees: 180))
                        } else if let image = classes.image {
                            Image(uiImage: image)
                                .resizable()
                                .rotationEffect(.init(degrees: 180))
                        } else {
                            Color(hex: "#404040")
                        }
                    }
                )
                .cornerRadius(50, corners: .bottomLeft)
                .overlay(
                    Button {
                        classes.update(classes.user?.classes[index].id ?? "")
                    } label: {
                        VStack {
                            Image(systemName: "square.and.arrow.down.fill")
                                .padding(9)
                                .background(Circle().fill(Color(hex: "#D98B4B")))
                            
                            Text("Save")
                                .font(.system(size: 12))
                        }
                    }
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                        .background(Color(.systemBackground))
                        .cornerRadius(50, corners: [.topLeft])
                    , alignment: .bottomTrailing)
                
                Bottom(editing: true)
                    .environmentObject(classes)
                    .background(classes.isPlaying ? Color(.systemBackground) : dark ? Color(.secondarySystemBackground) : Color(hex: "#F0F0F0"))
                    .onTapGesture {
                        withAnimation { edit.toggle() }
                    }
            }
            .ignoresSafeArea()
//            .navigationBarHidden(true)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focused = false
                    }
                    .font(.body.bold())
                }
            }
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $pickImage) {
            ImagePicker(image: $classes.image, type: $pickImageType)
                .ignoresSafeArea()
        }
        .onChange(of: pickImageType) { _ in
            pickImage.toggle()
        }
        .sheet(isPresented: $classes.editWorkouts) {
            NavigationView {
                EditCategory(edit: .constant(false), display: false)
                    .environmentObject(classes)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
//                                classes.editIndex = nil
                                classes.editWorkouts.toggle()
                            } label: {
                                Text("Done")
                                    .bold()
                            }
                        }
                    }
            }
            .accentColor(.primary)
        }
    }
}

struct Swipe: View {
    
    @EnvironmentObject var data: DataManager
    
    init(
        workout: Category.Workout,
        array: Binding<[Category.Workout]>,
        index: Int,
        type: SwipeType,
        title: String,
        focused: FocusState<Bool>.Binding
    ) {
        self._array = array
        self.index = index
        self.workout = workout
        self.type = type
        self.title = title
        self.focused = focused
    }
    
    /// Array Of All Elements
    @Binding var array: [Category.Workout]
    
    /// Index Of The Element
    let index: Int
    
    /// The Selected Element
    let workout: Category.Workout
    
    /// Type Of Swipe Object
    let type: SwipeType
    
    /// Swipe Box Title
    let title: String
    
    @GestureState var isDragging = false
    
    var focused: FocusState<Bool>.Binding
    
    @State var oldDur = ""
    
    var body: some View {
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
            
            HStack {
//                Text("\(title):")
//                    .font(.system(size: 20, weight: .regular))
//                Spacer()
                
                switch type {
                case .equipment:
                    Text(workout.equipment)
                        .font(.system(size: 20, weight: .semibold))
                case .workout:
                    Text(workout.exercise)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                Spacer()
                
                if focused.wrappedValue == true {
                    Button {
                        focused.wrappedValue = false
                    } label: {
                        Text("Done")
                            .font(.body.bold())
                    }
                    .padding(.trailing)
                }
                
                Group {
                    switch type {
                    case .equipment:
                        TextField(
                            "0",
                            text:
                                Binding {
                                    return workout.equipmentCount
                                } set: { value in
                                    array[index].equipmentCount = value
                                }
                        )
                        .focused(focused)
                    case .workout:
                        TextField(
                            "0:00",
                            text:
                                Binding {
                                    return workout.duration
                                } set: { value in
                                    array[index].duration = value
                                }
                        )
                        .focused(focused)
                        .onAppear { print(workout); oldDur = workout.duration }
                        .onChange(of: workout.duration) { v in
                            if v.count > oldDur.count && v.count == 3 {
                                array[index].duration.insert(":", at: array[index].duration.index(array[index].duration.startIndex, offsetBy: 1))
                            }
                            
                            if v.count == 3 && v.count < oldDur.count {
                                array[index].duration.remove(at: array[index].duration.index(array[index].duration.startIndex, offsetBy: 1))
                            }
                            
                            if v.count > 4 && v.count > oldDur.count {
                                array[index].duration.removeLast()
                            }
                            
                            oldDur = v
                        }
                    }
                }
                .keyboardType(.numberPad)
                .fixedSize()
                .font(.system(size: 22))
                .foregroundColor(Color(hex: "#707070"))
                .padding(9)
                .background(Rectangle().stroke(Color(hex: "#707070")))
                .padding(.trailing)
            }
            .padding(.horizontal)
            .frame(height: 75)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 10))
            .offset(x: workout.offset)
            .gesture(
                DragGesture()
                    .updating($isDragging) { value, state, _ in
                        state = true
                        onChanged(value: value, index: index)
                    }.onEnded { (value) in
                        onEnd(value: value, index: index)
                    }
            )
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    func remove(at index: Int) {
        withAnimation { array.remove(at: index) }
        data.update(data.user?.classes[index].id ?? "")
    }
    
    func onChanged(value: DragGesture.Value, index: Int){
        
        if value.translation.width < 0 && isDragging {
            
            array[index].offset = value.translation.width
        }
    }
    
    func onEnd(value: DragGesture.Value,index: Int) {
        withAnimation {
            if -value.translation.width >= 50 {
                array[index].offset = -65
            } else {
                array[index].offset = 0
            }
        }
    }
    
    enum SwipeType {
        case equipment
        case workout
    }
}

struct ClassDetails_Previews: PreviewProvider {
    static var previews: some View {
        ClassDetailsEditView(index: 0, edit: .constant(true))
            .environmentObject(DataManager())
    }
}
