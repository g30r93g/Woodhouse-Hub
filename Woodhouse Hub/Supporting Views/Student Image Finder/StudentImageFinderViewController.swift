//
//  StudentImageFinderViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 15/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class StudentImageFinderViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak private var dismissButton: UIButton!
	@IBOutlet weak private var studentIDTextField: UITextField!
	@IBOutlet weak private var findImageButton: UIButton!
	@IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
	
	// MARK: View Controller Life Cycle
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.studentIDTextField.becomeFirstResponder()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.studentIDTextField.resignFirstResponder()
	}
	
	// MARK: Methods
	private func loadStudentImage() {
		self.loadingIndicator.startAnimating()
		
		guard let studentID = self.studentIDTextField.text else { self.dismiss(animated: true, completion: nil);
			self.loadingIndicator.stopAnimating(); return }
		guard let studentIDURL = URL(string: "https://vle.woodhouse.ac.uk/gfx/REMSphotos/\(studentID).jpg") else { self.dismiss(animated: true, completion: nil); self.loadingIndicator.stopAnimating(); return }
		
		URLSession.shared.dataTask(with: studentIDURL) { (data, response, error) in
			guard error == nil else { self.dismiss(animated: true, completion: nil); self.loadingIndicator.stopAnimating(); return }
			guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else { self.dismiss(animated: true, completion: nil); self.loadingIndicator.stopAnimating(); return }
			guard let mimeType = response?.mimeType, mimeType.hasPrefix("image") else { self.dismiss(animated: true, completion: nil); self.loadingIndicator.stopAnimating(); return }
			guard let imageData = data else { self.dismiss(animated: true, completion: nil); self.loadingIndicator.stopAnimating(); return }
			guard let studentIDImage = UIImage(data: imageData) else { self.dismiss(animated: true, completion: nil); self.loadingIndicator.stopAnimating(); return }
			
			self.saveToPhotos(studentIDImage)
			self.loadingIndicator.stopAnimating()
		}.resume()
	}
	
	private func saveToPhotos(_ image: UIImage) {
		UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
	}
	
	@objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
		if error == nil {
			let alert = UIAlertController(title: "Image Saved", message: "This image has been saved to your photo library.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default))
			present(alert, animated: true)
		}
	}
	
	// MARK: IBActions
	@IBAction private func findImageTapped(_ sender: UIButton) {
		self.loadStudentImage()
	}
	
	@IBAction private func dismissTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
	
}
