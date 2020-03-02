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
	private var earliestDate: Date?
	private var dateSelected = Date()
	
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
	
	@objc private func updateView() {
		guard let attendance = Student.current.getAttendance()?.detailedAttendance.sorted() else { return }
		guard let earliestAttendance = attendance.first?.date else { return }
		self.earliestDate = earliestAttendance
		
		self.calendarCollection.reloadData()
		self.attendanceEntryCollection.reloadData()
	}
	
}

// FIXME
//extension AttendanceView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//
//	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		if collectionView == self.attendanceEntryCollection {
//		guard let attendance = Student.current.getAttendance()?.detailedAttendance else { return 0 }
//
//		return attendance.filter({$0.date == self.dateSelected}).count
//		} else if collectionView == self.calendarCollection {
//			guard let date = self.earliestDate else { return 0 }
//			return Date().numberOfDays(to: date)
//		} else {
//			return 0
//		}
//	}
//
//	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//		if collectionView == self.attendanceEntryCollection {
//			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Attendance", for: indexPath) as! AttendanceCell
//
//			guard let attendance = Student.current.getAttendance()?.detailedAttendance else { return cell }
//
//			let data = attendance.filter({$0.date == self.dateSelected})[indexPath.item]
//
//			cell.setupCell(from: data)
//
//			return cell
//		} else if collectionView == self.calendarCollection {
//			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! CalendarCell
//
//			let dateToDisplay
//
//			return cell
//		} else {
//			return UICollectionViewCell()
//		}
//	}
//
//}

extension AttendanceView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		return UICollectionViewCell()
	}
	
}
