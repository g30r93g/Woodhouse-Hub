//
//  ExamTimetableViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 19/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class ExamTimetableViewController: UIViewController {

	// MARK: IBOutlets
	@IBOutlet weak var candidateNumber: UILabel!
	@IBOutlet weak var examsTimetable: UITableView!
	
	// MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		self.setupView()
    }
	
	func setupView() {
		if let examDetails = Student.current.studentProfile?.exams {
			self.candidateNumber.text = "Candidate Number: \(examDetails.candidateNumber)"
		} else {
			self.candidateNumber.text = "No exams timetabled."
		}
	}
	
	// MARK: IBActions
	@IBAction func dismissTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

extension ExamTimetableViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let examsTimetable = Student.current.studentProfile?.exams?.exams else { return 0 }
		return examsTimetable.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Exam", for: indexPath) as! ExamCell
		guard let examTimetable = Student.current.studentProfile?.exams?.exams else { return cell }
		let data = examTimetable[indexPath.row]
		
		cell.setupCell(from: data, index: indexPath.row)
		
		return cell
	}
	
}
