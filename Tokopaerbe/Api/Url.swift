//
//  Url.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 02/06/24.
//

import Foundation

struct Url {
    static let baseURL = "http://172.20.10.5:8080"
    
    struct Endpoints {
        static let register = "\(Url.baseURL)/register"
        static let login = "\(Url.baseURL)/login"
        static let profile = "\(Url.baseURL)/profile"
        static let refresh = "\(Url.baseURL)/refresh"
        static let products = "\(Url.baseURL)/products"
        static let search = "\(Url.baseURL)/search"
        static let review = "\(Url.baseURL)/review"
        // Add other endpoints as needed
    }
}
