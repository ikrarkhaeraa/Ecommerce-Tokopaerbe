//
//  ProductsResponse.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 15/06/24.
//

import Foundation
import SwiftUI

struct ProductsResponse: Codable {
    let itemsPerPage : Int
    let currentItemCount : Int
    let pageIndex : Int
    let totalPages : Int
    let items : [Product]
}

struct Product: Codable, Hashable {
    let productId : String
    let productName : String
    let productPrice : Int64
    let image : String
    let brand : String
    let store : String
    let sale : Int
    let productRating: Float16
}
