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
	private let upcomingEventsURL = URL(string: "https://vle.woodhouse.ac.uk/events.aspx?eventcat=Events&#eventlist")!
	private let registeredEventsURL = URL(string: "https://vle.woodhouse.ac.uk/events.aspx?eventcat=Registered&#eventlist")!
	private let staffGalleryURL = URL(string: "https://vle.woodhouse.ac.uk/staffgallery.aspx")!
	var bulletinURL: URL? = nil {
		didSet {
			NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "woodle.studentBulletin")))
		}
	}
	
	// MARK: Properties 
	private var homeWebView = WKWebView()
	var isSignedIn = false
	
	// MARK: Data Properties
	private var upcomingEvents: [Event] = []
	private var registeredEvents: [Event] = []
	private var staffGallery: [StaffMember] = []
	
	// MARK: Data Methods
	public func getUpcomingEvents() -> [Event]? {
		if self.upcomingEvents.count > 0 {
			return self.upcomingEvents
		} else {
			return nil
		}
	}
	
	public func getRegisteredEvents() -> [Event]? {
		if self.registeredEvents.count > 0 {
			return self.registeredEvents
		} else {
			return nil
		}
	}
	
	public func getStaffGallery() -> [StaffMember]? {
		if self.staffGallery.count > 0 {
			return self.staffGallery
		} else {
			return nil
		}
	}
	
	// MARK: Initialisers
	override init() {
		super.init()
		
		self.setupWebViews()
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
	
	class StaffMember {
        let firstName: String
        let lastName: String
        let code: String
		let position: String
		let email: String
		var image: UIImage?
		
		init(name: String, position: String, email: String, imageURL: String) {
            self.firstName = name.extract(until: " ").trimmingCharacters(in: .whitespaces)
            self.lastName = name.extract(from: " ").trimmingCharacters(in: .whitespaces)
            self.code = imageURL.replacingOccurrences(of: "gfx/REMSphotos/", with: "").replacingOccurrences(of: ".jpg", with: "").replacingOccurrences(of: ".JPG", with: "").uppercased()
			self.position = position.trimmingCharacters(in: .whitespaces)
            self.email = email.trimmingCharacters(in: .whitespaces)
			self.image = nil
			
			self.fetchImage(from: "https://vle.woodhouse.ac.uk/\(imageURL)")
		}
		
		private func fetchImage(from url: String) {
			guard let imageURL = URL(string: url) else { return }
			
			DispatchQueue.global(qos: .userInteractive).async {
				guard let imageData = try? Data(contentsOf: imageURL) else { return }
				self.image = UIImage(data: imageData)
			}
		}
	}
	
	// MARK: Methods
	private func setupWebViews() {
		self.homeWebView.configuration.preferences.javaScriptEnabled = true
		self.homeWebView.navigationDelegate = self
	}
	
	public func signIn() {
		print("[WoodleInteractor] Loading Sign In...")
		let request = URLRequest(url: home)
		self.homeWebView.load(request)
	}
	
	private func completeSignIn(completion: @escaping(Bool) -> Void) {
		print("[WoodleInteractor] Signing in...")
		self.enterUsernamePassword {
			// Maths question
			self.homeWebView.evaluateJavaScript("document.getElementById('pagecontentdiv').getElementsByTagName('div')[4].getElementsByTagName('span')[0].innerText") { (html, error) in
                if error != nil { fatalError("\(error)") }
				
				guard let mathsQuestion = html as? String else { fatalError() }
				
				print("[WoodleInteractor] Maths Question: \(mathsQuestion)")
				
				var answer: Int {
					let splitQuestion = mathsQuestion.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "").replacingOccurrences(of: "+", with: " ").replacingOccurrences(of: "plus", with: " ").replacingOccurrences(of: "and", with: " ").trimmingCharacters(in: .symbols).trimmingCharacters(in: .whitespaces).split(separator: " ").map({String($0)}).map({Int($0) ?? 0})
					
					print("[WoodleInteractor] Tidied Maths Question: \(splitQuestion)")
					
					return splitQuestion.reduce(0, { return $0 + $1 })
				}
                
                print("[WoodleInteractor] Maths Answer: \(answer)")
				
				self.homeWebView.evaluateJavaScript("document.getElementById('txtMathAns').focused=true", completionHandler: nil)
				self.homeWebView.evaluateJavaScript("document.getElementById('txtMathAns').value='\(answer)'") { (html, error) in
					if error != nil { fatalError() }
					
					self.homeWebView.evaluateJavaScript("document.getElementById('btnSubmit').click()") { (_, error) in
						completion(error == nil)
						print("[WoodleInteractor] Finished Sign In Sequence")
					}
				}
			}
		}
	}
	
	private func enterUsernamePassword(completion: @escaping() -> Void) {
		// Username field
		let username = WoodhouseCredentials.shared.getUsername()
		let password = WoodhouseCredentials.shared.getPassword()
		
		print("[WoodleInteractor] Entering Credentials")
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
	
	private func fetchUpcomingEvents() {
		print("[WoodleInteractor] Retrieving upcoming events")
		self.homeWebView.evaluateJavaScript("document.getElementById('pagecontentdiv').innerHTML") { (html, error) in
            if error != nil { fatalError() }
			
            guard let htmlString = html as? String else { fatalError() }
            let htmlDocument = try! SwiftSoup.parse(htmlString)
            let events = try! htmlDocument.getElementsByClass("grid-item").array()
			
			for event in events {
                guard let eventCard = try! event.getElementsByClass("card-body").first() else { continue }
                
                let details = try! eventCard.getAllElements().array()
                
                let title = try! details[1].text()
                let description = try! eventCard.html().extract(from: ">", occurrence: 10).extract(until: "<").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "READ ON...", with: "")
                var dateString = try! details[6].text()
                let organiser = try! details[8].text()
                var feeString = try! details[10].text()
                let signUpURL = "https://vle.woodhouse.ac.uk/" + (try! details[13].attr("href") ?? "")
                
                var date: (Date?, Date?) {
                    // Replace month names with numbers to make date dd/mm/yyyy
                    dateString = dateString.replaceMonthWithCardinals()
                    
                    let dateRegex = NSRegularExpression("([0]?[1-9]|[1|2][0-9]|[3][0|1])[./-]([0]?[1-9]|[1][0-2])[./-]([0-9]{4}|[0-9]{2})")
                    let dates = dateRegex.allMatches(for: dateString)
                    
                    let timeRegex = NSRegularExpression("[0-9][0-9]:[0-9][0-9]+")
                    let times = timeRegex.allMatches(for: dateString)
                    
                    let fromDateString = "\(dates.first ?? "") \(times.first ?? "")"
                    let toDateString = "\(dates.last ?? "") \(times.last ?? "")"
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "DD/MM/YYYY HH:mm"
                    
                    let fromDate = formatter.date(from: fromDateString)
                    let toDate = formatter.date(from: toDateString)
                    
                    return (fromDate, toDate)
                }
                
                var fee: Double {
                    if feeString.contains("Free") {
                        return 0.00
                    }
                    
                    feeString = feeString.replacingOccurrences(of: "£", with: "")
                    
                    return Double(feeString) ?? -1
                }
                
                
//				let eventDetails = event.replacingOccurrences(of: "<br>", with: "§").split(separator: "§").map({String($0)})
//
//				// 0 - Title
//				let title = eventDetails[0].replacingOccurrences(of: "</b>", with: "").replacingOccurrences(of: "<b>", with: "")
//
//				// 1 - Description
//				let description = eventDetails[1].extract(until: "<")
//
//				// 2 - Date
//				var date: (Date, Date) {
//					if var dates = eventDetails.first(where: {$0.contains("Date/Time")}) {
//						dates = dates.extractTextBetweenFontTags()
//						dates = dates.replacingOccurrences(of: "to", with: "§")
//
//						if dates.contains(":") {
//							dates.insert("§", at: dates.index(dates.endIndex, offsetBy: -14))
//						}
//
//						let splitDates = dates.split(separator: "§").map({String($0)})
//						if splitDates.count == 4 {
//							// Date & Time
//							let fromDateString = "\(splitDates[0]) - \(splitDates[2])"
//							let toDateString = "\(splitDates[1]) - \(splitDates[3])"
//
//							let fromDate = Date.woodleFormat(from: fromDateString)
//							let toDate = Date.woodleFormat(from: toDateString)
//
//							return (fromDate, toDate)
//						} else {
//							// Date
//							guard let fromDateString = splitDates.first else { return (Date(), Date()) }
//							guard let toDateString = splitDates.safelyAccess(index: 1) else { return (Date(), Date()) }
//
//							let fromDate = Date.woodleFormat(from: fromDateString)
//							let toDate = Date.woodleFormat(from: toDateString)
//
//							return (fromDate, toDate)
//						}
//					} else {
//						return (Date(), Date())
//					}
//				}
//
//				// 3 - Organiser
//				let organiser = (eventDetails.first(where: {$0.contains("Organiser")}) ?? "").extractTextBetweenFontTags()
//
//				// 4 - Fee
//				var fee: Double {
//					if var feeString = eventDetails.first(where: {$0.contains("Fee")}) {
//						if feeString.contains("Free") { return 0 }
//
//						feeString = feeString.extractTextBetweenFontTags()
//						feeString = feeString.replacingOccurrences(of: "£", with: "").trimmingCharacters(in: .whitespaces)
//						return Double(feeString) ?? -1
//					} else {
//						return -1
//					}
//				}
//
//				// 5 - Places remaining & Total Places
//				var placesRemaining: (Int?, Int?) {
//					if var htmlString = eventDetails.first(where: {$0.contains("Places Remaining")}) {
//						htmlString = htmlString.extractTextBetweenFontTags()
//						htmlString = htmlString.replacingOccurrences(of: "of", with: "§")
//
//						let splitString = htmlString.split(separator: "§").map({String($0)})
//
//						let placesRemaining = splitString[0].extractNumbers()
//						let totalPlaces = splitString[1].extractNumbers()
//
//						return (placesRemaining, totalPlaces)
//					} else {
//						return (nil, nil)
//					}
//				}
//
//				self.upcomingEvents.append(Event(title: title, description: description, startDate: date.0, endDate: date.1, eventOrganiser: organiser, fee: fee, placesRemaining: placesRemaining.0, totalPlaces: placesRemaining.1))
			}
			print("[WoodleInteractor] Fetched upcoming events")
			NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "woodle.updatedEvents")))
			
			self.loadRegisteredEvents()
		}
	}
	
	private func loadRegisteredEvents() {
		let request = URLRequest(url: registeredEventsURL)
		self.homeWebView.load(request)
	}
	
	private func fetchRegisteredEvents() {
		print("[WoodleInteractor] Retrieving registered events")
		self.homeWebView.evaluateJavaScript("document.getElementById('Importantnotices1_eventregister1_lblEvents').innerHTML") { (html, error) in
            if error != nil { return }
		
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
					if var dateString = eventDetails.first(where: {$0.contains("Date/Time")}) {
						dateString = dateString.extractTextBetweenFontTags()
						
						print("[WoodleInteractor] Date Extracted: \(dateString)")
						
						// List Cases
						//  1. (Date) to (Date) - 27 June 2019 to 28 June 2019
						//  2. (Date) (Time) to (Time) - 01 April 2020 08:00 to 15:00
						//  3. (Date) to (Date) (Time) to (Time) - 26 February 2020 to 07 March 2020 13:15 to 00:00
						
						// Case 2
						let dateTwoTimeRegex = NSRegularExpression("([0-9]+ [A-Z][a-z]+ [0-9]+) ([0-9]+:[0-9]+) to ([0-9]+:[0-9]+)")
						if dateTwoTimeRegex.matches(dateString) {
							// Split at spaces. Indices 0,1,2 = From Date. Index 3 = From Time. Index 5 = To Time
							let splitDate = dateString.split(separator: " ").map({String($0)})
							
							let startDateString = "\(splitDate[0]) \(splitDate[1]) \(splitDate[2]) \(splitDate[3])"
							let endDateString = "\(splitDate[0]) \(splitDate[1]) \(splitDate[2]) \(splitDate[5])"
							
							let startDate = Date.woodleFormat(from: startDateString)
							let endDate = Date.woodleFormat(from: endDateString)
							
							print("[WoodleInteractor]  - From Date: \(startDate) To Date: \(endDate)")
							
							return (startDate, endDate)
						}
						
						// Case 3
						let twoDateTwoTimeRegex = NSRegularExpression("([0-9]+ [A-Z][a-z]+ [0-9]+) to ([0-9]+ [A-Z][a-z]+ [0-9]+) ([0-9]+:[0-9]+) to ([0-9]+:[0-9]+)")
						if twoDateTwoTimeRegex.matches(dateString) {
							// Split at spaces. Indices 0,1,2 = From Date. Indices 4,5,6 = To Date. Index 7 = From Time. Index 8 = To Time
							let splitDate = dateString.split(separator: " ").map({String($0)})
							
							let startDateString = "\(splitDate[0]) \(splitDate[1]) \(splitDate[2]) \(splitDate[7])"
							let endDateString = "\(splitDate[4]) \(splitDate[5]) \(splitDate[6]) \(splitDate[8])"
							
							let startDate = Date.woodleFormat(from: startDateString)
							let endDate = Date.woodleFormat(from: endDateString)
							
							print("[WoodleInteractor] • From Date: \(startDate) To Date: \(endDate)")
							
							return (startDate, endDate)
						}
						
						// Case 1
						let twoDateRegex = NSRegularExpression("([0-9]+ [A-Z][a-z]+ [0-9]+) to ([0-9]+ [A-Z][a-z]+ [0-9]+)")
						if twoDateRegex.matches(dateString) {
							// Split at spaces. Indices 0,1,2 = From Date. Indices 4,5,6 = To Date.
							let splitDate = dateString.split(separator: " ").map({String($0)})
							
							let startDateString = "\(splitDate[0]) \(splitDate[1]) \(splitDate[2])"
							let endDateString = "\(splitDate[4]) \(splitDate[5]) \(splitDate[6])"
							
							let startDate = Date.woodleFormat(from: startDateString)
							let endDate = Date.woodleFormat(from: endDateString)
							
							print("[WoodleInteractor]  - From Date: \(startDate) To Date: \(endDate)")
							
							return (startDate, endDate)
						}
						
						return (Date(), Date())
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
			
			let futureRegisteredEvents = self.registeredEvents.filter({$0.startDate > Date()})
			if !futureRegisteredEvents.isEmpty {
				NotificationManager.session.setupWoodleEventNotifications(from: futureRegisteredEvents)
			}
			
			print("[WoodleInteractor] Fetched registered events")
			NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "woodle.updatedEvents")))
		}
	}
	
	// MARK: Student Bulletin
	func getStudentBulletinURL() {
		print("[WoodleInteractor] Retrieving latest student bulletin")
		self.homeWebView.evaluateJavaScript("document.getElementsByClassName('isotope-grid cols-3')[0].getElementsByClassName('grid-item')[0].innerHTML") { (html, error) in
            if error != nil { self.loadStaffGallery(); return }
		
			guard let htmlString = html as? String else { fatalError() }
			
			let document = try! SwiftSoup.parse(htmlString)
			let links = try! document.getElementsByTag("a").map({try! $0.attr("href")})
			
			let studentBulletinRelativeURL = links.safelyAccess(index: 0) ?? ""
			let studentBulletinURL = "https://vle.woodhouse.ac.uk/\(studentBulletinRelativeURL)"
			
			self.bulletinURL = URL(string: studentBulletinURL)
			print("[WoodleInteractor] Student Bulletin URL obtained - \(studentBulletinRelativeURL)")
			
			// Fetch Staff Gallery
			self.loadStaffGallery()
		}
	}
	
	// MARK: Staff Gallery
	private func loadStaffGallery() {
		let request = URLRequest(url: self.staffGalleryURL)
		self.homeWebView.load(request)
	}
	
	private func parseStaffGallery() {
		print("[WoodleInteractor] Getting staff gallery...")
		
		self.homeWebView.evaluateJavaScript("document.getElementsByClassName('row')[0].innerHTML") { (html, error) in
			if error != nil { fatalError() }
			
			guard let htmlString = html as? String else { fatalError() }
			let document = try! SwiftSoup.parse(htmlString)
			
			// Get Staff Entries
			let staffEntries = try! document.getElementsByClass("col-xl-3 col-sm-6 mb-30")
			
			for profile in staffEntries {
                let name = try! profile.getElementsByClass("team-name").text()
                let positionName = try! profile.getElementsByClass("team-position").text()
                let email = try! profile.getElementsByClass("team-contact-link").text()
                let imageURL = try! profile.getElementsByClass("team-thumb").first()?.getElementsByTag("img").attr("src") ?? ""
				
				print("[WoodleInteractor] Adding staff member: \(name) (\(positionName)) - \(email) - \(imageURL)")
				self.staffGallery.append(StaffMember(name: name, position: positionName, email: email, imageURL: imageURL))
			}
			
			NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "woodle.retrievedStaffGallery")))
			print("[WoodleInteractor] Staff Members Retrieved")
            
            self.loadUpcomingEvents()
		}
	}
	
	// MARK: Sign Out
	func signOut() {
		self.homeWebView = WKWebView()
		
		self.upcomingEvents = []
		self.registeredEvents = []
		self.staffGallery = []
	}

}

extension WoodleInteractor: WKNavigationDelegate {
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url?.absoluteString else { return }
		
		if url.contains("https://vle.woodhouse.ac.uk/login.aspx") {
			// Log In
			if !self.isSignedIn {
				self.completeSignIn { (isSignedIn) in
					print("[WoodleInteractor] Did\(isSignedIn ? "" : " not") sign in to woodle")
					
					self.isSignedIn = isSignedIn
				}
			}
		} else if url.contains("default.aspx") || url.contains("studenthome.aspx") {
			// Load Student Home for Upcoming Events and student bulletin
            self.getStudentBulletinURL()
		} else if url.contains("events.aspx?eventcat=Events&#eventlist") {
			// Parse Upcoming Events
			self.fetchUpcomingEvents()
        } else if url.contains("events.aspx?eventcat=Registered&#eventlist") {
			// Parse Registered Events
			self.fetchRegisteredEvents()
        } else if url.contains("staffgallery.aspx") {
            // Get Staff Gallery
            self.parseStaffGallery()
        } else {
            print("[WoodleInteractor] Uncaught URL: \(url)")
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.host == "vle.woodhouse.ac.uk" {
            guard let credentials = WoodhouseCredentials.shared.getCredential() else { completionHandler(.performDefaultHandling, nil); return }
            
            URLCredentialStorage.shared.setDefaultCredential(credentials, for: challenge.protectionSpace)
            challenge.sender?.use(credentials, for: challenge)
            completionHandler(.useCredential, credentials)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
}
