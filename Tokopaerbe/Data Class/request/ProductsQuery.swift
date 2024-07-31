//
//  ProductsQuery.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 15/06/24.
//

import Foundation

struct ProductsQuery: Codable {
    let search : String?
    let brand : String?
    let lowest : Int?
    let highest : Int?
    let sort : String?
    let limit : Int?
    let page : Int?
}

