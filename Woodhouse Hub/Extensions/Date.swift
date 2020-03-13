//
//  Date.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 17/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation

extension Date {
	
	var isWeekend: Bool {
		return Calendar(identifier: .gregorian).isDateInWeekend(self)
	}
	
	static func woodleFormat(from string: String) -> Date {
		let dateFormatter = DateFormatter()
		if string.contains(":") {
			dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
		} else {
			dateFormatter.dateFormat = "dd MMMM yyyy"
		}
		dateFormatter.locale = Locale(identifier: "en_GB")
		
		return dateFormatter.date(from: string) ?? Date()
	}
	
	static func markbookFormat(from string: String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd/MM/yyyy"
		dateFormatter.locale = Locale(identifier: "en_GB")
		
		return dateFormatter.date(from: string) ?? Date()
	}
	
	static func reportServerFormat(from string: String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
		
		return dateFormatter.date(from: string) ?? Date()
	}
	
	/// Returns the date
	func date() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.locale = Locale(identifier: "en_GB")
		
		return dateFormatter.string(from: self)
	}
	
	/// Returns the date with the week day name
	func extendedDate() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE dd MMM yyyy"
		dateFormatter.locale = Locale(identifier: "en_GB")
		
		return dateFormatter.string(from: self)
	}
	
	/// Returns the time
	func time() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm a"
		dateFormatter.amSymbol = ""
		dateFormatter.pmSymbol = ""
		
		return dateFormatter.string(from: self).replacingOccurrences(of: "  ", with: " ")
	}
	
	/// Uses the current date, but manipulates the time value
	func usingTime(_ hour: Int, _ minute: Int, _ second: Int) -> Date {
		let calendar = Calendar(identifier: .gregorian)
		
		var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
		dateComponents.hour	= hour
		dateComponents.minute = minute
		dateComponents.second = second
		
		return calendar.date(from: dateComponents)!
	}
	
	func dayName() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE"
		dateFormatter.locale = Locale(identifier: "en_GB")
		
		return dateFormatter.string(from: self)
	}
	
	func dayOfWeek() -> Int {
		switch self.dayName() {
		case "Monday":
			return 1
		case "Tuesday":
			return 2
		case "Wednesday":
			return 3
		case "Thursday":
			return 4
		case "Friday":
			return 5
		case "Saturday":
			return 6
		case "Sunday":
			return 7
		default:
			return 0
		}
	}
	
	func dateComponents(_ components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]) -> DateComponents {
		return Calendar(identifier: .gregorian).dateComponents(components, from: self)
	}
	
	func extractTime(from string: String) -> Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE"
		dateFormatter.locale = Locale(identifier: "en_GB")
		
		return dateFormatter.date(from: string)!
	}
	
	func addingOneDay(hour: Int, minute: Int, second: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: self.usingTime(hour, minute, second))!
	}
	
	/// Determines whether the current date falls in the range of two dates
	func fallsIn(lower: Date, upper: Date) -> Bool {
		return lower <= self && self <= upper
	}
	
	func addMinutes(amount: Int) -> Date {
		return Calendar.current.date(byAdding: .minute, value: amount, to: self)!
	}
	
	func getMondayOfWeek() -> Date {
		var calendar = Calendar(identifier: .gregorian)
		calendar.locale = Locale(identifier: "en_GB")
			
		return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
	}
	
	func addDays(value: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: value, to: self)!
	}
	
	/// Prettifies a date
	func prettify() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .short
		dateFormatter.dateStyle = .medium
		dateFormatter.locale = Locale(identifier: "en_GB")
		
		return dateFormatter.string(from: self)
	}
	
	func numberOfDays(to date: Date) -> Int {
		let startDate = self.usingTime(0, 0, 0).getMondayOfWeek() // Number of days from monday...
		let endDate = date.usingTime(0, 0, 0).getMondayOfWeek().addDays(value: 5) // ...to friday
		
		return Int(startDate.timeIntervalSince(endDate)) / (60*60*24)
	}
	
	func updateToCurrentWeek() -> Date {
		return self.getMondayOfWeek().addDays(value: self.dayOfWeek() - 1).usingTime(self.dateComponents().hour!, self.dateComponents().minute!, self.dateComponents().second!)
	}
	
}
