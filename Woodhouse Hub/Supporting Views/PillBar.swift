//
//  PillBar.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 01/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

protocol PillBarDelegate {
	
	func pillSectionUpdated()
	
}

@IBDesignable
class PillBar: RoundView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var timetableButton: UIButton!
	@IBOutlet weak private var attendanceButton: UIButton!
	@IBOutlet weak private var markbookButtton: UIButton!
	@IBOutlet weak private var otherButton: UIButton!
	
	// MARK: Properties
	var delegate: PillBarDelegate? = nil
	var currentSelection: PillItem = .timetable {
		didSet {
			self.updateSelectedItem()
		}
	}
	
	// MARK: Enums
	enum PillItem {
		case timetable
		case attendance
		case markbook
		case other
	}
	
	// MARK: Methods
	private func updateSelectedItem() {
		switch self.currentSelection {
		case .timetable:
			self.timetableButton.backgroundColor = #colorLiteral(red: 0.01392052043, green: 0.1597468555, blue: 0.4854152203, alpha: 1)
			self.timetableButton.setTitleColor(.white, for: .normal)
			
			self.attendanceButton.backgroundColor = .background
			self.attendanceButton.setTitleColor(#colorLiteral(red: 0.137254902, green: 0.2941176471, blue: 0.6, alpha: 1), for: .normal)
			self.markbookButtton.backgroundColor = .background
			self.markbookButtton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
			self.otherButton.backgroundColor = .background
			self.otherButton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
		case .attendance:
			self.attendanceButton.backgroundColor = #colorLiteral(red: 0.01392052043, green: 0.1597468555, blue: 0.4854152203, alpha: 1)
			self.attendanceButton.setTitleColor(.white, for: .normal)
			
			self.timetableButton.backgroundColor = .background
			self.timetableButton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
			self.markbookButtton.backgroundColor = .background
			self.markbookButtton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
			self.otherButton.backgroundColor = .background
			self.otherButton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
		case .markbook:
			self.markbookButtton.backgroundColor = #colorLiteral(red: 0.01392052043, green: 0.1597468555, blue: 0.4854152203, alpha: 1)
			self.markbookButtton.setTitleColor(.white, for: .normal)
			
			self.timetableButton.backgroundColor = .background
			self.timetableButton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
			self.attendanceButton.backgroundColor = .background
			self.attendanceButton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
			self.otherButton.backgroundColor = .background
			self.otherButton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
		case .other:
			self.otherButton.backgroundColor = #colorLiteral(red: 0.01392052043, green: 0.1597468555, blue: 0.4854152203, alpha: 1)
			self.otherButton.setTitleColor(.white, for: .normal)
			
			self.timetableButton.backgroundColor = .background
			self.timetableButton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
			self.attendanceButton.backgroundColor = .background
			self.attendanceButton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
			self.markbookButtton.backgroundColor = .background
			self.markbookButtton.setTitleColor(#colorLiteral(red: 0.1373262405, green: 0.2947477698, blue: 0.601218462, alpha: 1), for: .normal)
		}
		
		self.delegate?.pillSectionUpdated()
	}
	
	// MARK: IBActions
	@IBAction private func timetableSelected(_ sender: UIButton) {
		self.currentSelection = .timetable
	}
	
	@IBAction private func attendanceSelected(_ sender: UIButton) {
		self.currentSelection = .attendance
	}
	
	@IBAction private func markbookSelected(_ sender: UIButton) {
		self.currentSelection = .markbook
	}
	
	@IBAction private func otherSelected(_ sender: UIButton) {
		self.currentSelection = .other
	}
	
}
