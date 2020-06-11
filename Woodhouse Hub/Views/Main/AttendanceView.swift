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
	var delegate: ShowProtocol? = nil
	private var weekBeginnings: [Date] = []
	private var selectedDate = Date().getMondayOfWeek()
	
	// MARK: Override Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
	}
	
	// MARK: Methods
	private func attachLongPressRecogniser() {
		let deleteLongPress = UILongPressGestureRecognizer(target: self, action: #selector(attendanceOptionsHandler(gesture:)))
		deleteLongPress.minimumPressDuration = 0.3
		deleteLongPress.delaysTouchesBegan = true
		deleteLongPress.delegate = self
		self.attendanceEntryCollection.addGestureRecognizer(deleteLongPress)
	}
	
	@objc private func attendanceOptionsHandler(gesture: UILongPressGestureRecognizer) {
		guard gesture.state == .began else { return }
		
		let pointPressed = gesture.location(in: self.attendanceEntryCollection)
		
		if let indexPath = self.attendanceEntryCollection.indexPathForItem(at: pointPressed) {
			guard let attendance = Student.current.getAttendance()?.detailedAttendance else { return }
			let data = attendance.filter({$0.date == self.selectedDate})[indexPath.item]
			let className = data.correspondingTimetableEntry?.name ?? data.classIdentifier
			
			let alert = UIAlertController(title: "Options for \(className)", message: nil, preferredStyle: .actionSheet)
			
			let challenge = UIAlertAction(title: "Challenge Attendance Mark", style: .default) { (_) in
				let body = """
				Dear \(data.correspondingTimetableEntry?.teacher ?? "Teacher"),

				I am writing regarding our lesson on \(data.date.extendedDate()). You marked me as \(data.prettyAttendanceMark()). However, I believe I should have been marked ________.
				Please could you update this?
				
				Many thanks,
				\(Student.current.getDetails()?.name ?? "Student") (\(Student.current.getDetails()?.id ?? "Student ID"))
				"""
				
				var teacherEmail: String? {
					if let teacherCode = data.correspondingTimetableEntry?.teacher {
						return WoodleInteractor.shared.getStaffGallery()?.first(where: {teacherCode == $0.code})?.email
					} else {
						return nil
					}
				}
				
				var recipients: [String] = []
				if let teacherEmail = teacherEmail {
					recipients.append(teacherEmail)
				}
				
				do {
					let mail = MailingDelegate(subject: "Incorrect Attendance Mark for Lesson on \(data.date.extendedDate())", body: body, recipients: recipients)
					try mail.composeEmail()
				} catch {
					return
				}
			}
			
			let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
				alert.dismiss(animated: true, completion: nil)
			}
			
			alert.addAction(challenge)
			alert.addAction(cancel)
			
			self.delegate?.showAlert(alert)
		}
	}
	
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "dashboard.gatheredAttendance"), object: nil)
	}
	
	private func setupView() {
		self.registerForNotifications()
		self.attachLongPressRecogniser()
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

extension AttendanceView: UIGestureRecognizerDelegate { }

extension AttendanceView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		if collectionView == self.calendarCollection {
			return self.weekBeginnings.count
		} else {
			return 1
		}
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == self.calendarCollection {
			return 5
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
				let weekBeginning = self.weekBeginnings[indexPath.section]
				
				return weekBeginning.addDays(value: indexPath.row)
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
