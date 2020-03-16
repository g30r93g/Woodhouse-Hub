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
	func showAlert(_ alert: UIAlertController)
	
}

protocol DismissProtocol {
	
	func dismissRequested()
	
}

class MainViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak private var woodhouseLogo: UIImageView!
	@IBOutlet weak private var pillBar: PillBar!
	@IBOutlet weak private var timetableView: TimetableView!
	@IBOutlet weak private var attendanceView: AttendanceView!
	@IBOutlet weak private var markbookView: MarkbookView!
	@IBOutlet weak private var otherView: OtherView!
	@IBOutlet weak private var ucasPredictionsView: UCASPredictionsView!
	@IBOutlet weak private var examTimetableView: ExamTimetableView!
	@IBOutlet weak private var woodleEventsView: WoodleEventsView!
	@IBOutlet weak private var studentBulletinView: StudentBulletinView!
<<<<<<< Updated upstream
=======
	@IBOutlet weak private var pastoralView: PastoralView!
	@IBOutlet weak private var staffGalleryView: StaffGalleryView!
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
	
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
<<<<<<< Updated upstream
=======
		case pastoral
		case staffGallery
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
	}
	
	// MARK: Methods
	private func setupView() {
		self.pillBar.delegate = self
		self.timetableView.delegate = self
		self.attendanceView.delegate = self
		self.markbookView.delegate = self
		self.otherView.delegate = self
		self.ucasPredictionsView.delegate = self
		self.examTimetableView.delegate = self
		self.woodleEventsView.delegate = self
		self.studentBulletinView.delegate = self
<<<<<<< Updated upstream
=======
		self.pastoralView.delegate = self
		self.staffGalleryView.delegate = self
		
		self.attachLongPressRecogniser()
	}
	
	private func attachLongPressRecogniser() {
		let studentImageFinderHold = UILongPressGestureRecognizer(target: self, action: #selector(navigateToStudentImageFinder(gesture:)))
		studentImageFinderHold.minimumPressDuration = 3
		studentImageFinderHold.delaysTouchesBegan = true
		studentImageFinderHold.delegate = self
		self.woodhouseLogo.addGestureRecognizer(studentImageFinderHold)
	}
	
	@objc private func navigateToStudentImageFinder(gesture: UILongPressGestureRecognizer) {
		guard gesture.state == .began else { return }
		
		self.performSegue(withIdentifier: "Find Student Image", sender: self)
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
	}
	
	private func signOut() {
		let alert = UIAlertController(title: "Confirm Sign Out", message: nil, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
		alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
			Settings().signOut()
			self.performSegue(withIdentifier: "Sign Out", sender: nil)
		}))
		
		self.present(alert, animated: true, completion: nil)
	}
	
	internal func showDisclaimerMessage() {
		let message = "This application has been made with the intention of aggregating Woodhouse College's Learning Management and student facing systems. No harm is intended to the developers of the original systems, rather that the systems are slow, dated and unintuitive to use. This application is a mitigation to those factors, by taking advantage of local storage of a student's timetable, details and other cached data, as well as extending the system to notify for lessons. This application is in compliance with GDPR, since it piggybacks off of existing systems. Students can only access their information with their login details, unique to them. I am a student of the college and have no affiliation directly with the development teams responsible for Dashboard, Woodle, ReportServer or any other services used by the college."
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
<<<<<<< Updated upstream
=======
				self.pastoralView.alpha = 0
				self.staffGalleryView.alpha = 0
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
				self.pastoralView.alpha = 0
				self.staffGalleryView.alpha = 0
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
				self.pastoralView.alpha = 0
				self.staffGalleryView.alpha = 0
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
				self.pastoralView.alpha = 0
				self.staffGalleryView.alpha = 0
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
				self.pastoralView.alpha = 0
				self.staffGalleryView.alpha = 0
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
				self.pastoralView.alpha = 0
				self.staffGalleryView.alpha = 0
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
				self.pastoralView.alpha = 0
				self.staffGalleryView.alpha = 0
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
				self.pastoralView.alpha = 0
				self.staffGalleryView.alpha = 0
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
				self.staffGalleryView.alpha = 0
			})
		}
	}
	
	private func showStaffGallery() {
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
				self.pastoralView.alpha = 0
				self.staffGalleryView.alpha = 1
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
			})
		}
	}

}

extension MainViewController: UIGestureRecognizerDelegate { }

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

extension MainViewController: ShowProtocol, DismissProtocol {
	
	func showAlert(_ alert: UIAlertController) {
		self.present(alert, animated: true)
	}
	
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
<<<<<<< Updated upstream
=======
		case .pastoral:
			self.showPastoral()
		case .staffGallery:
			self.showStaffGallery()
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
