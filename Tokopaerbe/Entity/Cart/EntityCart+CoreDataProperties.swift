//
//  EntityCart+CoreDataProperties.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 29/07/24.
//
//

import Foundation
import CoreData


extension CartEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CartEntity> {
        return NSFetchRequest<CartEntity>(entityName: "EntityCart")
    }

    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var productPrice: Int
    @NSManaged public var productStock: Int
    @NSManaged public var productQuantity: Int
    @NSManaged public var productVariant: String?
    @NSManaged public var productImage: String?
    @NSManaged public var productChecked: Bool

}

extension CartEntity : Identifiable {

}
