//
//  CircularLoadingView.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 24/06/24.
//

import Foundation
import SwiftUI

struct CircularLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
//            Circle()
//                .stroke(Color.gray.opacity(0.5), lineWidth: 10)
//                .frame(width: 100, height: 100)
            
            Circle()
                .trim(from: 0.0, to: 0.6)
                .stroke(Color(hex: "#6750A4"), lineWidth: 3)
                .frame(width: 30, height: 30)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                .onAppear {
                    self.isAnimating = true
                }
        }
    }
}
