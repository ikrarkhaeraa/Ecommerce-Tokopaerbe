//
//  TransactionResponse.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 05/08/24.
//

import Foundation

struct TransactionResponse: Codable {
    let invoiceId: String
    let status: Bool
    let date: String
    let time: String
    let payment: String
    let total: Int
    let items: [Item]
    let rating: Int?
    let review: String?
    let image: String
    let name: String
}

struct Item: Codable {
    let productId: String
    let variantName: String
    let quantity: Int
}


