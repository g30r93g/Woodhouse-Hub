//
//  AttendanceView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 01/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class AttendanceView: RoundTopView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var calendarCollection: UICollectionView!
	@IBOutlet weak private var attendanceEntryCollection: UICollectionView!
	
	// MARK: Properties
	private var weekBeginnings: [Date] = []
	private var selectedDate = Date().getMondayOfWeek()
	
	// MARK: Override Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
	}
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "dashboard.gatheredAttendance"), object: nil)
	}
	
	private func setupView() {
		self.registerForNotifications()
		self.updateView()
	}
	
	func setupWeekBeginnings() {
		if let attendance = Student.current.getAttendance()?.detailedAttendance {
			self.weekBeginnings = attendance.map({$0.date.getMondayOfWeek()}).removeDuplicates().sorted().reversed()
		}
	}
	
	@objc private func updateView() {
		guard Student.current.getAttendance()?.detailedAttendance != nil else { return }
		self.setupWeekBeginnings()
		
		self.calendarCollection.reloadData()
		self.attendanceEntryCollection.reloadData()
	}
	
}

extension AttendanceView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == self.calendarCollection {
			return self.weekBeginnings.count * 5
		} else if collectionView == self.attendanceEntryCollection {
			guard let attendance = Student.current.getAttendance()?.detailedAttendance else { return 0 }
			
			return attendance.filter({$0.date == self.selectedDate}).count
		} else {
			return 0
		}
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == self.calendarCollection {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! CalendarCell
			var data: Date {
				// Determine week beginning
				let weekBeginning = self.weekBeginnings[indexPath.item / 5]
				
				return weekBeginning.addDays(value: 4 - (indexPath.item % 5))
			}
			
			cell.setupCell(with: data, selectedDate: self.selectedDate)

			return cell
		} else if collectionView == self.attendanceEntryCollection {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Attendance", for: indexPath) as! AttendanceCell

			guard let attendance = Student.current.getAttendance()?.detailedAttendance else { return cell }
			let data = attendance.filter({$0.date == self.selectedDate})[indexPath.item]

			cell.setupCell(from: data)

			return cell
		} else {
			return UICollectionViewCell()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == self.calendarCollection {
			let cell = collectionView.cellForItem(at: indexPath) as! CalendarCell
			
			self.selectedDate = cell.date
			
			collectionView.visibleCells.forEach({($0 as! CalendarCell).deselect()})
			cell.select()
			
			self.attendanceEntryCollection.reloadData()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == self.calendarCollection {
			return CGSize(width: (collectionView.bounds.width - 40) / 5, height: 80)
		} else if collectionView == self.attendanceEntryCollection {
			return CGSize(width: collectionView.bounds.width, height: 100)
		} else {
			return .zero
		}
	}

}
