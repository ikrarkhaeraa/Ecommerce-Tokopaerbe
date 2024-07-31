//
//  NetworkError.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 03/06/24.
//

import Foundation

enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case failedToDecodeResponse
}
