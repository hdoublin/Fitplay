//
//  ColorGardients.swift
//  Fitplay
//
//  Created by Scorpus on 3/24/23.
//

import SwiftUI

struct ColorGardients: View {
    var body: some View {
        HStack{
            // Vine Gradient
            Circle() .fill(RadialGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.9387335181, green: 0.9366018176, blue: 0.9556583762, alpha: 1)),Color(#colorLiteral(red: 0.5155320168, green: 0.5036066771, blue: 0.6691393256, alpha: 1))
            ]), center: .center, startRadius: 1, endRadius: 80))
            .frame(width: 140, height: 170)
            
            // Orange Gradient
            // Light-Orange Gradient
     
        }
    }
}

struct ColorGardients_Previews: PreviewProvider {
    static var previews: some View {
        ColorGardients()
    }
}
