//
//  FavoriteDataManager.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 25/07/24.
//

import CoreData
import Foundation

// Main data manager to handle the todo items
class DataManager: NSObject, ObservableObject {
    
    // Dynamic properties that the UI will react to
//    @Published var products: [FavoriteEntity] = [FavoriteEntity]()
//    @Published var productsCart: [CartEntity] = [CartEntity]()
    
    // Add the Core Data container with the model name
    let container: NSPersistentContainer = NSPersistentContainer(name: "AppEntity")
//    let containerCart: NSPersistentContainer = NSPersistentContainer(name: "CartProduct")
    
    // Default init method. Load the Core Data container
    override init() {
        super.init()
        container.loadPersistentStores { _, _ in }
//        containerCart.loadPersistentStores { _, _ in }
    }
}
