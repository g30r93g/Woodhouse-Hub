//
//  WoodhouseCredentials.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 14/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation

class WoodhouseCredentials {
	
	// MARK: Shared Instance
	static let shared = WoodhouseCredentials(username: Settings().username ?? "", password: Settings().password ?? "")
	
	// MARK: Initialiser
	init(username: String, password: String) {
		self.username = username
		self.password = password
		
		if username != "" && password != "" {
			self.updateCredential()
		}
	}
	
	// MARK: Properties
	private var username: String
	private var password: String
	
	private var credential: URLCredential?
	private var protectionSpace: URLProtectionSpace?
	
	// MARK: Accessors
	public func getUsername() -> String {
		return self.username
	}
	
	public func getPassword() -> String {
		return self.password
	}
	
	public func setUsername(to username: String) {
		self.username = username
		self.updateCredential()
	}
	
	public func setPassword(to password: String) {
		self.password = password
		self.updateCredential()
	}
	
	public func getCredential() -> URLCredential? {
		return self.credential
	}
	
	public func getProtectionSpace() -> URLProtectionSpace? {
		return self.protectionSpace
	}
	
	// MARK: Methods
	internal func updateCredential() {
		Settings().username = username
		Settings().password = password
		
		self.credential = URLCredential(user: username, password: password, persistence: .forSession)
	}
	
	public func setProtectionSpace(to protection: URLProtectionSpace?) {
		self.protectionSpace = protection
	}
	
}
