//
//  FulfillmentRequst.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 02/08/24.
//

import Foundation

struct FulfillmentRequst: Codable {
    let payment : String
    let items : [Items]
}

struct Items: Codable {
    let productId: String
    let variantName: String
    let quantity: Int
}
