//
//  Student.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 18/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation
import UIKit

class Student {
	
	// MARK: Shared Instance
	static let current = Student()
	
	// MARK: Initialiser
	init() { }
	
	// MARK: Properties
	private(set) var studentProfile: StudentProfile?
	
	// MARK: Structs
	struct StudentProfile {
		var details: StudentDetails?
		var timetable: [TimetableEntry]
		var attendance: Attendance?
		var ucasPredictions: [UCASPredictions]
		var exams: Exams?
		var markbook: [SubjectMarkbook]
	}
	
	struct StudentDetails {
		let name: String
		let id: String
		let tutorGroup: String
		let image: UIImage?
	}
	
	struct TimetableEntry: Equatable {
		let name: String
		let day: Int
		let startTime: Date
		let endTime: Date
		let teacher: String?
		let room: String?
		let attendanceMark: String?
	}
	
	struct Attendance {
		let attendance: Int
		let punctuality: Int
//		let detailedAttendance: [AttendanceEntry] = []
	}
	
	struct UCASPredictions {
		let subject: String
		let meg: String
		let mock: String
		let ucasPrediction: String
	}
	
	struct Exams {
		let candidateNumber: String
		let exams: [ExamEntry]
	}
	
	struct ExamEntry {
		let paperName: String
		let entryCode: String
		let awardingBody: String
		let startTime: Date
		let endTime: Date
		let room: String
		let seat: String
	}
	
	struct SubjectMarkbook {
		let name: String
		let units: [MarkbookUnit]
	}
	
	struct MarkbookUnit {
		let name: String
		let avgGCSE: Double
		let meg: String
		let ctg: String
		let averagePercentage: Int
		let averageGrade: String
		let grades: [MarkbookGrade]
	}
	
	struct MarkbookGrade {
		let name: String
		let markingType: String
		let weighting: Double
		let date: Date
		let mark: String
		let percentage: Int
	}
	
	// MARK: Getter Methods
	public func getDetails() -> StudentDetails? {
		return CoreDataManager.manager.getStudentDetails() ?? self.studentProfile?.details
	}
	
	public func getTimetable() -> [TimetableEntry]? {
		return CoreDataManager.manager.getStudentTimetable() ?? self.studentProfile?.timetable
	}
	
	// MARK: Setter Methods
	public func addDetails(from details: StudentDetails) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: [])
			Settings().studentDetails = details
		} else {
			self.studentProfile = StudentProfile(details: details, timetable: [], attendance: nil, ucasPredictions: [], exams: nil, markbook: [])
		}
		
		CoreDataManager.manager.saveStudentDetails(from: details)
	}
	
	public func addTimetable(from timetable: [TimetableEntry]) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: [])
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: timetable, attendance: nil, ucasPredictions: [], exams: nil, markbook: [])
		}
	}
	
	public func addAttendance(from attendance: Attendance) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: [])
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: attendance, ucasPredictions: [], exams: nil, markbook: [])
		}
	}
	
	public func addUCASPredictions(from predictions: [UCASPredictions]) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: predictions, exams: student.exams, markbook: [])
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: nil, ucasPredictions: predictions, exams: nil, markbook: [])
		}
	}
	
	public func addExamTimetable(from examTimetable: [ExamEntry]) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: [])
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: nil, ucasPredictions: [],  exams: nil, markbook: [])
		}
	}
	
	public func addExams(from exams: Exams) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: exams, markbook: student.markbook)
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: nil, ucasPredictions: [], exams: exams, markbook: [])
		}
	}
	
	public func addMarkbook(from markbook: [SubjectMarkbook]) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: markbook)
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: nil, ucasPredictions: [], exams: nil, markbook: markbook)
		}
	}
	
}
