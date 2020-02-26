//
//  MarkbookViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 21/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class MarkbookViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak var changeSubject: UIButton!
	@IBOutlet weak var subject: UILabel!
	@IBOutlet weak var meg: UILabel!
	@IBOutlet weak var avgGrade: UILabel!
	@IBOutlet weak var avgPercentage: UILabel!
	@IBOutlet weak var markbookEntries: UITableView!
	
	// MARK: Properties
	var currentSubject: Student.SubjectMarkbook?

	// MARK: View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		self.setupMarkbook()
    }
	
	// MARK: Methods
	private func setupMarkbook() {
		if let currentSubject = Student.current.studentProfile?.markbook.first {
			self.currentSubject = currentSubject
			self.updateView()
		}
	}
	
	private func handleChangeSubject() {
		guard let subjects = Student.current.studentProfile?.markbook else { return }
		let alert = UIAlertController(title: "Change Subject", message: "Please select from the following below", preferredStyle: .actionSheet)
		
		for (index, subject) in subjects.enumerated() {
			alert.addAction(UIAlertAction(title: subject.name, style: .default, handler: { (_) in
				self.currentSubject = subjects[index]
				self.updateView()
			}))
		}
		
		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = self.changeSubject //to set the source of your alert
			popoverController.sourceRect = CGRect(x: self.changeSubject.bounds.midX, y: self.changeSubject.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
			popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
		}

		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		
		self.present(alert, animated: true, completion: nil)
	}
	
	private func updateView() {
		guard let firstUnit = self.currentSubject?.units.first(where: {$0.averageGrade != "X"}) ?? self.currentSubject?.units.first else { return }
		guard let subjectName = self.currentSubject?.name else { return }
		self.subject.text = subjectName
		self.meg.text = "Minimum Expected Grade: \(firstUnit.meg)"
		self.avgGrade.text = "Average Grade: \(firstUnit.averageGrade)"
		self.avgPercentage.text = "Average Percentage: \(firstUnit.averagePercentage)%"
		
		self.markbookEntries.reloadData()
	}
	
	// MARK: IBActions
	@IBAction func dismissTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func changeSubjectTapped(_ sender: UIButton) {
		self.handleChangeSubject()
	}

}

extension MarkbookViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let tests = self.currentSubject?.units.flatMap({$0.grades}) {
			return tests.count
		} else {
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "MarkbookEntry", for: indexPath) as! MarkbookCell
		
		guard let data = self.currentSubject?.units.flatMap({$0.grades})[indexPath.row] else { return cell }
		
		cell.setupCell(from: data, index: indexPath.row)
		
		return cell
	}
	
}
