//
//  RatingBody.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 05/08/24.
//

import Foundation

struct RatingBody: Codable {
    let invoiceId : String
    let rating : Int
    let review : String
}
