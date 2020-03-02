//
//  OtherView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 02/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class OtherView: RoundTopView {
	
	// MARK: IBOutlets
	
	// MARK: Overriden Methods
	
	// MARK: Methods
	
	// MARK: IBActions
	@IBAction private func didTapAuthorName(_ sender: UIButton) {
		UIApplication.shared.open(URL(string: "instagram://user?username=g30r93g")!, options: [:], completionHandler: nil)
	}
	
}
