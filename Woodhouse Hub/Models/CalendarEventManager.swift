//
//  CalendarEventManager.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 01/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation
import EventKit

class CalendarEventManager {
	
	// MARK: Shared Instance
	static let manager = CalendarEventManager()
	
	// MARK: Init
	init() { }
	
	// MARK: Methods
	public func addWoodleCalendarEvent(_ event: WoodleInteractor.Event, completion: @escaping(Bool) -> Void) {
		let eventStore = EKEventStore()
		
		eventStore.requestAccess(to: .event) { (accessGranted, error) in
			if let error = error {
				print("[CalendarEventManager] Error: \(error.localizedDescription)")
				completion(false)
				return
			}
			
			if accessGranted {
				let calendarEvent = self.generateWoodleCalendarEvent(from: event, store: eventStore)
				
				do {
					try eventStore.save(calendarEvent, span: .thisEvent)
				} catch let error as NSError {
					print("[CalendarEventManager] Error: \(error.localizedDescription)")
				}
				print("[CalendarEventManager] Event '\(event.title)' saved!")
			} else {
				completion(false)
			}
		}
	}
	
	private func generateWoodleCalendarEvent(from event: WoodleInteractor.Event, store: EKEventStore) -> EKEvent {
		let calendarEvent: EKEvent = EKEvent(eventStore: store)

		calendarEvent.title = event.title
		calendarEvent.startDate = event.startDate
		calendarEvent.endDate = event.endDate
		calendarEvent.notes = event.description
		
		calendarEvent.calendar = store.defaultCalendarForNewEvents
		calendarEvent.alarms = self.setEventAlarms(for: event.startDate)
		
		return calendarEvent
	}
	
	private func setEventAlarms(for date: Date) -> [EKAlarm] {
		// Add one week in advance alarm
		let weekNotice = EKAlarm(absoluteDate: date.addDays(value: -7))
		
		// Add one day in advance alarm
		let dayNotice = EKAlarm(absoluteDate: date.addDays(value: -1))
		
		// Return alarms
		return [weekNotice, dayNotice]
	}
	
}
