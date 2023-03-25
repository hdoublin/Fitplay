//
//  SaveClasses.swift
//  Fitplay
//
//  Created by Scorpus on 3/24/23.
//

import SwiftUI

struct SaveClasses: View {
    var body: some View {
        ZStack{
                Circle() .fill(Color(hex: "#D98B4B"))
                    .frame(width: 64.22, height: 64.22)
            
            Image(systemName: "square.and.arrow.down.fill").foregroundColor(.white)
                .font(.system(size: 28))
                .scaledToFit()

        }
    }
}

struct SaveClasses_Previews: PreviewProvider {
    static var previews: some View {
        SaveClasses()
    }
}
