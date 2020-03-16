//
//  PastoralView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 13/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class PastoralView: RoundTopView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var overallStatus: UILabel!
	@IBOutlet weak private var praise: UILabel!
	@IBOutlet weak private var neutral: UILabel!
	@IBOutlet weak private var concern: UILabel!
	
	// MARK: Overriden Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
	}
	
	// MARK: Properties
	var delegate: DismissProtocol? = nil
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "dashboard.retrievedPastoral"), object: nil)
	}
	
	private func setupView() {
		self.registerForNotifications()
		self.updateView()
	}
	
	@objc private func updateView() {
		if let pastoral = Student.current.getPastoral() {
			self.overallStatus.text = "General Status: \(pastoral.generalStatus.rawValue)"
			self.praise.text = "Praise: \(pastoral.praise)"
			self.neutral.text = "Neutral: \(pastoral.neutral)"
			self.concern.text = "Concern: \(pastoral.concern)"
		}
	}
	
	// MARK: IBActions
	@IBAction private func backTapped(_ sender: UIButton) {
		self.delegate?.dismissRequested()
	}
	
}
