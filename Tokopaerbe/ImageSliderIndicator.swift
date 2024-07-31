//
//  ImageSliderIndicator.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 30/05/24.
//

import Foundation
import SwiftUI

struct ImageSliderIndicator: View {
    var numberOfPages: Int
    var currentPage: Int
    var activeColor: Color = Color("#6750A4")
    var inactiveColor: Color = .gray

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color(uiColor: <#T##UIColor#>) : inactiveColor)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.1))
        .clipShape(Capsule())
    }
}
