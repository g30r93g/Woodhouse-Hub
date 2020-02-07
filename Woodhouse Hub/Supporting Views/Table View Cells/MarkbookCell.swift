//
//  MarkbookCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 21/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class MarkbookCell: UITableViewCell {
		
	// MARK: IBOutlets
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var grade: UILabel!
	@IBOutlet weak var percent: UILabel!
	@IBOutlet weak var markingType: UILabel!
	@IBOutlet weak var weighting: UILabel!
	
	// MARK: Methods
	func setupCell(from data: Student.MarkbookGrade, index: Int) {
		self.reset()
		if (index % 2) == 1 { self.applyAlternateBackground() }
		
		self.name.text = data.name
		self.date.text = data.date.date()
		self.markingType.text = "Marking Type: \(data.markingType)"
		self.weighting.text = "Weighting: \(data.weighting)"
		
		if data.mark == "-" {
			if data.date > Date() {
				self.grade.text = "Test Scheduled"
				self.percent.text = ""
			} else {
				self.grade.text = "Grade Pending"
				self.percent.text = ""
			}
		} else if let mark = Int(data.mark), mark == data.percentage {
			self.grade.text = ""
			self.percent.text = "Percentage: \(data.percentage)%"
		} else {
			self.grade.text = "Grade: \(data.mark)"
			self.percent.text = "Percentage: \(data.percentage)%"
		}
	}
	
	private func reset() {
		self.backgroundColor = UIColor(named: "Cell")
	}
	
	private func applyAlternateBackground() {
		self.backgroundColor = UIColor(named: "Alternate Cell")
	}
		
}
