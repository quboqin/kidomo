//
//  kidomoApp.swift
//  kidomo
//
//  Created by qinqubo on 2024/5/30.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { granted, error in
                guard granted else { return }
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        )
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken

        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        let tokenViewModel = TokenViewModel()

        // Update the token
        tokenViewModel.updateToken(token)

        // Access the current token
        if let currentToken = tokenViewModel.token {
            print("Current token: \(currentToken)")
        } else {
            print("No token saved")
        }
        
        // Your server's API endpoint
        let url = URL(string: "https://saas-test.opsfast.com/api/blade-common/firebase-token/update-token")!

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // The header
        let viewModel = MessageViewModel()
        if let messageData = viewModel.retrieveMessage() {
            request.allHTTPHeaderFields = [
                "Content-Type": "application/x-www-form-urlencoded",
                "Blade-Auth": messageData.BladeAuth,
                "Authorization": messageData.Authorization
            ]
        }
        
        // The payload
        let payload: [String: Any] = ["token": token, "platform": "ios"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        // Create the task
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error occurred: \(error)")
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                print("Received data:\n\(str ?? "")")
            }
        }

        // Start the task
        task.resume()
    }
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
      -> UNNotificationPresentationOptions {
      let userInfo = notification.request.content.userInfo

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // ...

      // Print full message.
      print(userInfo)

      // Change this to your preferred presentation option
      return [[.list, .banner]]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
      let userInfo = response.notification.request.content.userInfo

      // ...

      // With swizzling disabled you must let Messaging know about the message, for Analytics
      // Messaging.messaging().appDidReceiveMessage(userInfo)

      // Print full message.
      print(userInfo)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
    }
}

@main
struct kidomoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            let urlString = "https://m-saas.opsfast.com/"
            let url = URL(string: urlString)!
            SecondView(url: url)
        }
    }
}
