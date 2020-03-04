//
//  ExamCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 19/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class ExamCell: RoundUICollectionViewCell {
	
	// MARK: IBOutlets
	@IBOutlet weak var paper: UILabel!
	@IBOutlet weak var paperCode: UILabel!
	@IBOutlet weak var startTime: UILabel!
	@IBOutlet weak var room: UILabel!
	@IBOutlet weak var seat: UILabel!
	
	// MARK: Methods
	func setupCell(from data: Student.ExamEntry) {
		self.paper.text = data.paperName
		self.paperCode.text = "\(data.awardingBody) (\(data.entryCode))"
		self.room.text = "Room: \(data.room)"
		self.seat.text = "Seat: \(data.seat)"
		self.startTime.text = "\(data.startTime.prettify()) (\(data.endTime.timeIntervalSince(data.startTime).stringFromTimeInterval()))"
	}
	
}
