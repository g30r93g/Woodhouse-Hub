//
//  TodayViewController.swift
//  Timetable
//
//  Created by George Nick Gorzynski on 10/02/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
	
	// MARK: IBOutlets
	@IBOutlet weak private var timetable: UITableView!
        
	// MARK: Properties
	var studentTimetable: [Student.TimetableEntry] = []
	
	// MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		_ = Student.current
    }
	
	// MARK: Methods
	func awaitTimetable(completion: @escaping([Student.TimetableEntry]) -> Void) {
		Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
			if let fetchedTimetable = Student.current.getTimetable() {
				completion(fetchedTimetable)
				
				timer.invalidate()
			}
		}
	}

	// MARK: NCWidgetProviding
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.failed
        // If there's no update required, use NCUpdateResult.noData
        // If there's an update, use NCUpdateResult.newData
		
		self.studentTimetable = Student.current.getTimetable() ?? []
		self.timetable.reloadData()
		
		self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		completionHandler(NCUpdateResult.noData)
    }
	
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		if activeDisplayMode == .compact {
            self.preferredContentSize = CGSize(width: maxSize.width, height: 250)
        } else if activeDisplayMode == .expanded {
			self.preferredContentSize = CGSize(width: maxSize.width, height: CGFloat(50 + (90 * self.studentTimetable.count)))
        }
    }
    
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let timetable = Student.current.getTimetable() else { return 0 }
		
		if DashboardInteractor.shared.currentDay >= 1 && DashboardInteractor.shared.currentDay <= 5 {
			return timetable.filter({$0.day == DashboardInteractor.shared.currentDay}).count
		} else {
			return timetable.filter({$0.day == 1}).count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TimetableEntry", for: indexPath) as! TimetableCell
		
		guard let timetable = Student.current.getTimetable() else { return cell }
		var data: Student.TimetableEntry {
			if DashboardInteractor.shared.currentDay >= 1 && DashboardInteractor.shared.currentDay <= 5 {
				return timetable.filter({$0.day == DashboardInteractor.shared.currentDay})[indexPath.row]
			} else {
				return timetable.filter({$0.day == 1})[indexPath.row]
			}
		}
		
		cell.setupCell(from: data, index: indexPath.row)
		
		return cell
	}
	
}
