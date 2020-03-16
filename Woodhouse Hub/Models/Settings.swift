//
//  Settings.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 18/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation

class Settings {
	
	// MARK: Initialisers
	init() { }
	
	// MARK: Properties
	public var username: String? {
		get {
			return UserDefaults.data.string(forKey: "Woodhouse-Username")
		}
		set {
			UserDefaults.data.set(newValue, forKey: "Woodhouse-Username")
		}
	}
	
	public var password: String? {
		get {
			return UserDefaults.data.string(forKey: "Woodhouse-Password")
		}
		set {
			UserDefaults.data.set(newValue, forKey: "Woodhouse-Password")
		}
	}
	
	public var isSignedIn: Bool {
		get {
			return UserDefaults.data.bool(forKey: "isSignedIn")
		}
		set {
			UserDefaults.data.set(newValue, forKey: "isSignedIn")
		}
	}
	
	public var isReceivingTimetableNotifications: Bool {
		get {
			return UserDefaults.data.bool(forKey: "isReceivingTimetableNotifications")
		}
		set {
			UserDefaults.data.set(newValue, forKey: "isReceivingTimetableNotifications")
		}
	}
	
	public var studentDetails: Student.StudentDetails? {
		get {
			let name = UserDefaults.data.string(forKey: "Student-Name")
			let idNumber = UserDefaults.data.string(forKey: "Student-ID")
			let tutorGroup = UserDefaults.data.string(forKey: "Student-Tutor-Group")
			
			if let name = name, let idNumber = idNumber, let tutorGroup = tutorGroup {
				return Student.StudentDetails(name: name, id: idNumber, tutorGroup: tutorGroup, image: nil)
			} else {
				return nil
			}
		}
		set {
			if let newValue = newValue {
				UserDefaults.data.set(newValue.name, forKey: "Student-Name")
				UserDefaults.data.set(newValue.id, forKey: "Student-ID")
				UserDefaults.data.set(newValue.tutorGroup, forKey: "Student-Tutor-Group")
			}
		}
	}
	
	// MARK: Methods
	func signOut() {
		Settings().isSignedIn = false
		
		// Remove credentials
		WoodhouseCredentials.shared.setUsername(to: "")
		WoodhouseCredentials.shared.setPassword(to: "")
		URLCredentialStorage.shared.setDefaultCredential(WoodhouseCredentials.shared.getCredential()!, for: WoodhouseCredentials.shared.getProtectionSpace()!)
		
		// Reset browsers
		DashboardInteractor.shared.signOut()
		ReportServerInteractor.shared.signOut()
		WoodleInteractor.shared.signOut()
		
		NotificationManager.session.removeAllNotifications()
		CoreDataManager.manager.deleteAndRebuild()
		
		// Crash app to reset app completely
		abort()
	}
	
}
