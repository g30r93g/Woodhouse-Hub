//
//  StaffGalleryView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 13/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class StaffGalleryView: UIView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var staffGallery: UITableView!
	
	// MARK: Overriden Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
	}
	
	// MARK: Properties
	var delegate: DismissProtocol? = nil
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "woodle.retrievedStaffGallery"), object: nil)
	}
	
	private func setupView() {
		self.registerForNotifications()
		self.updateView()
	}
	
	@objc private func updateView() {
		self.staffGallery.reloadData()
	}
	
	// MARK: IBActions
	@IBAction private func backTapped(_ sender: UIButton) {
		self.delegate?.dismissRequested()
	}
}

extension StaffGalleryView: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		guard let letters = WoodleInteractor.shared.getStaffGallery()?.map({$0.lastName}).mapFirstCharacter() else { return 0 }
		return letters.count
	}
	
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		guard let letters = WoodleInteractor.shared.getStaffGallery()?.map({$0.lastName}).mapFirstCharacter() else { return nil }
		return letters
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let letters = WoodleInteractor.shared.getStaffGallery()?.map({$0.lastName}).mapFirstCharacter() else { return nil }
		return letters[section]
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let letters = WoodleInteractor.shared.getStaffGallery()?.map({$0.lastName}).mapFirstCharacter() else { return 0 }
		let relevantLetter = letters[section]
		
		guard let relevantStaffMembers = WoodleInteractor.shared.getStaffGallery()?.filter({$0.lastName.starts(with: relevantLetter)}) else { return 0 }
		
		return relevantStaffMembers.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Staff Member", for: indexPath) as! StaffCell
		var data: WoodleInteractor.StaffMember? {
			guard let staffMembers = WoodleInteractor.shared.getStaffGallery() else { return nil }
			
			let letters = staffMembers.map({$0.lastName}).mapFirstCharacter()
			let relevantLetter = letters[indexPath.section]
			let relevantStaffMembers = staffMembers.filter({$0.lastName.starts(with: relevantLetter)})
			
			return relevantStaffMembers[indexPath.row]
		}
		
		if let data = data {
			cell.setupCell(from: data)
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120
	}
	
}
