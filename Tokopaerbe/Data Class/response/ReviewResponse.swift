//
//  ReviewResponse.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 22/07/24.
//

import Foundation


struct ReviewResponse: Codable, Hashable {
    let userName: String
    let userImage : String
    let userRating : Int
    let userReview : String
}
