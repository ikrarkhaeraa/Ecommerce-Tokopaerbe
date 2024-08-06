//
//  TokopaerbeApp.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 29/05/24.
//

import SwiftUI

@main
struct TokopaerbeApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
