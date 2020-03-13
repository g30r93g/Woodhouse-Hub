//
//  LoadingSignInViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 02/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class LoadingSignInViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak private var detailsLoading: UIActivityIndicatorView!
	@IBOutlet weak private var timetableLoading: UIActivityIndicatorView!
	@IBOutlet weak private var attendanceLoading: UIActivityIndicatorView!
	@IBOutlet weak private var markbookLoading: UIActivityIndicatorView!
	@IBOutlet weak private var pastoralLoading: UIActivityIndicatorView!
	
	@IBOutlet weak private var detailsCheck: UIImageView!
	@IBOutlet weak private var timetableCheck: UIImageView!
	@IBOutlet weak private var attendanceCheck: UIImageView!
	@IBOutlet weak private var markbookCheck: UIImageView!
	@IBOutlet weak private var pastoralCheck: UIImageView!
	
	// MARK: Properties
	private var loadedDetails = false
	private var loadedTimetable = false
	private var loadedAttendance = false
	private var loadedMarkbook = false
	private var loadedPastoral = false
	private var shouldSegue: Bool {
		return self.loadedDetails && self.loadedTimetable && self.loadedAttendance && self.loadedMarkbook && self.loadedPastoral
	}

	// MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		self.setupView()
		self.startCheckingForCompletion()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.signIn()
	}
	
	// MARK: Methods
	private func setupView() {
		self.detailsCheck.alpha = 0
		self.timetableCheck.alpha = 0
		self.attendanceCheck.alpha = 0
		self.markbookCheck.alpha = 0
		self.pastoralCheck.alpha = 0
	}
	
	private func signIn() {
		DashboardInteractor.shared.signIn(username: Settings().username!, password: Settings().password!) { (success) in
			if success {
				Settings().isSignedIn = true
				print("[LoadingSignInVC] Completed Sign In.")
			} else {
				print("[LoadingSignInVC] Failed Sign In.")
				let alert = UIAlertController(title: "Log In Failed", message: "Please check your username and password.", preferredStyle: .alert)
				
				let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
					self.dismiss(animated: true, completion: nil)
				}
				alert.addAction(okAction)
				
				self.present(alert, animated: true, completion: nil)
			}
		}
	}
	
	private func startCheckingForCompletion() {
		Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
			self.loadedDetails = Student.current.getDetails() != nil
			self.loadedTimetable = Student.current.getTimetable() != nil
			self.loadedAttendance = Student.current.getAttendance() != nil
			self.loadedMarkbook = Student.current.getMarkbook() != nil
			self.loadedPastoral = Student.current.getPastoral() != nil
			
			self.updateInterface()
			
			if self.shouldSegue {
				timer.invalidate()
				
				Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { (_) in
					self.performSegue(withIdentifier: "Fetched Student Details", sender: self)
				}
			}
		}
	}
	
	private func updateInterface() {
		if self.loadedDetails {
			self.detailsLoading.stopAnimating()
			self.detailsCheck.alpha = 1
		}
		
		if self.loadedTimetable {
			self.timetableLoading.stopAnimating()
			self.timetableCheck.alpha = 1
		}
		
		if self.loadedAttendance {
			self.attendanceLoading.stopAnimating()
			self.attendanceCheck.alpha = 1
		}
		
		if self.loadedMarkbook {
			self.markbookLoading.stopAnimating()
			self.markbookCheck.alpha = 1
		}
		
		if self.loadedPastoral {
			self.pastoralLoading.stopAnimating()
			self.pastoralCheck.alpha = 1
		}
	}

}
