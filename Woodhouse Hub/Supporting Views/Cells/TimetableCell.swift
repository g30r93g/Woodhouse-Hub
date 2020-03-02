//
//  TimetableCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 17/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class TimetableCell: RoundUICollectionViewCell {
	
	// MARK: IBOutlets
	@IBOutlet weak private var nextCurrentLesson: RoundLabel!
	@IBOutlet weak private var lessonStartTime: UILabel!
	@IBOutlet weak private var lessonEndTime: UILabel!
	@IBOutlet weak private var lessonName: UILabel!
	@IBOutlet weak private var teacher: UILabel!
	@IBOutlet weak private var room: UILabel!
	
	// MARK: Methods
	func setupCell(from data: Student.TimetableEntry) {
		// Setup time labels
		self.lessonStartTime.text = data.startTime.time()
		self.lessonEndTime.text = data.endTime.time()
		
		// Setup lesson name label
		self.lessonName.text = data.name
		
		// Setup teacher name label
		guard let teacherLabel = self.teacher else { return }
		if let teacher = data.teacher {
			teacherLabel.text = teacher
		} else {
			teacherLabel.text = ""
		}
		
		// Setup lesson room label
		if let room = data.room {
			self.room.text = "Room \(room)"
		} else {
			self.room.text = ""
		}
		
		// Indicate current and next lessons
		self.highlightCurrentLesson(from: data)
		self.highlightNextLesson(from: data)
	}

	private func highlightCurrentLesson(from data: Student.TimetableEntry) {
		if Date().fallsIn(lower: data.startTime, upper: data.endTime) {
			self.nextCurrentLesson.backgroundColor = #colorLiteral(red: 0.05725816637, green: 0.1552535594, blue: 0.4649428725, alpha: 1)
			self.nextCurrentLesson.text = "Now"
			self.nextCurrentLesson.alpha = 1
		} else {
			self.nextCurrentLesson.alpha = 0
		}
	}

	private func highlightNextLesson(from data: Student.TimetableEntry) {
		guard let nextLesson = Student.current.studentProfile?.timetable.sorted(by: {$0.day < $1.day}).filter({$0.startTime > Date()}).first else { return }
		
		if data == nextLesson {
			self.nextCurrentLesson.backgroundColor = #colorLiteral(red: 0.211450547, green: 0.4082797468, blue: 0.5572861433, alpha: 1)
			self.nextCurrentLesson.text = "Next"
			self.nextCurrentLesson.alpha = 1
		} else {
			self.nextCurrentLesson.alpha = 0
		}
	}
	
}
