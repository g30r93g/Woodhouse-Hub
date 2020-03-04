//
//  SignInViewController.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 14/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
	@IBOutlet weak var usernameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	
	// MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		self.usernameField.becomeFirstResponder()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		Settings().isSignedIn = false
	}
	
	// MARK: IBActions
	@IBAction func signIn() {
		self.loadingIndicator.startAnimating()
		
		guard let username = self.usernameField.text else { return }
		guard let password = self.passwordField.text else { return }
		
		WoodhouseCredentials.shared.setUsername(to: username)
		WoodhouseCredentials.shared.setPassword(to: password)
	}
	
}

extension SignInViewController: UITextFieldDelegate {
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField == self.usernameField {
			self.passwordField.becomeFirstResponder()
		} else if textField == self.passwordField {
			textField.resignFirstResponder()
			self.signIn()
		}
		
		return true
	}
	
}
