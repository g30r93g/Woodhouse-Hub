//
//  MainViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 01/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

protocol ShowProtocol {
	
	func showRequested(_ view: MainViewController.OtherViews)
	func signOutRequested()
	func showDisclaimer()
	
}

protocol DismissProtocol {
	
	func dismissRequested()
	
}

class MainViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak private var pillBar: PillBar!
	@IBOutlet weak private var timetableView: TimetableView!
	@IBOutlet weak private var attendanceView: AttendanceView!
	@IBOutlet weak private var markbookView: MarkbookView!
	@IBOutlet weak private var otherView: OtherView!
	@IBOutlet weak private var ucasPredictionsView: UCASPredictionsView!
	@IBOutlet weak private var examTimetableView: ExamTimetableView!
	@IBOutlet weak private var woodleEventsView: WoodleEventsView!
	@IBOutlet weak private var studentBulletinView: StudentBulletinView!
	@IBOutlet weak private var pastoralView: PastoralView!
	
	// MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		self.setupView()
		self.showTimetableView()
    }
	
	// MARK: Enums
	enum OtherViews {
		case ucas
		case examTimetable
		case woodleEvents
		case studentBulletin
		case pastoral
	}
	
	// MARK: Methods
	private func setupView() {
		self.pillBar.delegate = self
		self.markbookView.delegate = self
		self.otherView.delegate = self
		self.ucasPredictionsView.delegate = self
		self.examTimetableView.delegate = self
		self.woodleEventsView.delegate = self
		self.studentBulletinView.delegate = self
		self.pastoralView.delegate = self
	}
	
	private func signOut() {
		let alert = UIAlertController(title: "Confirm Sign Out", message: "The app will crash to reset completely.", preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
		alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
			Settings().signOut()
			self.timetableView.stopUpdate()
			
			self.performSegue(withIdentifier: "Sign Out", sender: nil)
		}))
		
		self.present(alert, animated: true, completion: nil)
	}
	
	internal func showDisclaimerMessage() {
		let message = "This application has been made with the intention of aggregating Woodhouse College's Learning Management and student facing systems. This application is a solution to the slow, unintuitive and separated systems used by Woodhouse College. This application leverages use of local storage on the student's device. The student's timetable, details and image is stored, as well as generating local notifications for lessons. This application is in compliance with GDPR, since it piggybacks off of existing systems. Students can only access their information with their login details, unique to them. I am a student of the college and have no affiliation directly with the development teams responsible for Dashboard, Woodle, ReportServer or any other services used by the college. No harm is intended to the developers of the original systems."
		let alert = UIAlertController(title: "Disclaimer", message: message, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		
		self.present(alert, animated: true, completion: nil)
	}
	
	private func showTimetableView() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.attendanceView.alpha = 0
				self.timetableView.alpha = 1
				self.markbookView.alpha = 0
				self.otherView.alpha = 0
				self.ucasPredictionsView.alpha = 0
				self.examTimetableView.alpha = 0
				self.woodleEventsView.alpha = 0
				self.studentBulletinView.alpha = 0
				self.pastoralView.alpha = 0
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
				self.ucasPredictionsView.alpha = 0
				self.examTimetableView.alpha = 0
				self.woodleEventsView.alpha = 0
				self.studentBulletinView.alpha = 0
				self.pastoralView.alpha = 0
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
				self.ucasPredictionsView.alpha = 0
				self.examTimetableView.alpha = 0
				self.woodleEventsView.alpha = 0
				self.studentBulletinView.alpha = 0
				self.pastoralView.alpha = 0
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
				self.ucasPredictionsView.alpha = 0
				self.examTimetableView.alpha = 0
				self.woodleEventsView.alpha = 0
				self.studentBulletinView.alpha = 0
				self.pastoralView.alpha = 0
			})
		}
	}
	
	private func showUCASPredictionsView() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.attendanceView.alpha = 0
				self.timetableView.alpha = 0
				self.markbookView.alpha = 0
				self.otherView.alpha = 0
				self.ucasPredictionsView.alpha = 1
				self.examTimetableView.alpha = 0
				self.woodleEventsView.alpha = 0
				self.studentBulletinView.alpha = 0
				self.pastoralView.alpha = 0
			})
		}
	}
	
	private func showExamTimetableView() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.attendanceView.alpha = 0
				self.timetableView.alpha = 0
				self.markbookView.alpha = 0
				self.otherView.alpha = 0
				self.ucasPredictionsView.alpha = 0
				self.examTimetableView.alpha = 1
				self.woodleEventsView.alpha = 0
				self.studentBulletinView.alpha = 0
				self.pastoralView.alpha = 0
			})
		}
	}
	
	private func showWoodleEventsView() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.attendanceView.alpha = 0
				self.timetableView.alpha = 0
				self.markbookView.alpha = 0
				self.otherView.alpha = 0
				self.ucasPredictionsView.alpha = 0
				self.examTimetableView.alpha = 0
				self.woodleEventsView.alpha = 1
				self.studentBulletinView.alpha = 0
				self.pastoralView.alpha = 0
			})
		}
	}
	
	private func showStudentBulletin() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.attendanceView.alpha = 0
				self.timetableView.alpha = 0
				self.markbookView.alpha = 0
				self.otherView.alpha = 0
				self.ucasPredictionsView.alpha = 0
				self.examTimetableView.alpha = 0
				self.woodleEventsView.alpha = 0
				self.studentBulletinView.alpha = 1
				self.pastoralView.alpha = 0
			})
		}
	}
	
	private func showPastoral() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.attendanceView.alpha = 0
				self.timetableView.alpha = 0
				self.markbookView.alpha = 0
				self.otherView.alpha = 0
				self.ucasPredictionsView.alpha = 0
				self.examTimetableView.alpha = 0
				self.woodleEventsView.alpha = 0
				self.studentBulletinView.alpha = 0
				self.pastoralView.alpha = 1
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

extension MainViewController: ShowProtocol, DismissProtocol {
	
	func showRequested(_ view: OtherViews) {
		switch view {
		case .ucas:
			self.showUCASPredictionsView()
		case .examTimetable:
			self.showExamTimetableView()
		case .woodleEvents:
			self.showWoodleEventsView()
		case .studentBulletin:
			self.showStudentBulletin()
		case .pastoral:
			self.showPastoral()
		}
	}
	
	func signOutRequested() {
		self.signOut()
	}
	
	func showDisclaimer() {
		self.showDisclaimerMessage()
	}
	
	func dismissRequested() {
		self.showOtherView()
	}
	
}
