//
//  ExamCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 19/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class ExamCell: UITableViewCell {
	
	// MARK: IBOutlets
	@IBOutlet weak var paper: UILabel!
	@IBOutlet weak var paperCode: UILabel!
	@IBOutlet weak var room: UILabel!
	@IBOutlet weak var seat: UILabel!
	@IBOutlet weak var startTime: UILabel!
	@IBOutlet weak var duration: UILabel!
	
	// MARK: Methods
	func setupCell(from data: Student.ExamEntry, index: Int) {
		self.reset()
		if (index % 2) == 1 { self.applyAlternateBackground() }
		
		self.paper.text = data.paperName
		self.paperCode.text = data.awardingBody
		self.room.text = "Room: \(data.room)"
		self.seat.text = "Seat: \(data.seat)"
		self.startTime.text = "Start Time: \(data.startTime.prettify())"
		self.duration.text = "Duration: \(data.endTime.timeIntervalSince(data.startTime).stringFromTimeInterval())"
	}
	
	private func reset() {
		self.backgroundColor = UIColor(named: "Cell")
	}
	
	private func applyAlternateBackground() {
		self.backgroundColor = UIColor(named: "Alternate Cell")
	}
	
}
