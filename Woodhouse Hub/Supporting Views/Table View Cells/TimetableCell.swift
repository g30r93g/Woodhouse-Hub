//
//  TimetableCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 17/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class TimetableCell: UITableViewCell {
	
	// MARK: IBOutlets
	@IBOutlet weak var lessonName: UILabel!
	@IBOutlet weak var lessonTime: UILabel!
	@IBOutlet weak var teacher: UILabel?
	@IBOutlet weak var room: UILabel!
	
	// MARK: Methods
	func setupCell(from data: Student.TimetableEntry, index: Int) {
		self.reset(index)
		
		self.highlightCurrentLesson(from: data)
		self.highlightNextLesson(from: data)
		
		self.lessonName.text = data.name
		self.lessonTime.text = "\(data.startTime.time()) - \(data.endTime.time())"
		
		if let room = data.room {
			self.room.text = "Room \(room)"
		} else {
			self.room.text = ""
		}
		
		guard let teacherLabel = self.teacher else { return }
		if let teacher = data.teacher {
			teacherLabel.text = teacher
		} else {
			teacherLabel.text = ""
		}
	}
	
	private func reset(_ index: Int) {
		if (index % 2) == 1 {
			self.contentView.backgroundColor = UIColor(named: "Alternate Cell")!
		} else {
			self.contentView.backgroundColor = UIColor(named: "Cell")!
		}
		
		self.lessonName.textColor = .label
		self.lessonTime.textColor = .label
		self.room.textColor = .label
		
		guard let teacherLabel = self.teacher else { return }
		teacherLabel.textColor = .label
	}
	
	private func highlightCurrentLesson(from data: Student.TimetableEntry) {
		if Date().fallsIn(lower: data.startTime, upper: data.endTime) {
			self.contentView.backgroundColor = #colorLiteral(red: 0.05725816637, green: 0.1552535594, blue: 0.4649428725, alpha: 1)
			self.lessonName.textColor = .white
			self.lessonTime.textColor = .white
			self.room.textColor = .white

			guard let teacherLabel = self.teacher else { return }
			teacherLabel.textColor = .white
		}
	}
	
	private func highlightNextLesson(from data: Student.TimetableEntry) {
		guard let nextLesson = Student.current.studentProfile?.timetable.sorted(by: {$0.day < $1.day}).filter({$0.startTime > Date()}).first else { return }
		
		if data == nextLesson {
			self.contentView.backgroundColor = #colorLiteral(red: 0.211450547, green: 0.4082797468, blue: 0.5572861433, alpha: 1)
			self.lessonName.textColor = .white
			self.lessonTime.textColor = .white
			self.room.textColor = .white
			
			guard let teacherLabel = self.teacher else { return }
			teacherLabel.textColor = .white
		}
	}
	
}
