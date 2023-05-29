//
//  Class.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 3/30/23.
//

import SwiftUI

struct Category: Identifiable, Codable {
    
    /// Unique ``Category`` Idenifier
    var id = UUID().uuidString
    
    /// ``Category`` Title
    var title: String
    
    /// Category Image
    var image: URL?

    /// Category Description
    var description: String
    
    /// All Workouts In Category
    var workouts: [Workout] = []
    
    /// Alll Workout Options For User To Select From
    var options = [Workout]()
    
    /// Category Offset For Adding / Removing Categories
    var offset = 0.0
    
    /// Total Duration Of The Catgeory
    var duration: TimeInterval {
        
        var totalDur = 0
        
        workouts.forEach { w in
            if w.duration.contains(":") {
                let components = w.duration.components(separatedBy: ":")
                print(components)
                totalDur += (Int(components[0]) ?? 0) * 60
                totalDur += Int(components[1]) ?? 0
            } else {
                totalDur += Int(w.duration) ?? 0
            }
        }
        
        return TimeInterval(totalDur)
    }
    
    /// Date Text
    var dateText = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image
        case description
        case workouts
//        case options
        case dateText = "Date"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.description, forKey: .description)
        try container.encodeIfPresent(self.image, forKey: .image)
        try container.encode(self.workouts, forKey: .workouts)
//        try container.encode(self.options, forKey: .options)
        try container.encode(self.dateText, forKey: .dateText)
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.image = try container.decodeIfPresent(URL.self, forKey: .image)
        self.workouts = try container.decode([Workout].self, forKey: .workouts)
        self.dateText = try container.decodeIfPresent(String.self, forKey: .dateText) ?? encodeDate()
    }
    
    init(title: String, image: URL? = nil, description: String, workouts: [Workout] = [], options: [Workout] = []) {
        self.title = title
        self.image = image
        self.description = description
        self.workouts = workouts
        self.dateText = encodeDate()
        self.options = options
    }
    
    func encodeDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: Date())
    }
        
    struct Workout: Identifiable, Equatable, Codable {
        
        /// Unique Workout Identifier
        var id = UUID().uuidString
        
        /// Workout Exercise
        var exercise: String = ""
        
        /// Workout Equipment
        var equipment: String = ""
        
        /// Workout Equipment Count
        var equipmentCount: String = ""
        
        /// Workout Time Duration
        var duration: String = ""
        
        /// Workout Offset For Drag-To-Delete
        var offset = 0.0
        
        enum CodingKeys: CodingKey {
            case id
            case exercise
            case equipment
            case equipmentCount
            case duration
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(self.id, forKey: .id)
            try container.encode(self.exercise, forKey: .exercise)
            try container.encode(self.equipment, forKey: .equipment)
            try container.encode(self.equipmentCount, forKey: .equipmentCount)
            try container.encode(self.duration, forKey: .duration)
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)
            self.exercise = try container.decode(String.self, forKey: .exercise)
            self.equipment = try container.decode(String.self, forKey: .equipment)
            self.equipmentCount = try container.decode(String.self, forKey: .equipmentCount)
            self.duration = try container.decode(String.self, forKey: .duration)
        }
        
        init(exercise: String, equipment: String) {
            self.exercise = exercise
            self.equipment = equipment
        }
    }
    
    var text: [TimeString] {
        
        var components = self.description.components(separatedBy: " ")
        
        var newComponents = [String]()
        var timeStrings = [TimeString]()
        
        while !components.isEmpty {
            if components.count >= 3 {
                newComponents.append("\(components[0]) \(components[1]) \(components[2])")
                components.removeFirst(3)
            } else if components.count == 2 {
                newComponents.append("\(components[0]) \(components[1])")
                components.removeFirst(2)
            } else {
                newComponents.append(components[0])
                components.remove(at: 0)
            }
        }
        
        newComponents.indices.forEach { index in
            if newComponents[index] != newComponents.last {
                let start = Double(index) * duration / Double(newComponents.count)
                let end = (Double(index + 1) - 0.1) * duration / Double(newComponents.count)
                timeStrings.append(TimeString(text: newComponents[index], start: start, end: end))
            } else {
                let start = Double(index) * duration / Double(newComponents.count)
                timeStrings.append(TimeString(text: newComponents[index], start: start, end: duration))
            }
        }
        
        return timeStrings
    }
}
