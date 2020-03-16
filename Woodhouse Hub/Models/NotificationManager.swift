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
	
	// MARK: Timetable Notitications
	func setupTimetableNotifications(for timetable: [Student.TimetableEntry]) {
		// Remove all timetable notifications
		self.removeTimetableNotifications()
		
		// MARK: Timetable
		let timetableCategory = UNNotificationCategory(identifier: "Timetabled", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .hiddenPreviewsShowTitle)
		self.addCategory(timetableCategory)
		
		for timetabledItem in timetable {
			let content = self.createTimetableContent(from: timetabledItem)
			let trigger = self.createTimeTrigger(from: timetabledItem)
			
			let request = UNNotificationRequest(identifier: "\(timetabledItem.name)-\(timetabledItem.startTime)-\(UUID().uuidString)", content: content, trigger: trigger)
			
			self.addNotification(request)
		}
		
		// MARK: Morning Timetable
		let morningTimetableCategory = UNNotificationCategory(identifier: "Morning Timetabled", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .hiddenPreviewsShowTitle)
		self.addCategory(morningTimetableCategory)
		
		for date in timetable.map({$0.startTime.dayOfWeek()}).removeDuplicates().map({Date().getMondayOfWeek().addDays(value: $0)}) {
			var lessonNames = timetable.filter({$0.startTime.dayOfWeek() == date.dayOfWeek()}).map({$0.name}).removeDuplicates()
			lessonNames.removeAll(where: {$0.contains("Lunch")})
			lessonNames.removeAll(where: {$0.contains("Learning Zone Study")})
			
			let content = self.createMorningTimetableNotification(for: lessonNames)
			let trigger = self.createMorningTimeTrigger(from: date)
			
			let request = UNNotificationRequest(identifier: "\(date.dayOfWeek())-\(UUID().uuidString)", content: content, trigger: trigger)
			
			self.addNotification(request)
		}
	}
	
	private func createTimeTrigger(from entry: Student.TimetableEntry) -> UNCalendarNotificationTrigger {
		let dateComponents = entry.startTime.addingTimeInterval(-5 * 60).dateComponents([.weekday, .hour, .minute])
		return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
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
				return "Room \(room) - \(entry.startTime.time()) - \(entry.endTime.time())"
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
	
	private func createMorningTimeTrigger(from date: Date) -> UNCalendarNotificationTrigger {
		let dateComponents = date.usingTime(8, 0, 0).dateComponents([.weekday, .hour, .minute])
		return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
	}
	
	private func createMorningTimetableNotification(for lessons: [String]) -> UNNotificationContent {
		let notification = UNMutableNotificationContent()
		
		var body: String = "You have "
		
		if lessons.count == 1 {
			body += "\(lessons[0]) today."
		} else {
			for (index, lesson) in lessons.enumerated() {
				if index == lessons.count - 1 {
					body += "and \(lesson) today."
				} else {
					body += "\(lesson), "
				}
			}
		}
		
		notification.title = "Today's Timetable"
		notification.body = body
		notification.sound = .default
		notification.categoryIdentifier = "Morning Timetabled"
		
		return notification
	}
	
	func removeTimetableNotifications() {
		print("Removing timetable notifications")
		self.removeNotification(identifier: "Timetabled")
		self.removeNotification(identifier: "Morning Timetabled")
	}
	
	// MARK: Student Bulletin Notifications
	func setupBulletinNotifications() {
		self.removeBulletinNotifications()
		
		let bulletinCategory = UNNotificationCategory(identifier: "Student Bulletin", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .hiddenPreviewsShowTitle)
		self.addCategory(bulletinCategory)
		
		let content = self.createBulletinNotificationContent()
		let mondayTrigger = self.createMondayBulletinTimeTrigger()
		let thursdayTrigger = self.createThursdayBulletinTimeTrigger()
		
		let mondayRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: mondayTrigger)
		let thursdayRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: thursdayTrigger)
		
		self.addNotification(mondayRequest)
		self.addNotification(thursdayRequest)
	}
	
	private func createMondayBulletinTimeTrigger() -> UNCalendarNotificationTrigger {
		let dateComponents = Date().getMondayOfWeek().usingTime(10, 30, 0).dateComponents([.weekday, .hour, .minute])
		return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
	}
	
	private func createThursdayBulletinTimeTrigger() -> UNCalendarNotificationTrigger {
		let dateComponents = Date().getMondayOfWeek().addDays(value: 4).usingTime(10, 30, 0).dateComponents([.weekday, .hour, .minute])
		return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
	}
	
	private func createBulletinNotificationContent() -> UNNotificationContent {
		let notification = UNMutableNotificationContent()
		
		notification.title = "Student Bulletin Updated"
		notification.body = "Head over to the 'Other' tab and tap Student Bulletin to see the latest update."
		notification.sound = .default
		notification.categoryIdentifier = "Student Bulletin"
		
		return notification
	}
	
	public func removeBulletinNotifications() {
		print("Removing bulletin notifications")
		self.removeNotification(identifier: "Student Bulletin")
	}
	
	// MARK: Woodle Events
	public func setupWoodleEventNotifications(from events: [WoodleInteractor.Event]) {
		self.removeWoodleEventNotifications()
		
		let woodleEventCategory = UNNotificationCategory(identifier: "Woodle Event", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .hiddenPreviewsShowTitle)
		self.addCategory(woodleEventCategory)
		
		for event in events {
			let oneHourContent = self.createWoodleEventContent(from: event, numberOfDays: 0)
			let oneDayContent = self.createWoodleEventContent(from: event, numberOfDays: 1)
			let threeDaysContent = self.createWoodleEventContent(from: event, numberOfDays: 3)
			let oneWeekContent = self.createWoodleEventContent(from: event, numberOfDays: 7)
			
			let oneHourInAdvanceTrigger = self.createWoodleEventTimeTrigger(from: event.startDate.addMinutes(amount: -60))
			let oneDayInAdvanceTrigger = self.createWoodleEventTimeTrigger(from: event.startDate.addDays(value: -1))
			let threeDaysInAdvanceTrigger = self.createWoodleEventTimeTrigger(from: event.startDate.addDays(value: -3))
			let oneWeekInAdvanceTrigger = self.createWoodleEventTimeTrigger(from: event.startDate.addDays(value: -7))
			
			let oneHourRequest = UNNotificationRequest(identifier: UUID().uuidString, content: oneHourContent, trigger: oneHourInAdvanceTrigger)
			let oneDayRequest = UNNotificationRequest(identifier: UUID().uuidString, content: oneDayContent, trigger: oneDayInAdvanceTrigger)
			let threeDaysRequest = UNNotificationRequest(identifier: UUID().uuidString, content: threeDaysContent, trigger: threeDaysInAdvanceTrigger)
			let oneWeekRequest = UNNotificationRequest(identifier: UUID().uuidString, content: oneWeekContent, trigger: oneWeekInAdvanceTrigger)
			
			self.addNotification(oneHourRequest)
			self.addNotification(oneDayRequest)
			self.addNotification(threeDaysRequest)
			self.addNotification(oneWeekRequest)
		}
	}
	
	private func createWoodleEventTimeTrigger(from date: Date) -> UNCalendarNotificationTrigger {
		let dateComponents = date.dateComponents([.weekday, .hour, .minute])
		
		return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
	}
	
	private func createWoodleEventContent(from event: WoodleInteractor.Event, numberOfDays: Int) -> UNNotificationContent {
		let notification = UNMutableNotificationContent()
		
		if numberOfDays == 0 {
			notification.title = "Woodle Event in 1 Hour"
		} else if numberOfDays == 1 {
			notification.title = "Woodle Event Tomorrow"
		} else {
			notification.title = "Woodle Event in \(numberOfDays) Days"
		}
		notification.subtitle = event.title
		notification.sound = .default
		notification.categoryIdentifier = "Woodle Event"
		
		
		
		return notification
	}
	
	private func removeWoodleEventNotifications() {
		self.removeNotification(identifier: "Woodle Event")
	}
	
}

extension NotificationManager {
	
	func removeAllNotifications() {
		UNUserNotificationCenter.current().removeAllDeliveredNotifications()
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
	}
	
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
