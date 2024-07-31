//
//  ProductDetailResponse.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 12/07/24.
//

import Foundation
import SwiftUI

struct ProductDetailResponse: Codable {
    let productId : String
    let productName : String
    let productPrice : Int
    let image : [String]
    let brand : String
    let description : String
    let store : String
    let sale : Int
    let stock : Int
    let totalRating : Int
    let totalReview : Int
    let totalSatisfaction : Int
    let productRating : Float16
    let productVariant : [ProductVariant]
}

struct ProductVariant: Codable {
    let variantName : String
    let variantPrice : Int
}
