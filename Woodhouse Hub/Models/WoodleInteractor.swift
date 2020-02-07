//
//  WoodleInteractor.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 17/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import WebKit
import SwiftSoup

class WoodleInteractor: NSObject {

	// MARK: Shared Instance
	static let shared = WoodleInteractor()
	
	// MARK: URLs
	private let home = URL(string: "https://vle.woodhouse.ac.uk")!
	private let upcomingEventsURL = URL(string: "https://vle.woodhouse.ac.uk/studenthome.aspx?eventcat=Events&#eventlist")!
	private let registeredEventsURL = URL(string: "https://vle.woodhouse.ac.uk/studenthome.aspx?eventcat=Registered&#eventlist")!
	
	// MARK: Properties
	private var homeWebView = WKWebView()
	
	// MARK: Data Properties
	public var upcomingEvents: [Event] = []
	public var registeredEvents: [Event] = []
	
	// MARK: Initialisers
	override init() {
		super.init()
		
		self.setupWebViews()
		self.loadSignIn()
	}
	
	// MARK: Structs
	struct Event: Equatable {
		let title: String
		let description: String
		let startDate: Date
		let endDate: Date
		let eventOrganiser: String
		let fee: Double
		let placesRemaining: Int?
		let totalPlaces: Int?
	}
	
	// MARK: Methods
	private func setupWebViews() {
		self.homeWebView.configuration.preferences.javaScriptEnabled = true
		self.homeWebView.navigationDelegate = self
	}
	
	private func loadSignIn() {
		let request = URLRequest(url: home)
		self.homeWebView.load(request)
	}
	
	public func signIn() {
		let request = URLRequest(url: home)
		self.homeWebView.load(request)
	}
	
	private func completeSignIn(completion: @escaping(Bool) -> Void) {
		self.enterUsernamePassword {
			// Maths question
			self.homeWebView.evaluateJavaScript("document.getElementsByTagName('b')[0].innerText") { (html, error) in
				if error != nil { fatalError() }
				
				guard let mathsQuestion = html as? String else { fatalError() }
				
				var answer: Int {
					let splitQuestion = mathsQuestion.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "+", with: "").replacingOccurrences(of: "plus", with: "").replacingOccurrences(of: "and", with: "").trimmingCharacters(in: .symbols).trimmingCharacters(in: .whitespaces).split(separator: " ").map({String($0)})
					
					let leftSide = splitQuestion[0].extractNumbers(limit: 2)
					let rightSide = splitQuestion[1].extractNumbers(limit: 2)
					
					return leftSide + rightSide
				}
				
				self.homeWebView.evaluateJavaScript("document.getElementById('txtUsername').focused=true", completionHandler: nil)
				self.homeWebView.evaluateJavaScript("document.getElementById('txtMathAns').value='\(answer)'") { (html, error) in
					if error != nil { fatalError() }
					
					self.homeWebView.evaluateJavaScript("document.getElementById('ImageButton1').click()") { (_, error) in
						completion(error != nil)
					}
				}
			}
		}
	}
	
	private func enterUsernamePassword(completion: @escaping() -> Void) {
		// Username field
		let username = WoodhouseCredentials.shared.getUsername()
		let password = WoodhouseCredentials.shared.getPassword()
		
		self.homeWebView.evaluateJavaScript("document.getElementById('txtUsername').focused=true") { (_, error) in
			if error != nil { completion() }
			
			self.homeWebView.evaluateJavaScript("document.getElementById('txtUsername').value=\"\(username)\"", completionHandler: nil)
			
			// Password field
			self.homeWebView.evaluateJavaScript("document.getElementById('txtPassword').focused=true") { (_, error) in
				if error != nil { completion() }
				
				self.homeWebView.evaluateJavaScript("document.getElementById('txtPassword').value=\"\(password)\"", completionHandler: nil)
				completion()
			}
		}
	}
	
	private func loadUpcomingEvents() {
		let request = URLRequest(url: upcomingEventsURL)
		self.homeWebView.load(request)
	}
	
	private func getUpcomingEvents() {
		self.homeWebView.evaluateJavaScript("document.getElementById('Importantnotices1_eventregister1_lblEvents').innerHTML") { (html, error) in
			if error != nil { fatalError() }
			
			guard let htmlString = html as? String else { fatalError() }
			let events = htmlString.replacingOccurrences(of: "<hr>", with: "§").split(separator: "§")
			
			for event in events {
				let eventDetails = event.replacingOccurrences(of: "<br>", with: "§").split(separator: "§").map({String($0)})
				
				// 0 - Title
				let title = eventDetails[0].replacingOccurrences(of: "</b>", with: "").replacingOccurrences(of: "<b>", with: "")
				
				// 1 - Description
				let description = eventDetails[1].extract(until: "<")
				
				// 2 - Date
//				let date = (eventDetails.first(where: {$0.contains("Date/Time")}) ?? "").extractTextBetweenFontTags()
				var date: (Date, Date) {
					if var dates = eventDetails.first(where: {$0.contains("Date/Time")}) {
						dates = dates.extractTextBetweenFontTags()
						dates = dates.replacingOccurrences(of: "to", with: "§")
						
						if dates.contains(":") {
							dates.insert("§", at: dates.index(dates.endIndex, offsetBy: -14))
						}
						
						let splitDates = dates.split(separator: "§").map({String($0)})
						if splitDates.count == 4 {
							// Date & Time
							let fromDateString = "\(splitDates[0]) - \(splitDates[2])"
							let toDateString = "\(splitDates[1]) - \(splitDates[3])"
							
							let fromDate = Date.woodleFormat(from: fromDateString)
							let toDate = Date.woodleFormat(from: toDateString)
							
							return (fromDate, toDate)
						} else {
							// Date
							let fromDateString = splitDates[0]
							let toDateString = splitDates[1]
							
							let fromDate = Date.woodleFormat(from: fromDateString)
							let toDate = Date.woodleFormat(from: toDateString)
							
							return (fromDate, toDate)
						}
					} else {
						return (Date(), Date())
					}
				}
				
				// 3 - Organiser
				let organiser = (eventDetails.first(where: {$0.contains("Organiser")}) ?? "").extractTextBetweenFontTags()
				
				// 4 - Fee
//				let fee = Double(eventDetails.first(where: {$0.contains("Fee")})?.extractTextBetweenFontTags().replacingOccurrences(of: "£", with: "")) ?? -1
				var fee: Double {
					if var feeString = eventDetails.first(where: {$0.contains("Fee")}) {
						if feeString.contains("Free") { return 0 }
						
						feeString = feeString.extractTextBetweenFontTags()
						feeString = feeString.replacingOccurrences(of: "£", with: "").trimmingCharacters(in: .whitespaces)
						return Double(feeString) ?? -1
					} else {
						return -1
					}
				}
				
				// 5 - Places remaining & Total Places
				var placesRemaining: (Int?, Int?) {
					if var htmlString = eventDetails.first(where: {$0.contains("Places Remaining")}) {
						htmlString = htmlString.extractTextBetweenFontTags()
						htmlString = htmlString.replacingOccurrences(of: "of", with: "§")
						
						let splitString = htmlString.split(separator: "§").map({String($0)})
						
						let placesRemaining = splitString[0].extractNumbers()
						let totalPlaces = splitString[1].extractNumbers()
						
						return (placesRemaining, totalPlaces)
					} else {
						return (nil, nil)
					}
				}
				
				self.upcomingEvents.append(Event(title: title, description: description, startDate: date.0, endDate: date.1, eventOrganiser: organiser, fee: fee, placesRemaining: placesRemaining.0, totalPlaces: placesRemaining.1))
			}
			
			self.loadRegisteredEvents()
		}
	}
	
	private func loadRegisteredEvents() {
		let request = URLRequest(url: registeredEventsURL)
		self.homeWebView.load(request)
	}
	
	private func getRegisteredEvents() {
		self.homeWebView.evaluateJavaScript("document.getElementById('Importantnotices1_eventregister1_lblEvents').innerHTML") { (html, error) in
			if error != nil { fatalError() }
		
			guard let htmlString = html as? String else { fatalError() }
			let events = htmlString.replacingOccurrences(of: "<hr>", with: "§").split(separator: "§")
		
			for event in events {
				let eventDetails = event.replacingOccurrences(of: "<br>", with: "§").split(separator: "§").map({String($0)})
				
				// 0 - Title
				let title = eventDetails[0].replacingOccurrences(of: "</b>", with: "").replacingOccurrences(of: "<b>", with: "")
				
				// 1 - Description
				let description = eventDetails[1].extract(until: "<")
				
				// 2 - Date
				var date: (Date, Date) {
					if var dates = eventDetails.first(where: {$0.contains("Date/Time")}) {
						dates = dates.extractTextBetweenFontTags()
						dates = dates.replacingOccurrences(of: "to", with: "§")
						
						if dates.contains(":") {
							dates.insert("§", at: dates.index(dates.endIndex, offsetBy: -14))
						}
						
						let splitDates = dates.split(separator: "§").map({String($0)})
						if splitDates.count == 4 {
							// Date & Time
							let fromDateString = "\(splitDates[0]) - \(splitDates[2])"
							let toDateString = "\(splitDates[1]) - \(splitDates[3])"
							
							let fromDate = Date.woodleFormat(from: fromDateString)
							let toDate = Date.woodleFormat(from: toDateString)
							
							return (fromDate, toDate)
						} else {
							// Date
							let fromDateString = splitDates[0]
							let toDateString = splitDates[1]
							
							let fromDate = Date.woodleFormat(from: fromDateString)
							let toDate = Date.woodleFormat(from: toDateString)
							
							return (fromDate, toDate)
						}
					} else {
						return (Date(), Date())
					}
				}
				
				// 3 - Organiser
				let organiser = (eventDetails.first(where: {$0.contains("Organiser")}) ?? "").extractTextBetweenFontTags()
				
				// 4 - Fee
				var fee: Double {
					if var feeString = eventDetails.first(where: {$0.contains("Fee")}) {
						if feeString.contains("Free") { return 0 }
						
						feeString = feeString.extractTextBetweenFontTags()
						feeString = feeString.replacingOccurrences(of: "£", with: "").trimmingCharacters(in: .whitespaces)
						return Double(feeString) ?? -1
					} else {
						return -1
					}
				}
				
				self.registeredEvents.append(Event(title: title, description: description, startDate: date.0, endDate: date.1, eventOrganiser: organiser, fee: fee, placesRemaining: nil, totalPlaces: nil))
			}
		}
	}
	
	func signOut() {
		self.homeWebView = WKWebView()
		
		self.upcomingEvents = []
		self.registeredEvents = []
	}

}

extension WoodleInteractor: WKNavigationDelegate {
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		guard let url = webView.url?.absoluteString else { return }
		if url == "https://vle.woodhouse.ac.uk/login.aspx" {
			// Log In
			self.completeSignIn { (isSignedIn) in
				print("Did \(isSignedIn ? "" : "not") sign in to woodle")
			}
		} else if url.contains("https://vle.woodhouse.ac.uk/default.aspx") {
			// Load Student Home for Upcoming Events - This is where the events tabs live
			self.loadUpcomingEvents()
		} else if url == "https://vle.woodhouse.ac.uk/studenthome.aspx?eventcat=Events&#eventlist" {
			// Parse Upcoming Events
			self.getUpcomingEvents()
		} else if url == "https://vle.woodhouse.ac.uk/studenthome.aspx?eventcat=Registered&#eventlist" {
			// Parse Registered Events
			self.getRegisteredEvents()
		}
	}
	
	func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
			if challenge.protectionSpace.host == "est.woodhouse.ac.uk" {
				guard let credentials = WoodhouseCredentials.shared.getCredential() else { completionHandler(.performDefaultHandling, nil); return }
				
				URLCredentialStorage.shared.setDefaultCredential(credentials, for: challenge.protectionSpace)
				challenge.sender?.use(credentials, for: challenge)
				completionHandler(.useCredential, credentials)
			} else {
				completionHandler(.performDefaultHandling, nil)
			}
		}
	
}
