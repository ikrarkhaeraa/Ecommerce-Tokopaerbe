//
//  LoginBody.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 04/06/24.
//

import Foundation

struct LoginBody: Codable {
    let email: String
    let password: String
    let firebaseToken: String
}
