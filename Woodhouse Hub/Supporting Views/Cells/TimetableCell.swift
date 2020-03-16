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
	@IBOutlet weak private var lessonContainerView: UIView!
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
		self.lessonContainerView.backgroundColor = #colorLiteral(red: 0.05882352941, green: 0.1568627451, blue: 0.4666666667, alpha: 1)
		self.nextCurrentLesson.alpha = 0
		
		self.unhighlightPastLesson(from: data)
		self.highlightCurrentLesson(from: data)
		self.highlightNextLesson(from: data)
	}
	
	private func unhighlightPastLesson(from data: Student.TimetableEntry) {
//		print("[TimetableCell] \(data.endTime) < \(Date()) == \(data.endTime < Date())")
		if data.endTime < Date() {
			self.lessonContainerView.backgroundColor = #colorLiteral(red: 0.462745098, green: 0.5529411765, blue: 0.6745098039, alpha: 1)
		}
	}

	private func highlightCurrentLesson(from data: Student.TimetableEntry) {
//		print("[TimetableCell] \(data.startTime) < \(Date()) < \(data.endTime) == \(Date().fallsIn(lower: data.startTime, upper: data.endTime))")
		if Date().fallsIn(lower: data.startTime, upper: data.endTime) {
			self.lessonContainerView.backgroundColor = #colorLiteral(red: 0.1490196078, green: 0.4156862745, blue: 0.7176470588, alpha: 1)
			self.nextCurrentLesson.text = "\(Int(data.endTime.timeIntervalSince(Date()) / 60)) mins left"
			self.nextCurrentLesson.alpha = 1
		}
	}

	private func highlightNextLesson(from data: Student.TimetableEntry) {
		guard let nextLesson = Student.current.studentProfile?.timetable.sorted(by: {$0.day < $1.day}).filter({$0.startTime > Date()}).first else { return }
		
//		print("[TimetableCell] \(data) = \(nextLesson) == \(data == nextLesson)")
		if data == nextLesson {
			self.lessonContainerView.backgroundColor = #colorLiteral(red: 0.1058823529, green: 0.2862745098, blue: 0.5921568627, alpha: 1)
			self.nextCurrentLesson.text = "Next"
			self.nextCurrentLesson.alpha = 1
		}
	}
	
}
