//
//  ProfileView.swift
//  Fitplay
//
//  Created by Scorpus on 3/23/23.
//

import ColorPickerRing
import Kingfisher
import MusicKit
import SwiftUI

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(DataManager())
    }
}

struct ProfileView: View {
    
    @EnvironmentObject var data: DataManager
    
    @AppStorage("dark_mode") var dark = false
    @AppStorage("accent") var accent = "#007AFF"
    
    @State var chooseColor = false
    
    @State var pickImage = false
    @State var pickImageType: UIImagePickerController.SourceType = .photoLibrary
    
    @State var confirmLogOut = false
        
    var body: some View {
        ZStack {
            let accentColor = Color(hex: accent)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    ProfileDetailsView(pickImage: $pickImage, pickImageType: $pickImageType, accent: $accent)
                    
                    ProfileInfoView(accent: $accent)
                    
                    ProfileStack(chooseColor: $chooseColor, confirmLogOut: $confirmLogOut, dark: $dark, accent: $accent)
                        .padding(.horizontal, 20)
                }
            }
        }
        .fullScreenCover(isPresented: $pickImage) {
            ImagePicker(image: $data.image, type: $pickImageType)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $chooseColor) {
            colorPickerController
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if data.image != nil {
                    Button("Save") {
                        data.update()
                    }
                    .foregroundColor(Color(hex: accent))
                    .font(.body.bold())
                }
            }
        }
        .alert("Log Out Of \(data.user?.name ?? "")", isPresented: $confirmLogOut) {
            Button("Log Out", role: .destructive) {
                data.logOut()
            }
        }
    }
    
    enum CellSize: CGFloat {
        case small = 75
        case large = 175
    }
    
    /// A ColorPickerRing view to be displayed as a full-screen controller. This changes the accent color.
    var colorPickerController: some View {
        NavigationView {
            ColorPickerRing(
                color: Binding {
                    UIColor(Color(hex: accent))
                } set: { v in accent = v.toHexString() },
                strokeWidth: 30
            )
            .frame(width: width * 0.8, height: width * 0.8)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Personalize")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        withAnimation { accent = "#007AFF" }
                    }
                    .foregroundColor(Color(hex: accent))
                    .font(.body.bold())
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        chooseColor.toggle()
                    }
                    .foregroundColor(Color(hex: accent))
                    .font(.body.bold())
                }
            }
        }
    }
}

/// A View containing the profile photo and name
struct ProfileDetailsView: View {
    @Binding var pickImage: Bool
    @Binding var pickImageType: UIImagePickerController.SourceType
    @FocusState var focused
    @Binding var accent: String
    
    @EnvironmentObject var data: DataManager
    
    @State private var accentColor: Color = .blue
    
    var body: some View {
        VStack {
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
                ZStack {
                    if let image = data.image {
                        Image(uiImage: image)
                            .resizable()
                    } else {
                        AsyncImage(url: data.user?.image, scale: 1) { image in
                            image
                                .resizable()
                        } placeholder: {
                            Image("defaultProfile")
                                .resizable()
                        }
                        
                        /*KFImage(data.user?.image ?? DataManager.image)
                         .resizable()*/
                    }
                    Circle()
                        .stroke(.white, lineWidth: 10)
                }
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
                
                
            }
            .scaledToFill()
            .frame(width: 170, height: 170)
            
            HStack {
                Spacer()
                
                Button {
                    if data.setNewName {
                        data.saveName()
                        focused = false
                        withAnimation { data.setNewName = false }
                    } else {
                        withAnimation { data.setNewName = true }
                        focused = true
                    }
                } label: {
                    Image(systemName: data.setNewName ? "checkmark" : "square.and.pencil")
                        .font(.system(size: 18, weight: .bold))
                        .padding(10)
                        .foregroundColor(.white)
                        .background {
                            LinearGradient(colors: [accentColor.lighter(by: 4), accentColor.darker(by: 4)], startPoint: .top, endPoint: .bottom)
                        }
                        .clipShape(Circle())
                        .shadow(color: accentColor.opacity(0.5), radius: 7, x: 3, y: 3)
                }
            }
            .frame(width: 300)
            .padding(.top, -30)
            
            Group {
                if data.setNewName {
                    TextField("Full Name", text: $data.newName, onCommit: {
                        data.saveName()
                        focused = false
                        withAnimation { data.setNewName = false }
                    })
                    .multilineTextAlignment(.center)
                    .focused($focused)
                    .padding(.vertical, 10)
                    .padding(.bottom, 7)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                focused = false
                            }
                            .font(.body.bold())
                        }
                    }
                    .background(focused ? Color.clear : Color.secondary.opacity(0.2))
                    .transition(.opacity.animation(.easeOut(duration: 0.3)))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                } else {
                    Text(data.user?.name ?? "Samuel Vulakh")
                }
            }
            .onAppear { data.newName = data.user?.name ?? "Samuel Vulakh" }
            .font(.system(size: 35, weight: .bold))
            .padding(.horizontal)
            
        }
        .onChange(of: accent, perform: { newValue in
            accentColor = Color(hex: accent)
        })
        .onAppear {
            accentColor = Color(hex: accent)
        }
    }
}

/// A View containing profile information like classes created, classes shared, and membership type
struct ProfileInfoView: View {
    @Binding var accent: String
    
    @EnvironmentObject var data: DataManager
    
    @State private var accentColor: Color = .blue
    
    var body: some View {
        VStack {
            Divider()
                .background(Color.primary.opacity(0.3))
                .padding(.horizontal, 30)
            
            HStack {
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Classes Created")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.primary.opacity(0.4))
                    
                    Text("\(data.user?.classes.count ?? 0)")
                        .foregroundColor(accentColor)
                        .padding(.top, 3)
                }
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Classes Shared")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.primary.opacity(0.4))
                    
                    Text("\(data.user?.shared ?? 0)")
                        .foregroundColor(accentColor)
                        .padding(.top, 3)
                }
                
                Spacer()
                
                VStack(spacing: 0) {
                    Text("Type")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.primary.opacity(0.4))
                    
                    Text((data.user?.status ?? .basic).rawValue)
                        .foregroundColor(accentColor)
                        .padding(.top, 3)
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            
            Divider()
                .background(Color.primary.opacity(0.3))
                .padding(.horizontal, 30)
        }
        .onChange(of: accent, perform: { newValue in
            accentColor = Color(hex: accent)
        })
        .onAppear {
            accentColor = Color(hex: accent)
        }
    }
}

/// A cell View for ``ProfileView`` settings. You can provide your own content to add to the cell
struct ProfileCell<Content: View>: View {
    var image: String = ""
    var customImage: String = ""
    var title: String = ""
    var size: ProfileCellSize = .small
    var dark: Bool = false
    let content: Content
    
    init(
        image: String = "",
        customImage: String = "",
        title: String = "",
        size: ProfileCellSize = .small,
        dark: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.image = image
        self.customImage = customImage
        self.title = title
        self.size = size
        self.dark = dark
        self.content = content()
    }
    
    var body: some View {
        HStack(spacing: 15) {
            if size == .small {
                if !image.isEmpty {
                    Image(systemName: image)
                } else if !customImage.isEmpty {
                    Image(customImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .background(customImage == "SpotifyLogo" ? Color.black.clipShape(Circle()) : Color.clear.clipShape(Circle()))
                }
                
                Text(title)
                    .font(.system(size: 20))
                    
                
                Spacer()
            }
            
            content
        }
        .padding(.horizontal, size == .small ? 20 : 0)
        .frame(height: size.rawValue)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(dark ? Color(.secondarySystemBackground) : .white)
                .shadow(color: .primary.opacity(dark ? 0 : 0.06), radius: 15, x: size == .small ? 5 : 10, y: 10)
                .shadow(color: .primary.opacity(dark ? 0 : 0.03), radius: 5, x: size == .small ? -5 : -10, y: -10)
        )
    }
}


enum ProfileCellSize: CGFloat {
    case small = 75
    case large = 175
}

/// A LazyVStack containing all of the settings ``ProfileCell`` for a profile
fileprivate struct ProfileStack: View {
    @EnvironmentObject var data: DataManager
    @Binding var chooseColor: Bool
    @Binding var confirmLogOut: Bool
    @Binding var dark: Bool
    @Binding var accent: String
    
    @State private var accentColor: Color = .blue
    
    var body: some View {
        LazyVStack(spacing: 17) {
            let accentColor = Color(hex: accent)
            
            personalizeView
            fontsCell
            darkModeCell
            notificationsCell
            
            
            if data.user?.spotifyAccessToken == nil && MusicAuthorization.currentStatus != .authorized {
                connectMusicCell
            } else {
                if data.user?.spotifyAccessToken != nil {
                    spotifyCell
                }
                
                if MusicAuthorization.currentStatus == .authorized {
                    appleMusicCell
                }
            }
            
            VStack {
                Text("More")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 22, weight: .semibold, design: .default))
                    .padding(.horizontal, 24)
                moreCell
            }
            .padding(.top, 12)
            
            logOutCell
            
            
        }
        .padding(.vertical, 20)
        .onAppear {
            accentColor = Color(hex: accent)
        }
        .onChange(of: accent) { newValue in
            accentColor = Color(hex: newValue)
        }
    }
    
    var personalizeView: some View {
        Button {
            withAnimation { chooseColor = true }
        } label: {
            ProfileCell(image: "paintpalette", title: "Personalize") {
                Group {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 23, height: 23)
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(dark ? .white : .secondary)
                        .font(.system(size: 10, weight: .semibold))
                }
            }
            .foregroundColor(.primary)
        }
    }
    
    var fontsCell: some View {
        Button {
            
        } label: {
            ProfileCell(image: "textformat.abc.dottedunderline", title: "Fonts") {
                Image(systemName: "chevron.right")
                    .foregroundColor(dark ? .white : accentColor)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundColor(.primary)
        }
    }
    
    var darkModeCell: some View {
        ProfileCell(image: "moon", title: "Dark Mode") {
            Toggle("", isOn: $dark)
                .tint(accentColor)
        }
    }
    
    var notificationsCell: some View {
        ProfileCell(image: "bell", title: "Notifications") {
            
            Toggle(
                "",
                isOn: Binding { false } set: { _ in
                    if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            )
            .tint(accentColor)
        }
    }
    
    var connectMusicCell: some View {
        ProfileCell(size: .large) {
            VStack {
                HStack {
                    
                    ZStack {
                        Image("SpotifyLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(.black))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .zIndex(1)
                        
                        Image("AppleMusicLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .zIndex(0)
                    }
                    .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Music Integration")
                            .font(.title3.bold())
                        
                        Text("Connect your Apple Music or Spotify account to FitPlay to improve your overall experience")
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.4))
                    }
                    .padding(.top)
                }
                .padding(.top)
                
                Spacer()
                
                HStack {
                    
                    Spacer(minLength: 0)
                    
                    Button {
                        let spotifyController = SpotifyController()
                        spotifyController.logInCompletion = { token in
                            data.user?.spotifyAccessToken = token
                            data.update()
                            print("token: \(token)")
                        }
                        spotifyController.spotifyAuthVC()
                    } label: {
                        Text("Connect Spotify")
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(hex: "#1ED760"))
                            )
                    }
                    
                    Button {
                        let appleMusicController = AppleMusicController()
                        Task {
                            await appleMusicController.requestMusicAuthorization()
                        }
                    } label: {
                        Text("Connect Apple Music")
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .frame(height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(hex: "#FD5163"))
                            )
                    }
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 20)
        }
    }
    
    var spotifyCell: some View {
        ProfileCell(customImage: "SpotifyLogo", title: "Spotify") {
            Toggle(
                "",
                isOn: Binding { true } set: { _ in
                    data.user?.spotifyAccessToken = nil
                    data.update()
                }
            )
            .tint(accentColor)
        }
    }
    
    var appleMusicCell: some View {
        ProfileCell(customImage: "AppleMusicLogo", title: "Apple Music") {
            Toggle(
                "",
                isOn: Binding { true } set: { _ in
                    if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            )
            .tint(accentColor)
        }
    }
    
    var moreCell: some View {
        ProfileCell(size: .large) {
            VStack {
                HStack(spacing: 15) {
                    Text("Behaviour Tracking")
                        .font(.system(size: 20))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(dark ? .white : Color(hex: "#000066"))
                        .font(.system(size: 10, weight: .semibold))
                }
                .padding(.horizontal, 24)
                .frame(height: 40)
                
                Divider()
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    Text("Help")
                        .font(.system(size: 20))
                    
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(dark ? .white : Color(hex: "#000066"))
                        .font(.system(size: 10, weight: .semibold))
                }
                .padding(.horizontal, 24)
                .frame(height: 40)
                
                Divider()
                    .padding(.horizontal)
                
                HStack(spacing: 15) {
                    Text("Feedback")
                        .font(.system(size: 20))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(dark ? .white : Color(hex: "#000066"))
                        .font(.system(size: 10, weight: .semibold))
                }
                .padding(.horizontal, 24)
                .frame(height: 40)
            }
        }
    }
    
    var logOutCell: some View {
        Group {
            Button {
                withAnimation { confirmLogOut.toggle() }
            } label: {
                ProfileCell(image: "", title: "Log Out") {
                    Image(systemName: "chevron.right")
                        .foregroundColor(dark ? .white : Color(hex: "#000066"))
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(.red)
            }
        }
        .padding(.top, 30)
    }
}
