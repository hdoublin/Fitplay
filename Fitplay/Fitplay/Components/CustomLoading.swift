//
//  CustomLoading.swift
//  The Coach
//
//  Created by Samuel Vulakh on 4/10/23.
//

import ActivityIndicatorView
import SwiftUI

struct CustomLoading: View {
    
    /// Error Handle
    @Binding var handle: Handle
    
    // Initialization
    init(_ handle: Binding<Handle>) {
        self._handle = handle
    }
    
    var body: some View {
        Group {
            if handle.loading {
                ZStack {
                    
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .opacity(0.7)
                    
                    ActivityIndicatorView(isVisible: .constant(true), type: .gradient([.white, .accentColor], lineWidth: 5))
                        .frame(width: 30, height: 30)
                        .padding(12)
                }
                .zIndex(998)
            }
        }
        .transition(.opacity.animation(.easeInOut))
    }
}
