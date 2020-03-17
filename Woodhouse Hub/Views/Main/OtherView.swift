//
//  OtherView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 02/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class OtherView: RoundTopView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var pastoral: UIButton!
	@IBOutlet weak private var ucasPredictions: UIButton!
	@IBOutlet weak private var examTimetable: UIButton!
	@IBOutlet weak private var woodleEvents: UIButton!
	@IBOutlet weak private var studentBulletin: UIButton!
	@IBOutlet weak private var staffLookup: UIButton!
	@IBOutlet weak private var signOut: UIButton!
	@IBOutlet weak private var authorName: UIButton!
	
	// MARK: Overriden Methods
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	// MARK: Properties
	var delegate: ShowProtocol? = nil
	
	// MARK: IBActions
	@IBAction private func showUCASPredictions(_ sender: UIButton) {
		self.delegate?.showRequested(.ucas)
	}
	
	@IBAction private func showExamTimetable(_ sender: UIButton) {
		self.delegate?.showRequested(.examTimetable)
	}
	
	@IBAction private func showWoodleEvents(_ sender: UIButton) {
		self.delegate?.showRequested(.woodleEvents)
	}
	
	@IBAction private func showStudentBulletin(_ sender: UIButton) {
		self.delegate?.showRequested(.studentBulletin)
	}
	
	@IBAction private func showPastoral(_ sender: UIButton) {
		self.delegate?.showRequested(.pastoral)
	}
	
	@IBAction private func showStaffLookup(_ sender: UIButton) {
		self.delegate?.showRequested(.staffGallery)
	}
	
	@IBAction private func signOutTapped(_ sender: UIButton) {
		self.delegate?.signOutRequested()
	}
	
	@IBAction private func didTapDisclaimer(_ sender: UIButton) {
		self.delegate?.showDisclaimer()
	}
	
	@IBAction private func didTapAuthorName(_ sender: UIButton) {
		UIApplication.shared.open(URL(string: "instagram://user?username=g30r93g")!, options: [:], completionHandler: nil)
	}
	
}
