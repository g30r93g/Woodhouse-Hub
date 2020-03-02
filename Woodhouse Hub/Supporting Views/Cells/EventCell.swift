//
//  EventCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 19/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
	
	// MARK: IBOutlets
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var desc: UILabel!
	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var fee: UILabel!
	@IBOutlet weak var placesAvailable: UILabel!
	
	// MARK: Methods
	func setupCell(from data: WoodleInteractor.Event, index: Int) {
		self.reset()
		if (index % 2) == 1 { self.applyAlternateBackground() }
		
		self.title.text = data.title
		self.desc.text = data.description
		self.date.text = "\(data.startDate.prettify()) to \(data.endDate.prettify())"
		
		if data.fee != 0 {
			self.fee.text = "Fee: £\(String(format: "%.2f", data.fee))"
		} else {
			self.fee.text = "Fee: Free"
		}
		
		if WoodleInteractor.shared.upcomingEvents.contains(data) {
			if let placesRemaining = data.placesRemaining, let placesAvailable = data.totalPlaces {
				self.placesAvailable.text = "Places Available: \(placesRemaining)/\(placesAvailable)"
			} else {
				self.placesAvailable.text = "Unlimited Places Available"
			}
		}
	}
	
	private func reset() {
		self.backgroundColor = UIColor(named: "Cell")
	}
	
	private func applyAlternateBackground() {
		self.backgroundColor = UIColor(named: "Alternate Cell")
	}
	
}
