//
//  LoginResponse.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 04/06/24.
//

import Foundation

struct LoginResponse: Codable {
    let userName: String
    let userImage: String
    let accessToken: String
    let refreshToken: String
    let expiresAt: UInt64
}
