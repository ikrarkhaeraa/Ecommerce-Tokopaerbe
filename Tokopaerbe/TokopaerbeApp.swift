//
//  TokopaerbeApp.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 29/05/24.
//

import SwiftUI

@main
struct TokopaerbeApp: App {
    
    // MARK: DeepLink
    @StateObject private var deepLinkManager = DeepLinkManager()
    // MARK: Core data
    @StateObject private var manager: DataManager = DataManager()
    
    var body: some Scene {

        WindowGroup {
            SplashScreen()
                .environmentObject(deepLinkManager)
                .onOpenURL { url in
                    let _ = Log.d("url: \(url)")
                    deepLinkManager.handleURL(url)
                }
                .environmentObject(manager)
                .environment(\.managedObjectContext, manager.container.viewContext)
                .onAppear {
                    let path = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
                    print("\(path)")
                }
        }
    }
}
