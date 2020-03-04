//
//  EventCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 19/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class EventCell: RoundUICollectionViewCell {
	
	// MARK: IBOutlets
	@IBOutlet weak private var title: UILabel!
	@IBOutlet weak private var eventDescription: UILabel!
	@IBOutlet weak private var date: UILabel!
	@IBOutlet weak private var fee: UILabel!
	@IBOutlet weak private var placesAvailable: UILabel!
	
	// MARK: Methods
	func setupCell(from data: WoodleInteractor.Event) {
		self.title.text = data.title
		self.eventDescription.text = data.description
		self.date.text = "\(data.startDate.prettify()) to \(data.endDate.prettify())"
		
		if data.fee != 0 {
			self.fee.text = "£\(String(format: "%.2f", data.fee))"
		} else {
			self.fee.text = "Free Event"
		}
		
		if let upcomingEvents = WoodleInteractor.shared.getUpcomingEvents(), upcomingEvents.contains(data) {
			if let placesRemaining = data.placesRemaining, let placesAvailable = data.totalPlaces {
				if placesRemaining == 0 {
					self.placesAvailable.text = "No Places Remaining (\(placesAvailable) Available)"
				} else {
					self.placesAvailable.text = "\(placesRemaining) Places Remaining (\(placesAvailable) Available)"
				}
			} else {
				self.placesAvailable.text = "Unlimited Places Available"
			}
		} else {
			self.placesAvailable.text = "Ask college staff about availability"
		}
	}
	
}
