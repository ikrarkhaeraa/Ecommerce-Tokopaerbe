//
//  FulfillmentResponse.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 02/08/24.
//

import Foundation

struct FulfillmentResponse: Codable {
    let invoiceId : String
    let status : Bool
    let date : String
    let time : String
    let payment : String
    let total : Int
}
