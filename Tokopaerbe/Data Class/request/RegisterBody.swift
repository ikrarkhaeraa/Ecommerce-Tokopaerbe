//
//  RegisterBody.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 02/06/24.
//

import Foundation

struct RegisterBody: Codable {
    let email: String
    let password: String
    let firebaseToken: String
}
