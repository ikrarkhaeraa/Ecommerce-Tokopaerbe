//
//  SplashScreen.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 01/06/24.
//

import SwiftUI

struct SplashScreen: View {
    
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @State private var isActive: Bool = false
    
    
    var body: some View {
        NavigationView {
            
            VStack {
                if case .productDetail(let productId) = deepLinkManager.destination {
                    NavigationLink(
                        destination: ProductDetailScreen(productIdDeepLink: productId),
                        isActive: .constant(true)
                    ) {
                        EmptyView()
                    }
                }
                
                NavigationLink(
                    destination: MainScreen(page: 0),
                    isActive: $isActive
                ) {
                    //                Image(uiImage: UIImage(named: "splash_screen")!)
                    GIFImage(name: "splash_screen").frame(width: 300, height: 300)
                }
                
            }.onAppear {
                
                if case .productDetail = deepLinkManager.destination {
                    deepLinkManager.destination = .unknown
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    UserDefaults.standard.setValue(false, forKey: "isGrid")
                    isActive = true
                }
            }
        }
    }
    
//    #Preview {
//        SplashScreen()
//    }
    // MARK: - Previews
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            SplashScreen().environmentObject(DeepLinkManager())
        }
    }
}
