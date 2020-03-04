//
//  WoodleEventsView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 02/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class WoodleEventsView: RoundTopView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var back: UIButton!
	@IBOutlet weak private var segment: UISegmentedControl!
	@IBOutlet weak private var eventsCollection: UICollectionView!
	
	// MARK: Overriden Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
	}
	
	// MARK: Properties
	var delegate: DismissProtocol? = nil
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "woodle.updatedEvents"), object: nil)
	}
	
	private func setupView() {
		self.segment.selectedSegmentIndex = 0
		
		self.registerForNotifications()
		self.updateView()
	}
	
	@objc private func updateView() {
		self.eventsCollection.reloadData()
	}
	
	// MARK: IBActions
	@IBAction private func backTapped(_ sender: UIButton) {
		self.delegate?.dismissRequested()
	}
	
	@IBAction private func segmentChanged(_ sender: UISegmentedControl) {
		self.updateView()
	}
	
}

extension WoodleEventsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if self.segment.selectedSegmentIndex == 0, let registered = WoodleInteractor.shared.getRegisteredEvents() {
			return registered.count
		} else if self.segment.selectedSegmentIndex == 1, let upcoming = WoodleInteractor.shared.getUpcomingEvents() {
			return upcoming.count
		} else {
			return 0
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Event", for: indexPath) as! EventCell
		
		var event: WoodleInteractor.Event? {
			if self.segment.selectedSegmentIndex == 0, let registered = WoodleInteractor.shared.getRegisteredEvents() {
				return registered[indexPath.item]
			} else if self.segment.selectedSegmentIndex == 1, let upcoming = WoodleInteractor.shared.getUpcomingEvents() {
				return upcoming[indexPath.item]
			} else {
				return nil
			}
		}
		
		guard let data = event else { return cell }
		
		cell.setupCell(from: data)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.width, height: 125)
	}
	
}
