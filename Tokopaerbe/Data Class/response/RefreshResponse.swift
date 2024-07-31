//
//  RefreshResponse.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 06/06/24.
//

import Foundation

struct RefreshResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: UInt64
}
