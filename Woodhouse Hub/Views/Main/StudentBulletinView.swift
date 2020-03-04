//
//  StudentBulletinView.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 02/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit
import PDFKit

class StudentBulletinView: RoundTopView {
	
	// MARK: IBOutlets
	@IBOutlet weak private var back: UIButton!
	@IBOutlet weak private var pdfContainer: UIView!
	
	// MARK: Overriden Methods
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setupView()
	}
	
	// MARK: Properties
	var delegate: DismissProtocol? = nil
	private var pdfView: PDFView!
	
	// MARK: Methods
	private func registerForNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name(rawValue: "woodle.studentBulletin"), object: nil)
	}
	
	private func setupView() {
		self.registerForNotifications()
		
		self.pdfView = PDFView(frame: self.pdfContainer.bounds)
		self.pdfView.backgroundColor = .clear
		
		self.pdfContainer.addSubview(self.pdfView)
		
		self.updateView()
	}
	
	@objc private func updateView() {
		if let bulletinURL = WoodleInteractor.shared.bulletinURL, let document = PDFDocument(url: bulletinURL) {
			print("[StudentBulletinView] Student bulletin displaying")
			self.pdfView.document = document
		} else {
			print("[StudentBulletinView] Student bulletin failed to load")
		}
	}
	
	// MARK: IBActions
	@IBAction private func backTapped(_ sender: UIButton) {
		self.delegate?.dismissRequested()
	}
	
}
