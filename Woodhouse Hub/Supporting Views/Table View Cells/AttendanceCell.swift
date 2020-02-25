//
//  AttendanceCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 25/02/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class AttendanceCell: UITableViewCell {
	
	// MARK: IBOutlets
	@IBOutlet weak private var lesson: UILabel!
	@IBOutlet weak private var date: UILabel!
	@IBOutlet weak private var teacher: UILabel!
	@IBOutlet weak private var attendanceMark: UILabel!
	
	// MARK: Methods
	func setupCell(from data: Student.AttendanceEntry, index: Int) {
		self.reset()
		if (index % 2) == 1 { self.applyAlternateBackground() }
		
		self.date.text = "Date: \(data.date.extendedDate())"
		
		switch data.attendanceMark {
		case .present:
			self.attendanceMark.text = "Present"
			self.attendanceMark.textColor = .systemGreen
		case .late:
			self.attendanceMark.text = "Late"
			self.attendanceMark.textColor = .systemOrange
		case .veryLate:
			self.attendanceMark.text = "Very Late"
			self.attendanceMark.textColor = .systemOrange
		case .unauthorisedAbsence:
			self.attendanceMark.text = "Unauthorised Absence"
			self.attendanceMark.textColor = .systemRed
		case .notifiedAbsence:
			self.attendanceMark.text = "Notified Absence"
			self.attendanceMark.textColor = .systemRed
		case .internalExam:
			self.attendanceMark.text = "Internal Exam"
			self.attendanceMark.textColor = .systemBlue
		case .permissionToMiss:
			self.attendanceMark.text = "Permission to Miss Lesson"
			self.attendanceMark.textColor = .systemBlue
		case .cancelled:
			self.attendanceMark.text = "Cancelled"
			self.attendanceMark.textColor = .systemBlue
		case .transferIntoSet:
			self.attendanceMark.text = "Transfer In"
			self.attendanceMark.textColor = UIColor(named: "Text")
		case .transferOutOfSet:
		self.attendanceMark.textColor = .black
			self.attendanceMark.text = "Transfer Out"
			self.attendanceMark.textColor = UIColor(named: "Text")
		case .event:
			self.attendanceMark.text = "Event"
			self.attendanceMark.textColor = UIColor(named: "Text")
		case .mark:
			self.attendanceMark.text = ""
			self.attendanceMark.textColor = .clear
		}
		
		if let timetable = Student.current.getTimetable(), let matchingClass = timetable.first(where: {$0.day == data.date.dayOfWeek() && $0.classIdentifier == data.classIdentifier}) {
			self.lesson.text = matchingClass.name
			self.teacher.text = matchingClass.teacher ?? ""
		} else {
			self.lesson.text = data.classIdentifier
		}
	}
	
	private func reset() {
		self.backgroundColor = UIColor(named: "Cell")
	}
	
	private func applyAlternateBackground() {
		self.backgroundColor = UIColor(named: "Alternate Cell")
	}
	
}
