//
//  PaymentRemoteConfigResponse.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 26/08/24.
//

import Foundation

struct PaymentRemoteConfigResponse: Codable {
 let title: String
 let item: [PaymentMethod]
}

struct PaymentMethod: Codable {
    let label : String
    let image : String
    let status : Bool
}
