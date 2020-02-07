//
//  DashboardInteractor.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 14/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import WebKit
import SwiftSoup

class DashboardInteractor: NSObject {
	
	// MARK: Shared Instance
	static let shared = DashboardInteractor()
	
	// MARK: URLs
	internal let home = URL(string: "https://est.woodhouse.ac.uk")!
	internal let markbook = URL(string: "https://est.woodhouse.ac.uk/MyEMarkBook.aspx")!
	
	// MARK: Properties
	internal var homeWebView = WKWebView()
	internal var markbookWebView = WKWebView()
	
	public var currentDay: Int {
		switch Date().dayName() {
		case "Monday":
			return 1
		case "Tuesday":
			return 2
		case "Wednesday":
			return 3
		case "Thursday":
			return 4
		case "Friday":
			return 5
		default:
			return 0
		}
	}
	
	// MARK: Initialisers
	override init() {
		super.init()
		
		self.setupWebViews()
	}
	
	// MARK: Methods
	private func setupWebViews() {
		self.homeWebView.configuration.preferences.javaScriptEnabled = true
		self.homeWebView.navigationDelegate = self
		
		self.markbookWebView.configuration.preferences.javaScriptEnabled = true
		self.markbookWebView.navigationDelegate = self
	}
	
	public func signIn(username: String, password: String, completion: @escaping(Bool) -> Void) {
		WoodhouseCredentials.shared.setUsername(to: username)
		WoodhouseCredentials.shared.setPassword(to: password)
		
		let request = URLRequest(url: home)
		self.homeWebView.load(request)
		NotificationCenter.default.post(name: Notification.Name("dashboard.didNavigate"), object: nil, userInfo: nil)
		
		self.loadMarkbook()
		
		self.determineIfSignedIn() { (isSignedIn) in
			completion(isSignedIn)
		}
	}
	
	private func determineIfSignedIn(completion: @escaping(Bool) -> Void) {
		Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
			if !self.homeWebView.isLoading {
				self.homeWebView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html, error) in
					guard let htmlString = html as? String else { fatalError() }
					
					if htmlString.contains("My dashboard") {
						// Is Signed In
						timer.invalidate()
						NotificationCenter.default.post(name: Notification.Name("dashboard.didSignIn"), object: nil, userInfo: nil)
						
						completion(true)
					} else if htmlString.contains("401 - Unauthorized: Access is denied due to invalid credentials.") {
						print("Incorrect Credentials")
						NotificationCenter.default.post(name: Notification.Name("dashboard.finished"), object: nil, userInfo: nil)
						
						timer.invalidate()
						
						completion(false)
					}
				}
			}
		}
	}
	
	private func getBasicStudentDetails() {
		// Setup Dispatch Queue
		let nameDispatch = DispatchGroup()
		let idDispatch = DispatchGroup()
		let tutorGroupDispatch = DispatchGroup()
		let attendanceDispatch = DispatchGroup()
		let punctualityDispatch = DispatchGroup()
		
		// Initiate Variables
		var studentName: String?
		var studentID: String?
		var studentTutorGroup: String?
		var studentImage: UIImage?
		var studentAttendance: Int?
		var studentPunctuality: Int?
		
		// Student Name
		nameDispatch.enter()
		self.homeWebView.evaluateJavaScript("document.getElementById('cphLeft_dMyPortal_ctl13_mpMyPortal_lnkMyDetails1').innerText") { (text, error) in
			if error != nil { fatalError() }
			
			guard let name = text as? String else { fatalError() }
			print("Student name: \(name.replacingOccurrences(of: "\n", with: " "))")
			
			studentName = name.replacingOccurrences(of: "\n", with: " ")
			nameDispatch.leave()
		}
		
		nameDispatch.notify(queue: .global(qos: .userInitiated)) {
			if let name = studentName, let id = studentID, let tutorGroup = studentTutorGroup {
				Student.current.addDetails(from: Student.StudentDetails(name: name, id: id, tutorGroup: tutorGroup, image: studentImage))
			}
		}
		
		// Student ID Number
		idDispatch.enter()
		self.homeWebView.evaluateJavaScript("document.getElementById('cphLeft_dMyPortal_ctl13_mpMyPortal_lnkMyDetails2').innerText") { (text, error) in
			if error != nil { fatalError() }
			
			guard let id = text as? String else { fatalError() }
			print("Student ID: \(id)")
			
			self.getStudentImage(studentID: id) { (image) in
				studentImage = image
				studentID = id
				
				idDispatch.leave()
			}
		}
		
		idDispatch.notify(queue: .global(qos: .userInitiated)) {
			if let name = studentName, let id = studentID, let tutorGroup = studentTutorGroup {
				Student.current.addDetails(from: Student.StudentDetails(name: name, id: id, tutorGroup: tutorGroup, image: studentImage))
			}
		}
		
		// Student Tutor Group
		tutorGroupDispatch.enter()
		self.homeWebView.evaluateJavaScript("document.getElementById('cphLeft_dMyPortal_ctl13_mpMyPortal_sTutorGroup').innerText") { (text, error) in
			if error != nil { fatalError() }
			
			guard let tutorGroup = text as? String else { fatalError() }
			print("Student tutor group: \(tutorGroup)")
			
			studentTutorGroup = tutorGroup
			tutorGroupDispatch.leave()
		}
		
		tutorGroupDispatch.notify(queue: .global(qos: .userInitiated)) {
			if let name = studentName, let id = studentID, let tutorGroup = studentTutorGroup {
				Student.current.addDetails(from: Student.StudentDetails(name: name, id: id, tutorGroup: tutorGroup, image: studentImage))
			}
		}
		
		// Student Attendance
		attendanceDispatch.enter()
		self.homeWebView.evaluateJavaScript("document.getElementById('cphLeft_dMyPortal_ctl13_mpMyPortal_lblAttendance').innerText") { (text, error) in
			if error != nil { fatalError() }
			
			guard let attendance = text as? String else { fatalError() }
			let attendanceValue = attendance.extractNumbers()
			
			print("Student attendance: \(attendanceValue)%")
			
			studentAttendance = attendanceValue
			attendanceDispatch.leave()
		}
		
		attendanceDispatch.notify(queue: .global(qos: .userInitiated)) {
			if let attendance = studentAttendance, let punctuality = studentPunctuality {
				Student.current.addAttendance(from: Student.Attendance(attendance: attendance, punctuality: punctuality))
			}
		}
		
		// Student Punctuality
		punctualityDispatch.enter()
		self.homeWebView.evaluateJavaScript("document.getElementById('cphLeft_dMyPortal_ctl13_mpMyPortal_lblPunctuality').innerText") { (text, error) in
			if error != nil { fatalError() }
			
			guard let punctuality = text as? String else { fatalError() }
			let punctualityValue = punctuality.extractNumbers()
			
			print("Student punctuality: \(punctualityValue)%")
			
			studentPunctuality = punctualityValue
			punctualityDispatch.leave()
		}
		
		punctualityDispatch.notify(queue: .global(qos: .userInitiated)) {
			if let attendance = studentAttendance, let punctuality = studentPunctuality {
				Student.current.addAttendance(from: Student.Attendance(attendance: attendance, punctuality: punctuality))
				NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "dashboard.gatheredDetails"), object: nil)
			}
		}
	}
	
	private func getStudentImage(studentID: String, completion: @escaping(UIImage?) -> Void) {
		guard let imageURL = URL(string: "https://est.woodhouse.ac.uk/Library/userPhotos/\(studentID).jpg") else { completion(nil); return }
		
		DispatchQueue.global(qos: .userInteractive).async {
			guard let imageData = try? Data(contentsOf: imageURL) else { completion(nil); return }
			let image = UIImage(data: imageData)
			
			completion(image)
		}
	}
	
	private func getStudentTimetable() {
		var timetable: [Student.TimetableEntry] = []
		
		self.homeWebView.evaluateJavaScript("document.getElementById('cphCenterColumn_dMyTimetable1_ctl13_mtMyTimetable_dStudentTimetable').innerHTML") { (html, error) in
			if error != nil { fatalError() }
			
			// iterate over tr to get all lessons. Day of week (starting on monday) corresponds to index in array
			// Using onmouseover and its tag <div class...> inside the <td style="cursor: pointer;"...> tag, extract the following from the text that follows that tag
			// All cells follow a common rule of:
			//  1. Lesson Name
			//  2. Timing
			//  3. Teacher <- Optional
			//  4. Attendance <- Optional
			// This can be extracted by matching <div class=\'left\'> and anything after this until the trailing '>'.
			// Then split text in this div at each div. First item will be lesson name, second item will be timing and third item (which is optional) will be teacher name and code.
			
			guard let timetableHTML = html as? String else { fatalError() }
			
			let studentTimetable = try! SwiftSoup.parse(timetableHTML)
			let table = try! studentTimetable.getElementsByTag("table")[0]
			for row in try! table.getElementsByTag("tr") { // Period
				
				for (dayIndex, col) in try! row.select("td").enumerated() { // Day
					if let onMouseOverContent = try? col.attr("onmouseover") {
						// Lesson/Lunch/Directed
						
						if onMouseOverContent.count == 0 { continue }
						
						var className: String!
						var startTime: Date!
						var endTime: Date!
						var teacher: String?
						var room: String?
						var attendanceMark: String?
						
						let firstCloseTag = onMouseOverContent.firstIndex(of: ">")!
						let secondCloseTag = onMouseOverContent[firstCloseTag...].firstIndex(of: ">")!
						let extractedString = String(onMouseOverContent[secondCloseTag...]).dropFirst(21).replacingOccurrences(of: "<br />", with: "#")
						
						let extractedItems = Array(extractedString.extract(until: "<").split(separator: "#"))
						for (extractedIndex, item) in extractedItems.enumerated() {
							let stringValue = String(item)
							
							switch extractedIndex {
							case 0:
								// Class Name
								className = stringValue.replacingOccurrences(of: "A level", with: "").extract(until: "-").replacingOccurrences(of: "Yr1", with: "").replacingOccurrences(of: "Yr2", with: "").extract(until: "(").trimmingCharacters(in: .whitespacesAndNewlines)
							case 1:
								// Time
								let times = stringValue.split(separator: "-").map({String($0).trimmingCharacters(in: .whitespaces)})
								
								let startHour = Int(times[0].split(separator: ":")[0].trimmingCharacters(in: .whitespacesAndNewlines))!
								let startMinute = Int(times[0].split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines))!
								let startDate = Date().getMondayOfWeek().addDays(value: dayIndex).usingTime(startHour, startMinute, 00)
								
								let endHour = Int(times[1].split(separator: ":")[0].trimmingCharacters(in: .whitespacesAndNewlines))!
								let endMinute = Int(times[1].split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines))!
								let endDate = Date().getMondayOfWeek().addDays(value: dayIndex).usingTime(endHour, endMinute, 00)
								
								if Date().isWeekend {
									startTime = startDate.addDays(value: 7)
									endTime = endDate.addDays(value: 7)
								} else {
									startTime = startDate
									endTime = endDate
								}
							case 2:
								// Teacher
								teacher = stringValue.extract(until: "(").trimmingCharacters(in: .whitespacesAndNewlines)
							case 3:
								// Attendance
								attendanceMark = String(stringValue.replacingOccurrences(of: "(", with: "").first!)
							default:
								break
							}
						}
						
						// Room number
						if onMouseOverContent.contains("Room ") {
							room = String(Int(onMouseOverContent.extract(from: onMouseOverContent.count - 9).extract(until: ")").trimmingCharacters(in: .letters).trimmingCharacters(in: .whitespacesAndNewlines))!)
						}
						
						let entry = Student.TimetableEntry(name: className, day: dayIndex, startTime: startTime, endTime: endTime, teacher: teacher, room: room, attendanceMark: attendanceMark)
						timetable.append(entry)
					}
				}
			}
			
			Student.current.addTimetable(from: timetable)
			NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "dashboard.gatheredTimetable"), object: nil)
			NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "dashboard.finished"), object: nil)
		}
	}
	
	public func setupTimetableNotifications() {
		if let timetable = Student.current.studentProfile?.timetable {
			NotificationManager.session.setupTimetableNotifications(for: timetable)
		}
	}
	
	public func removeTimetableNotifications() {
		if let timetable = Student.current.studentProfile?.timetable {
			NotificationManager.session.removeTimetableNotifications(for: timetable)
		}
	}
	
	private func loadMarkbook() {
		let request = URLRequest(url: markbook)
		self.markbookWebView.load(request)
	}
	
	private func getMarkbookGrades() {
		Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { (timer) in
			self.markbookWebView.evaluateJavaScript("document.getElementById('cphMain_tcStudentILP_tpMarkbooks').innerHTML") { (html, error) in
				if let error = error {
					fatalError(error.localizedDescription)
				}
				
				guard let timetableHTML = html as? String else { fatalError() }
				let markbookDoc = try! SwiftSoup.parse(timetableHTML)
				let subjects = try! markbookDoc.getElementsByClass("course")
				
				var markbook: [Student.SubjectMarkbook] = []
				
				for subject in subjects {
					guard let subjectNameText = try? subject.getElementsByTag("table")[0].getElementsByTag("h3")[0].getElementsByTag("a").text() else { fatalError() }
					let subjectName = subjectNameText.replacingOccurrences(of: "A level", with: "").replacingOccurrences(of: "Yr1", with: "").replacingOccurrences(of: "Yr2", with: "").extract(until: "(").trimmingCharacters(in: .whitespacesAndNewlines).capitalized
					let units = try! subject.getElementsByClass("unit")
					
					var subjectUnits: [Student.MarkbookUnit] = []
					
					for unit in units {
						var markbookUnit: Student.MarkbookUnit!
						var markbookGrades: [Student.MarkbookGrade] = [] {
							didSet {
								markbookGrades.sort(by: {$0.date < $1.date})
							}
						}
						
						guard let unitTable = try? unit.getElementsByClass("standardTable").first() else { fatalError() }
						guard let unitName = try? unitTable.getElementsByClass("blank").first()?.text() else { fatalError() }
						
						let tableRows = try! unitTable.getElementsByTag("tr")
										
						if tableRows.count < 5 { continue }
						
						let testNames = try! tableRows[0].getElementsByTag("th").map({try! $0.attr("onmouseover")})
						let markingType = try! tableRows[1].getElementsByTag("th").map({try! $0.text()})
						let weighting = try! tableRows[2].getElementsByTag("th").map({try! $0.text()})
						let dates = try! tableRows[3].getElementsByTag("th").map({try! $0.text()})
						let marks = try! tableRows[4].getElementsByTag("td").map({try! $0.text()})
						
						for index in 0..<weighting.count {
							let testName = testNames[index].extract(from: "'").extract(until: ")").trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .whitespacesAndNewlines)
							let markingType = markingType[index]
							let weight = Double(weighting[index]) ?? -1
							let date = Date.markbookFormat(from: dates[index+3])

							let relevantMarkData = marks[index + 3].split(separator: " ").map({String($0)})
							guard let mark = relevantMarkData.first else { continue }
							guard let percentage = relevantMarkData.last?.extractNumbers() else { continue }

							markbookGrades.append(Student.MarkbookGrade(name: testName, markingType: markingType, weighting: weight, date: date, mark: mark, percentage: percentage))
						}

						let avgGCSE = Double(marks[0]) ?? -1
						let meg = marks[1]
						let ctg = marks[2]
						let avgPercent = marks[marks.count - 2].extractNumbers(limit: 2)
						let avgGrade = marks[marks.count - 1]

						markbookUnit = Student.MarkbookUnit(name: unitName, avgGCSE: avgGCSE, meg: meg, ctg: ctg, averagePercentage: avgPercent, averageGrade: avgGrade, grades: markbookGrades)
						subjectUnits.append(markbookUnit)
					}
					
					markbook.append(Student.SubjectMarkbook(name: subjectName, units: subjectUnits))
				}
				
				Student.current.addMarkbook(from: markbook)
			}
		}
	}
	
	func signOut() {
		self.homeWebView = WKWebView()
		self.markbookWebView = WKWebView()
	}
	
}

extension DashboardInteractor: WKNavigationDelegate {
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//		print("Navigation Ended - \(webView.url?.absoluteString)")
		
		switch webView {
		case self.homeWebView:
			// Timetable & Basic Details
			self.getBasicStudentDetails()
			self.getStudentTimetable()
			_ = ReportServerInteractor.shared
		case self.markbookWebView:
			// Student Results
			self.getMarkbookGrades()
			break
		default:
			break
		}
	}
	
	func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//		print("Auth requested for host \(challenge.protectionSpace.host) via \(challenge.protectionSpace.authenticationMethod)")
		
		if challenge.protectionSpace.host == "est.woodhouse.ac.uk" {
			guard let credentials = WoodhouseCredentials.shared.getCredential() else { completionHandler(.performDefaultHandling, nil); return }
			WoodhouseCredentials.shared.setProtectionSpace(to: challenge.protectionSpace)
			
			URLCredentialStorage.shared.setDefaultCredential(credentials, for: challenge.protectionSpace)
			challenge.sender?.use(credentials, for: challenge)
			completionHandler(.useCredential, credentials)
		} else {
			completionHandler(.performDefaultHandling, nil)
		}
	}
	
}