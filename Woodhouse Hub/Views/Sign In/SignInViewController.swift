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
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Sign In Successful" {
//			let destVC = segue.destination as! HomeViewController
		}
	}
	
	// MARK: IBActions
	@IBAction func signIn() {
		self.loadingIndicator.startAnimating()
		
		guard let username = self.usernameField.text else { return }
		guard let password = self.passwordField.text else { return }
		
		DashboardInteractor.shared.signIn(username: username, password: password) { (success) in
			self.loadingIndicator.stopAnimating()
			
			if success {
				self.performSegue(withIdentifier: "Sign In Successful", sender: self)
			} else {
				let alert = UIAlertController(title: "Log In Failed", message: "Please check your username and password.", preferredStyle: .alert)
				
				alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
				
				self.present(alert, animated: true, completion: nil)
			}
		}
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
