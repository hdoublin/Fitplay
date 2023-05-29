//
//  HomeView.swift
//  Fitplay
//
//  Created by Scorpus on 3/22/23.
//

import Kingfisher
import SwiftUI

struct HomeView: View {
    @State var isOpenChat:Bool = false
    @State var isUpcoming:Bool = true
    @State var isCalenderSelected:Bool = false
    @State private var dateSelected: Date = Date()
    @State private var selectedDates: [Date] = [Calendar.current.date(byAdding: .day, value: 3, to: Date())!,Calendar.current.date(byAdding: .day, value: 7, to: Date())!,Calendar.current.date(byAdding: .day, value: -5, to: Date())!]
    @Environment(\.verticalSizeClass) var size
    
    @EnvironmentObject var data: DataManager
    
    @AppStorage("accent") var accent = "#007AFF"
    
    /// Is The User Searching Through Classes (Expands Search Bar)
    @State var searching = false
    
    @FocusState var focused
    
    var body: some View {
        ZStack {
            VStack {
                
                if !data.add {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hello,")
                            .padding(.leading,20)
                            .foregroundColor(.primary.opacity(0.5))
                            .font(.system(size: 25, weight: .bold))
                        Text(data.user?.name ?? "Samuel Vulakh")
                            .padding(.leading,40)
                            .foregroundColor(.primary.opacity(0.5))
                            .font(.system(size: 25, weight: .bold))
                        
                        Spacer()
                    }
                    .padding(.top)
                    .frame(maxWidth: .infinity, maxHeight: height * 0.2, alignment: .leading)
                }
                
                if data.isCalendar {
                    
                    VStack(spacing: 0) {
                        ZStack {
                            Color(.systemBackground)
                                .cornerRadius(40, corners: [.bottomLeft])
                                .background(Color(.lightGray).opacity(0.4))
                                .frame(height: 40)
                            if isUpcoming {
                                Text("Upcoming Classes")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .font(.custom(size: 20,weight: .regular))
                                    .foregroundColor(.black.opacity(0.6))
                                    .padding(.leading)
                                    .padding(.bottom, 12)
                                    .padding(.leading, 12)
                            }

                        }
                        ZStack {
                            Color(.lightGray).opacity(0.4)
                                .cornerRadius(40, corners: [.topRight, .bottomLeft])
                            VStack {
                                if isUpcoming {
                                    VStack(alignment: .leading) {

                                        ForEach([0],id: \.self) { id in
                                            HStack(spacing: 20){
                                                Image(systemName: "figure.yoga")
                                                Text("Upcoming Classes")
                                                Text("08h30 - 09h00")
                                            }
                                            .font(.custom(size: 18,weight: .regular))
                                            .foregroundColor(Color(hex: "#0065FF"))
                                            .padding(10)
                                            .frame(height:50)
                                            .background(Color(hex: "#ECF2FE"))
                                            .cornerRadius(10, corners: .allCorners)
                                            .frame(maxWidth: .infinity)
                                        }
                                    }
                                    .padding(.top)
                                    
                                    SelectableCalendarView(monthToDisplay: Date(), dateSelected: $dateSelected, selectedDates: $selectedDates)
                                        .padding()
                                        .padding()
                                } else {
                                    Divider()
                                    Text("No upcoming class(es) let’s create one now Click the blue button below.")
                                        .font(Fonts.description)
                                        .foregroundColor(.black.opacity(0.6))
                                        .padding(.top)
                                        .padding(.horizontal)
                                }
                                
                                
                                Spacer()
                            }
                            
                        }
                        
                    }
                    .padding(.top, -70)
                } else {
                    ClassesView()
                        .environmentObject(data)
                }
           
            }
            .safeAreaInset(edge: .top) {
                VStack {
                    
                    Image("LogoName")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 20)
                    
                    HStack {
                        
                        if !searching {
                            if data.editWorkouts || data.add {
                                Button {
                                    if data.editWorkouts {
                                        withAnimation { data.editWorkouts = false }
                                    } else if data.add {
                                        data.editIndex = nil
                                        data.selected = nil
                                        print("Going Home")
                                        withAnimation { data.add = false }
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 25, weight: .regular, design: .default))
                                        .padding()
                                        .background(Color(.systemBackground))
                                }
                            } else {
                                NavigationLink {
                                    ProfileView()
                                        .environmentObject(data)
                                } label: {
                                    KFImage(data.user?.image ?? DataManager.image)
                                        .resizable()
                                        .clipShape(Circle())
                                        .scaledToFit()
                                        .overlay(Circle().stroke(Color(hex: accent), lineWidth: 3))
                                        .frame(width: 50, height: 50)
                                }
                                .padding(.leading)
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            Button {
                                withAnimation { searching.toggle() }
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 20, weight: .regular, design: .default))
                            }
                            
                            if searching {
                                TextField(data.editWorkouts ? "What move are you searching for?" : "Search workout category or moves", text: $data.searchText)
                                    .padding(.leading, 6)
                                    .focused($focused)
                                    .toolbar {
                                        ToolbarItem(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                focused = false
                                            }
                                            .font(.body.bold())
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                        .padding(.leading)
                    }
                    .padding(.trailing)
                }
            }

            if !data.isPlaying && !data.add {
                CustomMenu()
                    .environmentObject(data)
                    .frame(height:120)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea()
            }
        }
        .accentColor(.primary)
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(DataManager())
    }
}

//                    HStack{
//                        NavigationLink {
//                            // ChatsView()
//                        } label: {
//                            Image(systemName: "bell.badge")
//                                .foregroundColor(.black)
//                                .frame(width: 40,height: 40)
//                                .background(Color(hex: "#F0F0F0"))
//                                .cornerRadius(10, corners: .allCorners)
//
//                        }
//
//                        Spacer()
//                        Text("Tuesday, 29 February")
//                            .font(.custom(size: 20,weight: .semibold))
//                        Spacer()
//
//                        NavigationLink {
//                            ProfileView()
//                                .environmentObject(data)
//                        } label: {
//                            KFImage(data.user?.image ?? DataManager.image)
//                                .resizable()
//                                .clipShape(Circle())
//                                .scaledToFit()
//                                .overlay(Circle().stroke(Color(hex: "#404FD8"), lineWidth: 3))
//                                .frame(width: 50, height: 50)
//                                .onAppear { print(data.user?.image) }
//                        }
//                    }
//                    Spacer()
//                        .frame(height: 10)
//                    Text("Hello,")
//                        .padding(.leading,20)
//                        .foregroundColor(.black.opacity(0.5))
//                        .font(.custom(size: 25,weight: .bold))
//                    Text(data.user?.name ?? "")
//                        .padding(.leading,40)
//                        .foregroundColor(.black.opacity(0.5))
//                        .font(.custom(size: 25,weight: .bold))
//                    Spacer()
//                        .frame(height:70)
//
//
//    SelectableCalendarView(monthToDisplay: Date(), dateSelected: $dateSelected, selectedDates: $selectedDates)
//        .padding()
//        .background(Color(hex: "#F4F4F4").cornerRadius(10))
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(
//            Color.black.opacity(0.4)
//                .ignoresSafeArea()
//                .onTapGesture {
//                    withAnimation { isCalenderSelected.toggle() }
//                }
//        )
