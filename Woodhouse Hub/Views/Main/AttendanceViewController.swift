//
//  AttendanceViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 10/02/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class AttendanceViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak private var weekBeginningLabel: UILabel!
	@IBOutlet weak private var attendanceTable: UITableView!
	
	// MARK: Properties
	private var weekBeginning: Date = Date().getMondayOfWeek()
	private var weekBeginnings: [Date] = []
	
	// MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		self.setupWeekBeginnings()
		self.updateWeekBeginningLabel()
    }
	
	// MARK: Methods
	func setupWeekBeginnings() {
		if let attendance = Student.current.getAttendance()?.detailedAttendance {
			self.weekBeginnings = attendance.map({$0.date.getMondayOfWeek()}).removeDuplicates()
		}
	}
	
	// MARK: Week Beginning Selector
	private func showWeekBeginningSelector() {
		let selection = UIAlertController(title: "Change Week", message: nil, preferredStyle: .actionSheet)
		
		for week in weekBeginnings {
			selection.addAction(UIAlertAction(title: week.date(), style: .default, handler: { (alert) in
				let weekBeginningIndex = Int(self.weekBeginnings.firstIndex(where: {$0.date() == alert.title}) ?? 0)
				self.weekBeginning = self.weekBeginnings.safelyAccess(index: weekBeginningIndex) ?? Date().getMondayOfWeek()
				
				self.updateWeekBeginningLabel()
			}))
		}
		
		self.present(selection, animated: true, completion: nil)
	}
	
	private func updateWeekBeginningLabel() {
		self.weekBeginningLabel.text = "Week Beginning: \(weekBeginning.date())"
		self.attendanceTable.reloadData()
	}
	
	// MARK: IBActions
	@IBAction func dismissTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func weekBeginningSelectorTapped(_ sender: UIButton) {
		self.showWeekBeginningSelector()
	}

}

extension AttendanceViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let filteredAttendance = Student.current.getAttendance()?.detailedAttendance.filter({$0.date.getMondayOfWeek() == self.weekBeginning}) else { return 0 }
		return filteredAttendance.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "Attendance", for: indexPath) as? AttendanceCell else { return UITableViewCell() }
		guard let filteredAttendance = Student.current.getAttendance()?.detailedAttendance.filter({$0.date.getMondayOfWeek() == self.weekBeginning}) else { return cell }
		let attendance = filteredAttendance[indexPath.row]
		
		cell.setupCell(from: attendance, index: indexPath.row)
		
		return cell
	}
	
}
