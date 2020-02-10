//
//  StudentViewController.swift
//  Woodhouse-Dashboard
//
//  Created by George Nick Gorzynski on 14/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit
import WebKit

class HomeViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
	@IBOutlet weak var refreshButton: UIButton!
	@IBOutlet weak var studentDetailsView: UIView!
	@IBOutlet weak var studentName: UILabel!
	@IBOutlet weak var studentID: UILabel!
	@IBOutlet weak var studentTutorGroup: UILabel!
	@IBOutlet weak var studentImage: UIImageView!
	@IBOutlet weak var studentImageCover: UIVisualEffectView!
	@IBOutlet weak var studentAttendance: UILabel!
	@IBOutlet weak var studentAttendanceIndicator: UIView!
	@IBOutlet weak var studentPunctuality: UILabel!
	@IBOutlet weak var studentPunctualityIndicator: UIView!
	@IBOutlet weak var studentTimetableView: UIView!
	@IBOutlet weak var timetableDescriptor: UILabel!
	@IBOutlet weak var studentTimetable: UITableView!
	@IBOutlet weak var otherView: UIView!
	
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var detailLabel: UILabel!
	@IBOutlet weak var progressIndicator: UIProgressView!
	@IBOutlet weak var progressDescriptor: UILabel!
	
	// MARK: Variables
	private var lastLoad: Date!
	
	// MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		self.setupView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if lastLoad == nil || lastLoad.addMinutes(amount: 1) < Date() {
			self.lastLoad = Date()
			self.refreshButton.alpha = 0
			self.start()
		}
	}
	
	// MARK: Methods
	func toggleStudentImage() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.4) {
				if UserDefaults.data.bool(forKey: "isHidingImage") {
					// Show Image
					UserDefaults.data.set(false, forKey: "isHidingImage")
					self.studentImageCover.alpha = 0
				} else {
					// Hide Image
					UserDefaults.data.set(true, forKey: "isHidingImage")
					self.studentImageCover.alpha = 1
				}
			}
		}
	}
	
	private func setupView() {
		self.startLoading()
		
		self.studentImageCover.alpha = UserDefaults.data.bool(forKey: "isHidingImage") ? 1 : 0
	}
	
	func start() {
		// Show student details if cached
		if let studentDetails = Student.current.getDetails() {
			self.updateStudentDetailsView(with: studentDetails)
		}
		
		// Show timetable if cached
		if Student.current.getTimetable() != nil {
			self.studentTimetable.reloadData()
		}
		
		WoodleInteractor.shared.signIn()
		_ = ReportServerInteractor.shared
		
		self.awaitStudentDetails()
		
		if Settings().isSignedIn {
			DashboardInteractor.shared.signIn(username: Settings().username!, password: Settings().password!) { (_) in }
		} else {
			Settings().isSignedIn = true
		}
	}
	
	func awaitStudentDetails() {
		Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { (timer) in
			guard let attendanceDetails = Student.current.studentProfile?.attendance else { return }
			
			self.studentAttendance.text = "Attendance: \(attendanceDetails.attendance)%"
			self.studentPunctuality.text = "Punctuality: \(attendanceDetails.punctuality)%"
			
			if attendanceDetails.attendance < 95 {
				if attendanceDetails.attendance < 90 {
					self.studentAttendanceIndicator.backgroundColor = .red
				} else {
					self.studentAttendanceIndicator.backgroundColor = .orange
				}
			} else {
				self.studentAttendanceIndicator.backgroundColor = .green
			}
			
			if attendanceDetails.punctuality < 95 {
				if attendanceDetails.punctuality < 90 {
					self.studentPunctualityIndicator.backgroundColor = .red
				} else {
					self.studentPunctualityIndicator.backgroundColor = .orange
				}
			} else {
				self.studentPunctualityIndicator.backgroundColor = .green
			}
			
			self.studentTimetable.reloadData()
			
			timer.invalidate()

			UIView.animate(withDuration: 0.4) {
				self.refreshButton.alpha = 1
			}
		}
	}
	
	func updateStudentDetailsView(with data: Student.StudentDetails) {
		self.studentTimetable.reloadData()
		
		self.studentName.text = data.name
		self.studentID.text = "Student ID: \(WoodhouseCredentials.shared.getUsername())"
		self.studentTutorGroup.text = "Tutor Group: \(data.tutorGroup)"
		
		if let image = data.image {
			self.studentImage.image = image
			self.studentImage.contentMode = .scaleAspectFill
			self.studentImage.sizeToFit()
		}
		
		self.updateTimetableDescriptor()
	}
	
	func updateTimetableDescriptor() {
		if DashboardInteractor.shared.currentDay == 0 {
			self.timetableDescriptor.text = "Monday's Timetable"
		} else {
			self.timetableDescriptor.text = "Today's Timetable"
		}
	}
	
	private func startLoading() {
		// Start loading indicator
		self.loadingIndicator.startAnimating()
	}
	
	private func endLoading() {
		// Stop loading indicator
		self.loadingIndicator.stopAnimating()
	}
	
	// MARK: IBActions
	@IBAction func studentImageVisibilityToggled(_ sender: UIButton) {
		self.toggleStudentImage()
	}
	
	@IBAction func showFullTimetable() {
		self.performSegue(withIdentifier: "Show Timetable", sender: self)
	}
	
	@IBAction func refreshTapped() {
		UIView.animate(withDuration: 0.4) {
			self.refreshButton.alpha = 0
		}
		self.setupView()
	}
	
	@IBAction func signOut() {
		let alert = UIAlertController(title: "Confirm Sign Out", message: nil, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
		alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
			Settings().signOut()
			self.performSegue(withIdentifier: "Sign Out", sender: nil)
		}))
		
		self.present(alert, animated: true, completion: nil)
	}

}

// MARK: View Controller Extensions
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let timetable = Student.current.studentProfile?.timetable else { return 0 }
		
		if DashboardInteractor.shared.currentDay >= 1 && DashboardInteractor.shared.currentDay <= 5 {
			return timetable.filter({$0.day == DashboardInteractor.shared.currentDay}).count
		} else {
			return timetable.filter({$0.day == 1}).count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TimetableEntry", for: indexPath) as! TimetableCell
		
		guard let timetable = Student.current.studentProfile?.timetable else { return cell }
		var data: Student.TimetableEntry {
			if DashboardInteractor.shared.currentDay >= 1 && DashboardInteractor.shared.currentDay <= 5 {
				return timetable.filter({$0.day == DashboardInteractor.shared.currentDay})[indexPath.row]
			} else {
				return timetable.filter({$0.day == 1})[indexPath.row]
			}
		}
		
		cell.setupCell(from: data, index: indexPath.row)
		
		return cell
	}
	
}
