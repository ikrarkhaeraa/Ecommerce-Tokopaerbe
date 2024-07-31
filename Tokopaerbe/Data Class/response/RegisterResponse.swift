//
//  RegisterResponse.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 02/06/24.
//

import Foundation

struct RegisterResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: UInt64
}
