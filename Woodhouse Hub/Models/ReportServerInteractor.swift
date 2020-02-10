//
//  ReportServerInteractor.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 19/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation
import WebKit
import SwiftSoup

class ReportServerInteractor: NSObject {
	
	// MARK: Shared Instance
	static let shared = ReportServerInteractor()
	
	// MARK: URLs
	internal let ucasPredictions = URL(string: "https://reportserver.woodhouse.ac.uk/reportserver/pages/reportviewer.aspx?%2fstudentaccess%2fpredictedgradesforstudent&rs:command=render")!
	internal let examTimetable = URL(string: "https://reportserver.woodhouse.ac.uk/reportserver/pages/reportviewer.aspx?%2fstudentaccess%2fstudentexamtimetable&rs:command=render")!
	
	// MARK: Properties
	internal var ucasWebView = WKWebView()
	internal var examWebView = WKWebView()
	
	// MARK: Initialisers
	override init() {
		super.init()
		
		self.setupWebViews()
		self.loadUCASPredictions()
		self.loadExamTimetable()
	}
	
	// MARK: Methods
	private func setupWebViews() {
		self.ucasWebView.configuration.preferences.javaScriptEnabled = true
		self.ucasWebView.navigationDelegate = self
		
		self.examWebView.configuration.preferences.javaScriptEnabled = true
		self.examWebView.navigationDelegate = self
	}
	
	private func loadUCASPredictions() {
		let request = URLRequest(url: self.ucasPredictions)
		self.ucasWebView.load(request)
	}
	
	private func fetchUCASPredictions() {
		Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { (timer) in
			
			self.ucasWebView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html, error) in
				if let error = error { fatalError(error.localizedDescription) }
				
				guard let htmlString = html as? String else { return }
				
				let document = try! SwiftSoup.parse(htmlString)
				let outerTable = try! document.getElementsByTag("table").filter({$0.hasAttr("lang")})
				
				if 3 > outerTable.count - 1 { print("**E**"); return }
				let innerTable = try! outerTable[3].getElementsByTag("table")[0].getElementsByAttributeValue("valign", "top")
				
				var predictions: [Student.UCASPredictions] = []
				for (index, entry) in innerTable.enumerated() {
					if index == 0 { continue }
					
					let columns = try! entry.getElementsByTag("td").map({try! $0.text()})
					
					// 1 - Subject
					let subject = columns[1]
					
					// 2 - MEG
					let meg = columns[2]
					
					// 3 - Mock Grade
					let mock = columns[3]
					
					// 4 - UCAS Grade
					let ucas = columns[4]
					
					if subject != "Subject" {
						predictions.append(Student.UCASPredictions(subject: subject, meg: meg, mock: mock, ucasPrediction: ucas))
					}
				}
				
				timer.invalidate()
				Student.current.addUCASPredictions(from: predictions.sorted(by: {$0.subject < $1.subject}))
			}
		}
	}
	
	private func loadExamTimetable() {
		let request = URLRequest(url: self.examTimetable)
		self.examWebView.load(request)
	}
	
	private func fetchExamTimetable() {
		var count = 0
		Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { (timer) in
			if count <= 5 { timer.invalidate() }
			
			count += 1
			self.examWebView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html, error) in
				if let error = error { fatalError(error.localizedDescription) }
				
				guard let htmlString = html as? String else { fatalError() }
				let document = try! SwiftSoup.parse(htmlString)
				let tables = try! document.getElementsByTag("table").filter({$0.hasAttr("lang")})
				if tables.count < 8 { return }
				
				let candidateNumber = try! tables[7].getElementsByTag("div").first()?.text() ?? ""
				print(" - Candidate Number: \(candidateNumber)")
				
				if candidateNumber == "" { return }
				let examsTable = try! tables[3].getElementsByTag("table").last()!.getElementsByAttributeValue("valign", "top")
				
				var exams: [Student.ExamEntry] = []
				for (index, exam) in examsTable.enumerated() {
					if index == 0 || index == examsTable.count - 1 { continue }
					
					let examData = try! exam.getElementsByTag("div").map({try! $0.text()})
					
					let date = examData[1]
					
					let startTime = Date.reportServerFormat(from: "\(date) \(examData[2])")
					let endTime = Date.reportServerFormat(from: "\(date) \(examData[3])")
					
					var awardingBody: String {
						let scrapedBody = examData[4]
						if scrapedBody == "AQA" {
							return scrapedBody
						} else {
							return scrapedBody.capitalized
						}
					}
					let entryCode = examData[5]
					let paperName = examData[6].capitalized
					
					let room = examData.safelyAccess(index: 7) ?? "Pending"
					let seat = examData.safelyAccess(index: 8) ?? "Pending"
					
					exams.append(Student.ExamEntry(paperName: paperName, entryCode: entryCode, awardingBody: awardingBody, startTime: startTime, endTime: endTime, room: room, seat: seat))
				}
				Student.current.addExams(from: Student.Exams(candidateNumber: candidateNumber, exams: exams))
				
				timer.invalidate()
			}
		}
	}
	
	func signOut() {
		self.ucasWebView = WKWebView()
		self.examWebView = WKWebView()
	}
	
}

extension ReportServerInteractor: WKNavigationDelegate {
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//		print("Navigation Ended - \(webView.url?.absoluteString)")
		
		switch webView {
		case self.ucasWebView:
			// UCAS Predictions
			self.fetchUCASPredictions()
			break
		case self.examWebView:
			// Exam Timetable
			self.fetchExamTimetable()
		default:
			break
		}
	}
	
	func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//		print("Auth requested for host \(challenge.protectionSpace.host) via \(challenge.protectionSpace.authenticationMethod)")
		
		if challenge.protectionSpace.host == "reportserver.woodhouse.ac.uk" {
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
