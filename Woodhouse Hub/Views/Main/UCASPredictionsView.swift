//
//  UCASPredictionsView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 03/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class UCASPredictionsView: RoundTopView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var back: UIButton!
	@IBOutlet weak private var predictions: UICollectionView!
	
	// MARK: Overriden Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
	}
	
	// MARK: Properties
	var delegate: DismissProtocol? = nil
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "reportServer.ucasPredictions"), object: nil)
	}
	
	private func setupView() {
		self.registerForNotifications()
		self.updateView()
	}
	
	@objc private func updateView() {
		self.predictions.reloadData()
	}
	
	// MARK: IBActions
	@IBAction private func backTapped(_ sender: UIButton) {
		self.delegate?.dismissRequested()
	}
	
}

extension UCASPredictionsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let predictions = Student.current.getPredictions() else { return 0 }
		
		return predictions.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UCAS Prediction", for: indexPath) as! UCASPredictionCell
		
		guard let data = Student.current.getPredictions()?[indexPath.item] else { return cell }
		
		cell.setupCell(from: data)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.width, height: 100)
	}
	
}
