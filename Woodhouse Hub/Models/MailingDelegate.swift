//
//  MailingDelegate.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 14/03/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import UIKit

class MailingDelegate {
	
	// MARK: Initialiser
	init(subject: String, body: String, recipients: [String]) {
		self.subject = subject
		self.body = body
		self.recipients = recipients
	}
	
	// MARK: Properties
	let subject: String
	let body: String
	let recipients: [String]
	
	// MARK: Methods
	public func composeEmail() throws {
		do {
			let outlookURL = try self.outlookDeepLink()
			let mailURL = try self.mailDeepLink()
			
			UIApplication.shared.open(outlookURL, options: [:], completionHandler: { (success) in
				
				if !success {
					UIApplication.shared.open(mailURL, options: [:], completionHandler: { (success) in
						
						if !success {
							fatalError()
						}
					})
				}
			})
		} catch {
			throw MailComposeError.unexpectedError
		}
	}
	
	private func outlookDeepLink() throws -> URL {
		var components = URLComponents()
		components.scheme = "ms-outlook"
		components.host = "compose"
		components.queryItems = [
			URLQueryItem(name: "to", value: self.recipients[0]),
			URLQueryItem(name: "subject", value: self.subject),
			URLQueryItem(name: "body", value: self.body),
		]
		
		if self.recipients.count > 1 {
			components.queryItems?.append(URLQueryItem(name: "cc", value: self.recipients[1..<self.recipients.count].joined(separator: ",")))
		}
		
		let url = components.url
		
		if url == nil { throw MailComposeError.urlError }
		print("[MailingDelegate] Outlook URL: \(url!.absoluteString)")

		return url!
	}
	
	private func mailDeepLink() throws -> URL {
		var components = URLComponents()
		components.scheme = "mailto"
		components.host = self.recipients[0]
		components.queryItems = [
			URLQueryItem(name: "subject", value: self.subject),
			URLQueryItem(name: "body", value: self.body),
		]
		
		if self.recipients.count > 1 {
			components.queryItems?.append(URLQueryItem(name: "cc", value: self.recipients[1..<self.recipients.count].joined(separator: ";")))
		}
		
		guard let urlString = components.url?.absoluteString.replacingOccurrences(of: "/", with: "") else { throw MailComposeError.urlError }
		guard let url = URL(string: urlString) else { throw MailComposeError.urlError }
		
		print("[MailingDelegate] Apple Mail URL: \(urlString)")
		
		return url
	}
	
	// MARK: Enums
	enum MailComposeError: Error {
		case urlError
		case unexpectedError
	}
	
}
