//
//  DragDrop.swift
//  Fitplay
//
//  Created by Samuel Vulakh on 5/11/23.
//

import Foundation
import SwiftUI

struct ClassesDropDelegate: DropDelegate {
    
    var image: Category
    var data: DataManager
    
    func performDrop(info: DropInfo) -> Bool {
        // UnComment This Just a try...
        //pageData.currentPage = nil
        return true
    }
    
    // When User Dragged Into New Page...
    func dropEntered(info: DropInfo) {
        
        // UnComment This Just a try...
       /* if pageData.currentPage == nil{
            pageData.currentPage = page
        } */
        
        // Getting From And To Index...
        
        // From Index
        let fromIndex = data.user?.classes.firstIndex { $0.id == data.currentDraggingPage?.id } ?? 0
        
        // To Index...
        let toIndex = data.user?.classes.firstIndex { $0.id == self.image.id } ?? 0
        
        // Safe Check if both are not same...
        if fromIndex != toIndex {
            // Animation...
            withAnimation(.default) {
                // Swapping Data...
                guard let to = data.user?.classes[toIndex], let from = data.user?.classes[fromIndex] else { return }
                data.user?.classes[fromIndex] = to
                data.user?.classes[toIndex] = from
            }
        }
    }
    
    // setting Action as Move...
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

struct WorkoutsDropDelegate: DropDelegate {
    
    var c: Category
    var w: Workout
    var data: DataManager
    
    func performDrop(info: DropInfo) -> Bool {
        // UnComment This Just a try...
        //pageData.currentPage = nil
        return true
    }
    
    // When User Dragged Into New Page...
    func dropEntered(info: DropInfo) {
        
        // UnComment This Just a try...
       /* if pageData.currentPage == nil{
            pageData.currentPage = page
        } */
        
        // Getting From And To Index...
        
        // From Index
        let fromIndex = data.user?.classes.firstIndex { $0.id == data.currentDraggingPage?.id } ?? 0
        
        // To Index...
        let toIndex = data.user?.classes.firstIndex { $0.id == self.c.id } ?? 0
        
        // Safe Check if both are not same...
        if fromIndex != toIndex {
            // Animation...
            withAnimation(.default) {
                // Swapping Data...
                guard let to = data.user?.classes[toIndex], let from = data.user?.classes[fromIndex] else { return }
                data.user?.classes[fromIndex] = to
                data.user?.classes[toIndex] = from
                data.update()
            }
        }
    }
    
    // setting Action as Move...
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
