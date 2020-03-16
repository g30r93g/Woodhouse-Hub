//
//  StaffCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 14/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class StaffCell: UITableViewCell {
	
	// MARK: IBOutlets
	@IBOutlet weak private var staffImage: UIImageView!
	@IBOutlet weak private var staffName: UILabel!
	@IBOutlet weak private var staffEmail: UIButton!
	
	// MARK: Properties
	var email: String = ""
		
	// MARK: Methods
	func setupCell(from data: WoodleInteractor.StaffMember) {
		self.staffImage.image = data.image
		self.staffName.text = "\(data.firstName) \(data.lastName) (\(data.code))"
		self.staffEmail.setTitle(data.email, for: .normal)
		
		self.email = data.email
	}
	
	// MARK: IBActions
	@IBAction private func sendEmail(_ sender: UIButton) {
		do {
			try MailingDelegate(subject: "", body: "", recipients: [self.email]).composeEmail()
		} catch {
			return
		}
	}
	
}
