//
//  TimetableView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 01/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

@IBDesignable
class TimetableView: RoundTopView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var summaryLabel: UILabel!
	@IBOutlet weak private var showFullTimtetable: UIButton!
	@IBOutlet weak private var daySelector: UISegmentedControl!
	@IBOutlet weak private var timetableDaySelectorSeparation: NSLayoutConstraint!
	@IBOutlet weak private var timetable: UICollectionView!
	
	// MARK: Properties
	private var refreshTimer: Timer!
	
	// MARK: Overriden Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
		self.registerForNotifications()
	}
	
	// MARK: Properties
	var delegate: ShowProtocol? = nil
	private var isShowingCurrentDay = true
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "dashboard.gatheredTimetable"), object: nil)
	}
	
	private func setupView() {
		self.refreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (_) in
			print("[TimetableView] Refreshing from timer.")
			self.timetable.reloadData()
			})
		
		DispatchQueue.main.async {
			self.daySelector.alpha = 0
			
			switch Date().dayOfWeek() {
			case 1,2,3,4,5:
				self.daySelector.selectedSegmentIndex = Date().dayOfWeek() - 1
			default:
				self.daySelector.selectedSegmentIndex = 0
			}
		}
		
		self.attachLongPressRecogniser()
		
		self.updateView()
	}
	
	private func attachLongPressRecogniser() {
		let deleteLongPress = UILongPressGestureRecognizer(target: self, action: #selector(lessonOptionsHandler(gesture:)))
		deleteLongPress.minimumPressDuration = 0.3
		deleteLongPress.delaysTouchesBegan = true
		deleteLongPress.delegate = self
		self.timetable.addGestureRecognizer(deleteLongPress)
	}
	
	@objc private func lessonOptionsHandler(gesture: UILongPressGestureRecognizer) {
		guard gesture.state == .began else { return }
		
		let pointPressed = gesture.location(in: self.timetable)
		
		if let indexPath = self.timetable.indexPathForItem(at: pointPressed) {
			guard let timetable = Student.current.getTimetable() else { return }
			let data = timetable.filter({$0.day == self.daySelector.selectedSegmentIndex + 1})[indexPath.item]
			
			if data.name.contains("Lunch") || data.name.contains("Learning Zone Study") { return }
			
			// Show list of options
			let alert = UIAlertController(title: "Options for \(data.name)", message: nil, preferredStyle: .actionSheet)
			
			let absense = UIAlertAction(title: "Notify Absence", style: .default) { (action) in
				let body = """
				Dear Attendance,

				Please accept this written notification of my absence on the \(data.startTime.date()) at \(data.startTime.time())
				This is due to
				
				Regards,
				\(Student.current.getDetails()?.name ?? "Student") (\(Student.current.getDetails()?.id ?? "Student ID"))
				"""
				
				var teacherEmail: String? {
					if let teacherCode = data.teacherCode {
						return WoodleInteractor.shared.getStaffGallery()?.first(where: {teacherCode == $0.code})?.email
					} else {
						return nil
					}
				}
				
				var recipients: [String] = ["attendance@woodhouse.ac.uk"]
				if let teacherEmail = teacherEmail {
					recipients.append(teacherEmail)
				}

				do {
					let mail = MailingDelegate(subject: "Notifcation of Absence", body: body, recipients: recipients)
					try mail.composeEmail()
				} catch {
					return
				}
			}
			
			let lateness = UIAlertAction(title: "Notify Lateness", style: .default) { (action) in
				let body = """
				Dear \(data.teacher ?? "Teacher"),

				Please accept this written notification of my lateness for your lesson on the \(data.startTime.date()) at \(data.startTime.time())
				This is due to
				
				Regards,
				\(Student.current.getDetails()?.name ?? "Student") (\(Student.current.getDetails()?.id ?? "Student ID"))
				"""
				
				var teacherEmail: String? {
					if let teacherCode = data.teacherCode {
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
					let mail = MailingDelegate(subject: "Notifcation of Absence", body: body, recipients: recipients)
					try mail.composeEmail()
				} catch {
					return
				}
			}
			
			let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
				alert.dismiss(animated: true, completion: nil)
			}
			
			alert.addAction(absense)
			alert.addAction(lateness)
			alert.addAction(cancel)
			
			self.delegate?.showAlert(alert)
		}
	}
	
	@objc private func updateView() {
		self.updateTimetable()
		self.updateTimetableAppearance()
		self.updateSummaryLabel()
	}
	
	public func stopUpdate() {
		self.refreshTimer.invalidate()
	}
	
	private func updateSummaryLabel() {
		if self.isShowingCurrentDay {
			if Date().dayOfWeek() == 6 || Date().dayOfWeek() == 6 {
				self.summaryLabel.text = "Monday's Timetable"
			} else {
				self.summaryLabel.text = "Today's Timetable"
			}
		} else {
			switch self.daySelector.selectedSegmentIndex {
			case 0:
				self.summaryLabel.text = "Monday's Timetable"
			case 1:
				self.summaryLabel.text = "Tuesday's Timetable"
			case 2:
				self.summaryLabel.text = "Wednesday's Timetable"
			case 3:
				self.summaryLabel.text = "Thursday's Timetable"
			case 4:
				self.summaryLabel.text = "Friday's Timetable"
			default:
				self.summaryLabel.text = "Timetable"
			}
		}
	}
	
	private func updateTimetable() {
		DispatchQueue.main.async {
			self.timetable.reloadData()
		}
	}
	
	private func updateTimetableAppearance() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2) {
				if let timetable = Student.current.studentProfile?.timetable {
					self.showFullTimtetable.alpha = timetable.count > 0 ? 1 : 0
				} else {
					self.showFullTimtetable.alpha = 0
				}
			}
		}
	}
	
	private func updateTimetableDisplayMode() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.4) {
				self.timetableDaySelectorSeparation.constant = self.isShowingCurrentDay ? 5 : 45
				self.daySelector.alpha = self.isShowingCurrentDay ? 0 : 1
				self.showFullTimtetable.setTitle(self.isShowingCurrentDay ? "Show All" : "Show Today", for: .normal)
				self.layoutIfNeeded()
				
				if self.isShowingCurrentDay {
					self.daySelector.selectedSegmentIndex = Date().dayOfWeek() - 1
				}
			}
		}
		
		self.updateView()
	}
	
	// MARK: IBActions
	@IBAction private func showFullTimetableTapped(_ sender: UIButton) {
		self.isShowingCurrentDay = !self.isShowingCurrentDay
		self.updateTimetableDisplayMode()
	}
	
	@IBAction func daySelectorUpdated(_ sender: UISegmentedControl) {
		self.updateView()
	}
	
}

extension TimetableView: UIGestureRecognizerDelegate { }

extension TimetableView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let timetable = Student.current.getTimetable() else { return 0 }
		
		return timetable.filter({$0.day == self.daySelector.selectedSegmentIndex + 1}).count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimetableEntry", for: indexPath) as! TimetableCell
		
		guard let timetable = Student.current.getTimetable() else { return cell }
		
		let data = timetable.filter({$0.day == self.daySelector.selectedSegmentIndex + 1})[indexPath.item]
		
		cell.setupCell(from: data)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.width, height: 80)
	}
	
}
