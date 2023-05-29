//
//  AuthManager.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 4/5/23.
//

import FirebaseFirestoreSwift
import Firebase
import SwiftUI

class AuthManager: ObservableObject {
    
    /// User Log Status
    @AppStorage("status") var status = false
    
    /// Universal Error Message To Display To User
    @Published var message = ""
    
    /// Display Alert Popup
    @Published var alert = false
    
    /// Email For Sign In / Sign Up
    @Published var email = ""
    
    /// Password For Sign In / Sign Up
    @Published var password = ""
    
    /// New User To Be Created
    @Published var user = User()
    
    /// Logs In User
    public func logIn() {
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if let error {
                print(error)
                self.message = error.localizedDescription
                self.alert.toggle()
                return
            }
            
            DispatchQueue.main.async { self.status = true }
        }
    }
    
    /// Signs Up User
    public func signUp() {
                
        // Making Sure User Entered A Phone Number And Name Are Valid
        guard !user.name.isEmpty, user.phone.count == 10 else {
            self.message = "Please Make Sure Your Name Is Not Empty And Your US Phone Number Is Valid"
            self.alert.toggle()
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error {
                self.message = error.localizedDescription
                self.alert.toggle()
                return
            }
            
            self.saveData()
        }
    }
    
    /// Saves User Data
    public func saveData() {
        
        // Firebase User ID
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            try Firestore.firestore().collection("users").document(uid).setData(from: user) { error in
                
                if let error {
                    self.message = error.localizedDescription
                    self.alert.toggle()
                    return
                }
                
                DispatchQueue.main.async { self.status = true }
            }
        } catch {
            self.message = error.localizedDescription
            self.alert.toggle()
            return
        }
    }
}
