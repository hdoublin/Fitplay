//
//  CustomAlert.swift
//  The Coach
//
//  Created by Samuel Vulakh on 4/10/23.
//

import SwiftUI

/// Custom Alert View
struct CustomAlert: View {

    /// Error Handle
    @Binding var handle: Handle
    
    /// Timer That Is Updated Every Second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    /// Time That Alert Is Displayed For
    @State var time: Int = 2
    
    /// Checks If Alert Is For Error Or Notification
    var isErr: Bool {
        switch handle.value {
        case .err(_):
            return true
        case .notification(_):
            return false
        case .none:
            return false
        }
    }
    
    init(_ handle: Binding<Handle>) {
        self._handle = handle
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Displaying Alert At Bottom Of Screen
            Spacer()
            
            HStack {
                
                // If Alert Is An Error, Display Exclamation Mark
                if isErr {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 25))
                }
                
                // Displaying Error Description
                Text(handle.value?.errorDescription ?? "")
            }
            .frame(width: 315, alignment: .leading)
            .padding()
            .font(.system(size: 15))
            .foregroundColor(.white)
            .background(isErr ? Color.red : Color.accentColor)
            .cornerRadius(10)
            .padding(.bottom, handle.value == nil ? 0 : 30)
            .opacity(handle.value == nil ? 0 : 1)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 5, y: 5)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: -5, y: -5)
            .animation(.spring(), value: handle.value)
        }
        .zIndex(999)
        // Descreasing Time Remaining When Timer Value Changes
        .onReceive(timer) { _ in
            if time > 0 {
                time -= 1
            } else {
                time = 2
                withAnimation { handle.value = nil }
            }
        }
    }
}


/// Error Handle
struct Handle {
    
    /// Value Of Error Handle
    var value: ErrorHandle?
    
    /// General Loading
    var loading: Bool = false
}

/// Error Handle Value
enum ErrorHandle: Error, Equatable {
    
    /// Error For Display
    case err(_ description: String)
    
    /// Notification For Display
    case notification(_ description: String)
}

/// Localized Description For Error
extension ErrorHandle: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .err(let value):
            return value
        case .notification(let value):
            return value
        }
    }
}
