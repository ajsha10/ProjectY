//
//  AppDelegate.swift
//  ProjectY
//
//  Created by iosdev on 6.5.2021.
//

import UIKit
import MOPRIMTmdSdk
import RealmSwift
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
        
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
            
            // Declare your API Key and Endpoint:
            let myKey = "eu-central-1:cb996483-fd29-4a79-912e-9d9eff9af4f2"
            let myEndpoint = "https://1t0mp83yg7.execute-api.eu-central-1.amazonaws.com/metro2021/v1"
                    
            // Initialize the TMD:
            TMD.initWithKey(myKey, withEndpoint: myEndpoint, withLaunchOptions: launchOptions).continueWith { (task) -> Any? in
                    if let error = task.error {
                        NSLog("Error while initializing the TMD SDK: %@", error.localizedDescription)
                    }
                    else {
                        // Get the app's installation id:
                        print("Successfully initialized the TMD with id %@", task.result ?? "<nil>")
                    }
                    return task;
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

  


}

