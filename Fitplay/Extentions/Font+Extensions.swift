//
//  Font+Extensions.swift
//  Fitplay
//
//  Created by Scorpus on 03/23/23.
//

import SwiftUI


extension Font {
    public static func custom(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> Font {
            var font = "OpenSans-Regular"
            switch weight {
            case .light: font = "SourceSansPro-Light"
            case .bold: font = "SourceSansPro-Bold"
            case .regular: font = "SourceSansPro-Regular"
            case .medium: font = "SourceSansPro-Black"
            case .semibold: font = "SourceSansPro-SemiBold"
            case .thin: font = "SourceSansPro-ExtraLight"
                
            default: break
            }
            return Font.custom(font, size: size)
        }
}


