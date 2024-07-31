//
//  GeneralResponse.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 02/06/24.
//

import Foundation

struct GeneralResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T?
}
