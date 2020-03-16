//
//  MarkbookCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 21/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class MarkbookCell: RoundUICollectionViewCell {
		
	// MARK: IBOutlets
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var grade: UILabel!
	
	// MARK: Methods
	func setupCell(from data: Student.MarkbookGrade) {
		self.name.text = data.name
		self.date.text = data.date.date()
		
		if data.mark == "-" {
			if data.date > Date() {
				self.grade.text = "Test Scheduled"
			} else {
				self.grade.text = "Grade Pending"
			}
		} else if data.mark == "Absent" {
			self.grade.text = "Absent During Test"
		} else if let mark = Int(data.mark), mark == data.percentage {
			self.grade.text = "Percentage: \(data.percentage)%"
		} else {
			self.grade.text = "Grade: \(data.mark) (\(data.percentage)%)"
		}
	}
		
}
