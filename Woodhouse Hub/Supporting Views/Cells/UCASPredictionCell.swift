//
//  UCASPredictionCell.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 19/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class UCASPredictionCell: RoundUICollectionViewCell {
	
	// MARK: IBOutlets
	@IBOutlet weak var subject: UILabel!
	@IBOutlet weak var meg: UILabel!
	@IBOutlet weak var mock: UILabel!
	@IBOutlet weak var ucas: UILabel!
	
	// MARK: Methods
	func setupCell(from data: Student.UCASPredictions) {
		self.subject.text = data.subject
		self.meg.text = "Minimum Expected Grade: \(data.meg)"
		self.mock.text = "Mock Grade: \(data.mock)"
		self.ucas.text = "UCAS Predicted Grade: \(data.ucasPrediction)"
	}
	
}
