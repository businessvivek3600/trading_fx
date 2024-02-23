import UIKit
import Flutter
import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     FirebaseApp.configure()

    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        // Enable or disable features based on authorization.
      }
    } else {
      let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

   override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken:Data){
      print("data------------------------");
      Messaging.messaging().apnsToken=deviceToken
      print(" Token:--->\(deviceToken)")
    super.application(application,didRegisterForRemoteNotificationsWithDeviceToken:deviceToken)
  }
}
