//
//  LoadingState.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 05/06/24.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.7))

            ProgressView()

        }
        .ignoresSafeArea(.all)
        .frame(
            width: .infinity,
            height: .infinity,
            alignment: .center
        )
    }
}
