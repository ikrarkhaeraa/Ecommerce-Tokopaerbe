//
//  EntityNotif+CoreDataProperties.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 06/08/24.
//
//

import Foundation
import CoreData


extension EntityNotif {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityNotif> {
        return NSFetchRequest<EntityNotif>(entityName: "EntityNotif")
    }

    @NSManaged public var productId: String?
    @NSManaged public var date: String?
    @NSManaged public var time: String?
    @NSManaged public var isRead: Bool

}

extension EntityNotif : Identifiable {

}
