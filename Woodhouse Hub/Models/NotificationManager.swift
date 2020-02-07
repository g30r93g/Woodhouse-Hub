//
//  NotificationManager.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 17/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationManager {
	
	// MARK: Shared Instance
	static let session = NotificationManager()
	
	// MARK: Initialisers
	init() {
		self.askForNotificationPermissions()
	}
	
	// MARK: Properties
	var isPermitted: Bool = false
	
	// MARK: Timetable Notifications
	func setupTimetableNotifications(for timetable: [Student.TimetableEntry]) {
		let category = UNNotificationCategory(identifier: "Timetabled", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .hiddenPreviewsShowTitle)
		self.addCategory(category)
		
		for timetabledItem in timetable {
			let content = self.createTimetableContent(from: timetabledItem)
			let trigger = self.createTimeTrigger(from: timetabledItem)
//			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
			
			let request = UNNotificationRequest(identifier: "\(timetabledItem.name)-\(timetabledItem.startTime)-\(UUID().uuidString)", content: content, trigger: trigger)
			
			self.addNotification(request)
		}
	}
	
	private func createTimeTrigger(from entry: Student.TimetableEntry) -> UNCalendarNotificationTrigger {
		let dateComponents = entry.startTime.addingTimeInterval(-5 * 60).dateComponents()
		return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
	}
	
	private func createTimetableContent(from entry: Student.TimetableEntry) -> UNNotificationContent {
		let notification = UNMutableNotificationContent()
		
		var subtitle: String {
			if let teacher = entry.teacher {
				return "\(entry.name) - \(teacher)"
			} else {
				return entry.name
			}
		}
		
		var body: String {
			if let room = entry.room {
				return "Room \(room) - \(entry.startTime.time())"
			} else {
				return entry.startTime.time()
			}
		}
		
		notification.title = "Timetable"
		notification.subtitle = subtitle
		notification.body = body
		notification.sound = .default
		notification.categoryIdentifier = "Timetabled"
		
		return notification
	}
	
	func removeTimetableNotifications(for timetable: [Student.TimetableEntry]) {
		print("Removing timetable notifications")
		for _ in timetable {
			self.removeNotification(identifier: "Timetabled")
		}
	}
	
	func removeAllNotifications() {
		UNUserNotificationCenter.current().removeAllDeliveredNotifications()
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
	}
	
}

extension NotificationManager {
	
	private func askForNotificationPermissions() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (authorized, error) in
			if error != nil {
				self.isPermitted = false
			} else {
				self.isPermitted = authorized
			}
		}
	}
	
	private func addNotification(_ notification: UNNotificationRequest) {
		let center = UNUserNotificationCenter.current()
		
		center.add(notification) { (error) in
			if let error = error {
				fatalError(error.localizedDescription)
			}
		}
	}
	
	private func addCategory(_ category: UNNotificationCategory) {
		let center = UNUserNotificationCenter.current()
		
		center.getNotificationCategories { (categories) in
			if !categories.contains(category) {
				var newCategories = categories
				newCategories.insert(category)
				
				center.setNotificationCategories(newCategories)
			}
		}
	}
	
	private func removeNotification(identifier: String = "") {
		let center = UNUserNotificationCenter.current()
		center.getPendingNotificationRequests { (pendingNotifications) in
			let notificationsToRemove = pendingNotifications.filter({$0.content.categoryIdentifier == identifier}).map({$0.identifier})
			center.removePendingNotificationRequests(withIdentifiers: notificationsToRemove)
		}
	}
	
}
