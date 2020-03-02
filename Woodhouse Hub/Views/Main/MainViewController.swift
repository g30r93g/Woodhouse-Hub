//
//  MainViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 01/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak private var pillBar: PillBar!
	@IBOutlet weak private var timetableView: TimetableView!
	@IBOutlet weak private var attendanceView: AttendanceView!
	@IBOutlet weak private var markbookView: MarkbookView!
	@IBOutlet weak private var otherView: OtherView!
	
	// MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		self.setupView()
		self.showTimetableView()
    }
	
	// MARK: Methods
	private func setupView() {
		self.pillBar.delegate = self
		self.markbookView.delegate = self
	}
	
	private func showTimetableView() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.attendanceView.alpha = 0
				self.timetableView.alpha = 1
				self.markbookView.alpha = 0
				self.otherView.alpha = 0
			})
		}
	}
	
	private func showAttendanceView() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.attendanceView.alpha = 1
				self.timetableView.alpha = 0
				self.markbookView.alpha = 0
				self.otherView.alpha = 0
			})
		}
	}
	
	private func showMarkbookView() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.attendanceView.alpha = 0
				self.timetableView.alpha = 0
				self.markbookView.alpha = 1
				self.otherView.alpha = 0
			})
		}
	}
	
	private func showOtherView() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.attendanceView.alpha = 0
				self.timetableView.alpha = 0
				self.markbookView.alpha = 0
				self.otherView.alpha = 1
			})
		}
	}

}

extension MainViewController: PillBarDelegate {
	
	func pillSectionUpdated() {
		switch self.pillBar.currentSelection {
		case .timetable:
			self.showTimetableView()
		case .attendance:
			self.showAttendanceView()
		case .markbook:
			self.showMarkbookView()
		case .other:
			self.showOtherView()
		}
	}
	
}

extension MainViewController: MarkbookProtocol {
	
	func changeSubjectRequiresDisplay(alert: UIAlertController){
		self.present(alert, animated: true)
	}
	
}
