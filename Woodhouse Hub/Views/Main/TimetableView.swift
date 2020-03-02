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
	
	// MARK: Overriden Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
		self.registerForNotifications()
	}
	
	// MARK: Properties
	private var isShowingCurrentDay = true
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "dashboard.gatheredTimetable"), object: nil)
	}
	
	private func setupView() {
		DispatchQueue.main.async {
			self.daySelector.alpha = 0
			
			switch Date().dayOfWeek() {
			case 1,2,3,4,5:
				self.daySelector.selectedSegmentIndex = Date().dayOfWeek() - 1
			default:
				self.daySelector.selectedSegmentIndex = 0
			}
		}
		
		self.updateView()
	}
	
	@objc private func updateView() {
		self.updateTimetable()
		self.updateTimetableAppearance()
		self.updateSummaryLabel()
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
