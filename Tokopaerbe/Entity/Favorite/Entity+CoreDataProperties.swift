//
//  Entity+CoreDataProperties.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 25/07/24.
//
//

import Foundation
import CoreData


extension FavoriteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteEntity> {
        return NSFetchRequest<FavoriteEntity>(entityName: "EntityFav")
    }

    @NSManaged public var productId: String?
    @NSManaged public var productName: String?
    @NSManaged public var productImage: String?
    @NSManaged public var productPrice: Int
    @NSManaged public var productRating: Float
    @NSManaged public var productSale: Int
    @NSManaged public var productStock: Int
    @NSManaged public var productStore: String?
    @NSManaged public var productVariant: String?

}

extension FavoriteEntity : Identifiable {

}
