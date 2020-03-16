//
//  MarkbookView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 02/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class MarkbookView: RoundTopView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var subject: UILabel!
	@IBOutlet weak private var meg: UILabel!
	@IBOutlet weak private var averageGrade: UILabel!
	@IBOutlet weak private var changeSubject: UIButton!
	@IBOutlet weak private var markbookEntries: UICollectionView!
	
	// MARK: Properties
	var delegate: ShowProtocol? = nil
	private var currentSubject: Student.SubjectMarkbook?
	
	// MARK: Override Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
	}
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "dashboard.gatheredMarkbook"), object: nil)
	}
	
	private func setupView() {
		self.registerForNotifications()
		self.updateView()
	}
	
	@objc private func updateView() {
		guard let subject = self.currentSubject ?? Student.current.studentProfile?.markbook.first else { return }
		guard let firstUnit = subject.units.first(where: {$0.averageGrade != "X"}) ?? self.currentSubject?.units.first else { return }
		self.currentSubject = subject
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				UIView.animate(withDuration: 0.2) {
					self.subject.text = subject.name
					self.meg.text = "Minimum Expected Grade: \(firstUnit.meg)"
					self.averageGrade.text = "Average Grade: \(firstUnit.averageGrade) (~ \(firstUnit.averagePercentage)%)"
				}
			})
		}
		
		self.markbookEntries.reloadData()
	}
	
	private func handleChangeSubject() {
		guard let subjects = Student.current.studentProfile?.markbook, subjects.count > 0 else { return }
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
		
		self.delegate?.showAlert(alert)
	}
	
	// MARK: IBActions
	@IBAction private func changeSubjectTapped(_ sender: UIButton) {
		self.handleChangeSubject()
	}
	
}

extension MarkbookView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.currentSubject?.units.flatMap({$0.grades}).count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarkbookEntry", for: indexPath) as! MarkbookCell
		
		guard let data = self.currentSubject?.units.flatMap({$0.grades}).sorted()[indexPath.item] else { return cell }
		
		cell.setupCell(from: data)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.width, height: 80)
	}
	
}
