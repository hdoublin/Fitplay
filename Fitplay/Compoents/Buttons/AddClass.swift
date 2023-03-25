//
//  AddClass.swift
//  Fitplay
//
//  Created by Scorpus on 3/24/23.
//

import SwiftUI

struct AddClass: View {
    var body: some View {
        ZStack{
                Circle() .fill(Color(hex: "#4275DC"))
                    .frame(width: 64.22, height: 64.22)
                    .shadow(color: .black, radius: 0, x: 0, y: 1)
            
            Image(systemName: "plus.app.fill").foregroundColor(.white)
                .font(.system(size: 25))
                .scaledToFit()

        }
    }
}

struct AddClass_Previews: PreviewProvider {
    static var previews: some View {
        AddClass()
    }
}
