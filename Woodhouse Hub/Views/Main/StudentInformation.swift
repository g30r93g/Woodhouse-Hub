//
//  StudentInformation.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 01/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class StudentInformation: UIView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var studentImageCover: UIVisualEffectView!
	@IBOutlet weak private var studentImage: UIImageView!
	@IBOutlet weak private var studentName: UILabel!
	@IBOutlet weak private var studentID: UILabel!
	@IBOutlet weak private var studentTutorGroup: UILabel!
	@IBOutlet weak private var studentAttendance: UILabel!
	@IBOutlet weak private var studentAttendanceIndicator: UIView!
	@IBOutlet weak private var studentPunctuality: UILabel!
	@IBOutlet weak private var studentPunctualityIndicator: UIView!
	
	// MARK: Overriden Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
	}
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "dashboard.gatheredDetails"), object: nil)
	}
	
	private func setupView() {
		// Hide or show image
		self.studentImageCover.alpha = UserDefaults.data.bool(forKey: "isHidingImage") ? 1 : 0
		
		self.registerForNotifications()
		self.updateView()
	}
	
	@objc private func updateView() {
		// Show student details
		if let studentDetails = Student.current.getDetails() {
			self.updateStudentDetails(with: studentDetails)
		}
	}
	
	private func updateStudentDetails(with details: Student.StudentDetails) {
		DispatchQueue.main.async {
			self.studentName.text = details.name
			self.studentID.text = "Student ID: \(WoodhouseCredentials.shared.getUsername())"
			self.studentTutorGroup.text = "Tutor Group: \(details.tutorGroup)"
			
			if let image = details.image {
				self.studentImage.image = image
				self.studentImage.contentMode = .scaleAspectFill
//				self.studentImage.sizeToFit()
			}
			
			if let attendanceDetails = Student.current.getAttendance() {
				self.studentAttendance.text = "Attendance: \(attendanceDetails.overallAttendance)%"
				self.studentPunctuality.text = "Punctuality: \(attendanceDetails.overallPunctuality)%"
				
				if attendanceDetails.overallAttendance < 90 {
					self.studentAttendanceIndicator.backgroundColor = .red
				} else if attendanceDetails.overallAttendance < 95 {
					self.studentAttendanceIndicator.backgroundColor = .orange
				} else {
					self.studentAttendanceIndicator.backgroundColor = .green
				}
				
				if attendanceDetails.overallPunctuality < 95 {
					self.studentPunctualityIndicator.backgroundColor = .red
				} else if attendanceDetails.overallPunctuality < 90 {
					self.studentPunctualityIndicator.backgroundColor = .orange
				} else {
					self.studentPunctualityIndicator.backgroundColor = .green
				}
			}
		}
	}
	
	private func toggleStudentImage() {
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
	
	// MARK: IBActions
	@IBAction private func studentImageVisibilityToggled(_ sender: UIButton) {
		self.toggleStudentImage()
	}
	
}
