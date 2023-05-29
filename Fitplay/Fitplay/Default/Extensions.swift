//
//  Extensions.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 4/5/23.
//

import Firebase
import SwiftUI

// All Color Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else { return nil }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
    
    /// Make this Color lighter by a certain percentage
    /// - Parameter percentage: The percentage by which to make the color ligher. Defaults to 15
    /// - Returns: The updated, lighter Color
    func lighter(by percentage: CGFloat = 15.0) -> Color {
        return self.adjust(by: abs(percentage) )
    }
    
    /// Make this Color darker by a certain percentage
    /// - Parameter percentage: The percentage by which to make the color darker. Defaults to 15
    /// - Returns: The updated, darker Color
    func darker(by percentage: CGFloat = 15.0) -> Color {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    /// Adjusts the Color to make it ligher or darker.
    /// - Parameter percentage: The percentage by which to adjust the color. Postitive values are lighter while negative are darger. Defaults to 15
    /// - Returns: The adjusted Color
    func adjust(by percentage: CGFloat = 15.0) -> Color {
        let uiColor = UIColor(self)
        if let new = uiColor.adjust(by: percentage) {
            return Color(uiColor: new)
        }
        return self
    }
}

extension UIColor {
    /// Make this UIColor lighter by a certain percentage
    /// - Parameter percentage: The percentage by which to make the color ligher. Defaults to 15
    /// - Returns: The updated, lighter UIColor
    func lighter(by percentage: CGFloat = 15.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    /// Make this UIColor darker by a certain percentage
    /// - Parameter percentage: The percentage by which to make the color darker. Defaults to 15
    /// - Returns: The updated, darker UIColor
    func darker(by percentage: CGFloat = 15.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    /// Adjusts the UIColor to make it ligher or darker.
    /// - Parameter percentage: The percentage by which to adjust the color. Postitive values are lighter while negative are darger. Defaults to 15
    /// - Returns: The adjusted UIColor
    func adjust(by percentage: CGFloat = 15.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}


// All Font Extensions
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

// All View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension Calendar {
    
    func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates = [interval.start]
        enumerateDates(startingAfter: interval.start,
                       matching: components,
                       matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        return dates
    }
}

extension Date {
    
    func getDayNumber() -> Int {
        return Calendar.current.component(.day, from: self)
    }
    
    func getMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM"
        return formatter.string(from: self)
    }
    
    func getDaysForMonth() -> [Date] {
        guard
            let monthInterval = Calendar.current.dateInterval(of: .month, for: self),
            let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let monthLastWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.end)
        else {
            return []
        }
        let resultDates = Calendar.current.generateDates(inside: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
                                                         matching: DateComponents(hour: 0, minute: 0, second: 0))
        return resultDates
    }
    
    func isSameDay(comparingTo: Date) -> Bool {
        let selfComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let comparingComponents = Calendar.current.dateComponents([.year, .month, .day], from: comparingTo)
        guard let selfYear = selfComponents.year,
              let selfMonth = selfComponents.month,
              let selfDay = selfComponents.day,
              let comparingYear = comparingComponents.year,
              let comparingMonth = comparingComponents.month,
              let comparingDay = comparingComponents.day else {
            return false
        }
        return selfYear == comparingYear &&
               selfMonth == comparingMonth &&
               selfDay == comparingDay
    }
   
    func getLastMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: -1, to: self) ?? self
    }
    
    func getNextMonth() -> Date {
        return Calendar.current.date(byAdding: .month, value: 1, to: self) ?? self
    }
}

extension View {
    @ViewBuilder
    func addCircularBackground(isFilled: Bool, isSelected: Bool, highlightColor: Color = Color(hex: "#E6863B"), normalColor: Color = Color(hex: "#E6863B")) -> some View {
        self
            .padding(9)
        #if os(macOS)
            .foregroundColor(Color(cgColor: .black))
        #elseif os(iOS)
            .foregroundColor(Color(uiColor: .systemBackground))
        #endif
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(isSelected ? highlightColor : normalColor)
                    .frame(width: 35, height: 35)
                    .opacity(isFilled ? 1.0 : 0.0)
                    .padding(isSelected ? 3 : 0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(highlightColor, lineWidth: isSelected ? 2 : 0)
                    )
            )
    }
}

// Firestore Extensions
extension Firestore {
    
    /// Users Database Collection Reference
    static var users: CollectionReference { self.firestore().collection("users") }
    
    /// Workouts Database Collection Reference
    static var workouts: CollectionReference { firestore().collection("workouts") }
    
    /// Get Current User Document (Is NIL If User Is Not Logged In)
    static var current: DocumentReference? {
        
        /// Making Sure Current User ID Exists
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        
        // Returning Current User Document If ID Is Valid
        return Firestore.users.document(uid)
    }
}

// Shape Extensions
extension Shape {
    /// Enabling Stroke Width Fill On A Shape
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

// InsettableShape Extensions
extension InsettableShape {
    /// Enabling Stroke Width Fill On A Shape
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}
