//
//  CalendarCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 01/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class CalendarCell: RoundUICollectionViewCell{
	
	// MARK: IBOutlets
	@IBOutlet weak private var day: UILabel!
	@IBOutlet weak private var month: UILabel!
	
	// MARK: Properties
	private(set) var date: Date!
	
	// MARK: Methods
	func setupCell(with date: Date, selectedDate: Date) {
		self.date = date
		
		let dateComponents = date.dateComponents()
		// Setup day
		self.day.text = "\(dateComponents.day ?? 0)"
		
		// Setup month
		switch dateComponents.month {
		case 1:
			self.month.text = "Jan"
		case 2:
			self.month.text = "Feb"
		case 3:
			self.month.text = "Mar"
		case 4:
			self.month.text = "Apr"
		case 5:
			self.month.text = "May"
		case 6:
			self.month.text = "Jun"
		case 7:
			self.month.text = "Jul"
		case 8:
			self.month.text = "Aug"
		case 9:
			self.month.text = "Sept"
		case 10:
			self.month.text = "Oct"
		case 11:
			self.month.text = "Nov"
		case 12:
			self.month.text = "Dec"
		default:
			break
		}
		
		// Setup appearance
		if date == selectedDate {
			self.select()
		} else {
			self.deselect()
		}
	}
	
	public func select() {
		self.day.textColor = .black
		self.backgroundColor = .white
	}
	
	public func deselect() {
		self.day.textColor = .white
		self.backgroundColor = .systemGray3
	}
	
}
