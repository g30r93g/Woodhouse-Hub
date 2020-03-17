//
//  AppDelegate.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 14/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//
import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		self.determineStoryboard()
		
		// Begin checking for notifications
		UNUserNotificationCenter.current().delegate = self
		_ = NotificationManager.session
		
		// Setup username and password for dashboard
		self.start()
		
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		
		CoreDataManager.manager.saveContext()
	}
	
	// MARK: UISceneSession Lifecycle
	@available(iOS 13.0, *)
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	@available(iOS 13.0, *)
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		// Called when the user discards a scene session.
		// If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
		// Use this method to release any resources that were specific to the discarded scenes, as they will not return.
	}
	
	func start() {
		// Start
		if Settings().isSignedIn {
			DashboardInteractor.shared.signIn(username: Settings().username!, password: Settings().password!) { (_) in }
			WoodleInteractor.shared.signIn()
			_ = ReportServerInteractor.shared
			NotificationManager.session.setupBulletinNotifications()
		}
	}
	
	
	func determineStoryboard() {
		//		Settings().isSignedIn = false
		
		var storyboard: UIStoryboard {
			if Settings().isSignedIn {
				return UIStoryboard(name: "Main", bundle: nil)
			} else {
				return UIStoryboard(name: "Sign In", bundle: nil)
			}
		}
		
		let initialVC = storyboard.instantiateInitialViewController()
		self.window?.rootViewController = initialVC
		self.window?.makeKeyAndVisible()
	}
	
}

extension AppDelegate: UNUserNotificationCenterDelegate {
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		print("Received notification whilst in foreground: \(notification.request.content.title) - \(notification.request.content.body)")
		
		completionHandler(.alert)
	}
	
}
