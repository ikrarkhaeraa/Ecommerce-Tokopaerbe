//
//  DeepLinkManager.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 24/07/24.
//

import SwiftUI
import Combine

class DeepLinkManager: ObservableObject {
    enum Destination: Equatable {
        case productDetail(productId: String)
        case unknown
    }
    
    @Published var destination: Destination = .unknown
    
    func handleURL(_ url: URL) {
        let pathComponents = url.pathComponents
        let _ = Log.d("path components: \(pathComponents)")
        
        if url.host == "ecommerce.tokopaerbe.com" && pathComponents.count > 2 && pathComponents[1] == "product" {
            let productId = pathComponents[2]
            destination = .productDetail(productId: productId)
        } else {
            destination = .unknown
        }
    }
}



