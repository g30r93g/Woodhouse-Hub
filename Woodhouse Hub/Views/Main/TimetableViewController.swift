//
//  TimetableViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 17/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class TimetableViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak var daySegments: UISegmentedControl!
	@IBOutlet weak var notifications: UIButton!
	@IBOutlet weak var timetable: UITableView!

	// MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		self.setupTimetable()
    }
	
	// MARK: Methods
	func setupTimetable() {
		switch DashboardInteractor.shared.currentDay {
		case 1,2,3,4,5:
			self.daySegments.selectedSegmentIndex = DashboardInteractor.shared.currentDay - 1
		default:
			self.daySegments.selectedSegmentIndex = 0
		}
		
		self.notifications.setImage(UIImage(systemName: Settings().isReceivingTimetableNotifications ? "bell.fill" : "bell"), for: .normal)
		
		self.timetable.reloadData()
	}
	
	// MARK: IBActions
	@IBAction func daySegmentUpdated(_ sender: UISegmentedControl) {
		self.timetable.reloadData()
	}
	
	@IBAction func dismissTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func toggleTimetableNotification(_ sender: UIButton) {
		Settings().isReceivingTimetableNotifications = !Settings().isReceivingTimetableNotifications
		
		Settings().isReceivingTimetableNotifications ? DashboardInteractor.shared.setupTimetableNotifications() : DashboardInteractor.shared.removeTimetableNotifications()
		self.notifications.setImage(UIImage(systemName: Settings().isReceivingTimetableNotifications ? "bell.fill" : "bell"), for: .normal)
		
		let alert = UIAlertController(title: "Timetable notifications turned \(Settings().isReceivingTimetableNotifications ? "on" : "off")", message: "", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}

}

extension TimetableViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let timetable = Student.current.studentProfile?.timetable else { return 0 }
		return timetable.filter({$0.day == self.daySegments.selectedSegmentIndex + 1}).count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TimetableEntry", for: indexPath) as! TimetableCell
		
		guard let timetable = Student.current.studentProfile?.timetable else { return cell }
		let data = timetable.filter({$0.day == self.daySegments.selectedSegmentIndex + 1})[indexPath.row]
		
		cell.setupCell(from: data, index: indexPath.row)
		
		return cell
	}
	
}