//
//  AppDelegate.swift
//  FillITheBlanksGame
//
//  Created by MacBook on 8/17/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let newNavBarAppearance = customNavBarAppearance()
                
        let appearance = UINavigationBar.appearance()
        appearance.scrollEdgeAppearance = newNavBarAppearance
        appearance.compactAppearance = newNavBarAppearance
        appearance.standardAppearance = newNavBarAppearance
        
        if #available(iOS 15.0, *) {
            appearance.compactScrollEdgeAppearance = newNavBarAppearance
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    @available(iOS 13.0, *)
    func customNavBarAppearance() -> UINavigationBarAppearance {
        let customNavBarAppearance = UINavigationBarAppearance()
        
        // Apply a red background.
        customNavBarAppearance.configureWithOpaqueBackground()
        customNavBarAppearance.backgroundColor = hexStringToUIColor(hex: "#00CCFF")
        
        // Apply white colored normal and large titles.
        customNavBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title1)]
        customNavBarAppearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)]
        
        return customNavBarAppearance
    }
}

