//
//  User.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 4/5/23.
//

import Foundation

struct User: Codable {
    
    /// User Name
    var name: String
    
    /// User Phone Number
    var phone: String
    
    /// Has User Boarded
    var boarded = false
    
    /// Is The User A Trainer Or A Trainee
    var type: UserType = .trainer
    
    /// User Profile Picture
    var image: URL?
    
    /// Spotify Access Token
    var spotifyAccessToken: String?
    
    /// All User Classes
    var classes = [Category]()
    
    /// User Status Type
    var status: Self.UserStatus = .basic
    
    /// Number Of Classes Shared
    var shared = 0
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.boarded = try container.decode(Bool.self, forKey: .boarded)
        self.type = try container.decode(UserType.self, forKey: .type)
        self.image = try container.decodeIfPresent(URL.self, forKey: .image)
        self.spotifyAccessToken = try container.decodeIfPresent(String.self, forKey: .spotifyAccessToken)
        self.classes = try container.decodeIfPresent([Category].self, forKey: .classes) ?? []
        self.status = try container.decodeIfPresent(UserStatus.self, forKey: .status) ?? .basic
        self.shared = try container.decodeIfPresent(Int.self, forKey: .shared) ?? 0
    }
    
    init(name: String = "", phone: String = "") {
        self.name = name
        self.phone = phone
        self.type = .person
        self.image = nil
    }
    
    enum UserType: String, Codable {
        case trainer
        case person
    }
    
    enum UserStatus: String, Codable {
        case premium = "Premium"
        case basic = "Basic"
    }
}
