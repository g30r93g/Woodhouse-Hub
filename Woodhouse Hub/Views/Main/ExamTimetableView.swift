//
//  ExamTimetableView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 02/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class ExamTimetableView: RoundTopView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var back: UIButton!
	@IBOutlet weak private var examTimetable: UICollectionView!
	
	// MARK: Overriden Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
	}
	
	// MARK: Properties
	var delegate: DismissProtocol? = nil
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "reportServer.examTimetable"), object: nil)
	}
	
	private func setupView() {
		self.registerForNotifications()
		self.updateView()
	}
	
	@objc private func updateView() {
		self.examTimetable.reloadData()
	}
	
	// MARK: IBActions
	@IBAction private func backTapped(_ sender: UIButton) {
		self.delegate?.dismissRequested()
	}
	
}

extension ExamTimetableView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let exams = Student.current.getExams()?.exams else { return 0 }
		
		return exams.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Exam", for: indexPath) as! ExamCell
		
		guard let data = Student.current.getExams()?.exams[indexPath.item] else { return cell }
		
		cell.setupCell(from: data)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.width, height: 125)
	}
	
}
