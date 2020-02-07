//
//  WoodleEventsViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 19/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class WoodleEventsViewController: UIViewController {

	// MARK: IBOutlets
	@IBOutlet weak var eventTypeSelector: UISegmentedControl!
	@IBOutlet weak var eventsTable: UITableView!
	
	// MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	// MARK: IBActions
	@IBAction func dismissTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func typeSegmentUpdated(_ sender: UISegmentedControl) {
		self.eventsTable.reloadData()
	}
	
}

extension WoodleEventsViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.eventTypeSelector.selectedSegmentIndex == 0 {
			return WoodleInteractor.shared.upcomingEvents.count
		} else {
			return WoodleInteractor.shared.registeredEvents.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Event", for: indexPath) as! EventCell
		var data: WoodleInteractor.Event {
			if self.eventTypeSelector.selectedSegmentIndex == 0 {
				return WoodleInteractor.shared.upcomingEvents[indexPath.row]
			} else {
				return WoodleInteractor.shared.registeredEvents[indexPath.row]
			}
		}
		
		cell.setupCell(from: data, index: indexPath.row)
		
		return cell
	}
	
}
