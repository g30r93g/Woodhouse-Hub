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
	init() {
		// Get details
		if let details = self.getDetails() {
			self.addDetails(from: details)
		}
		
		// Get timetable
		if let timetable = self.getTimetable() {
			self.addTimetable(from: timetable)
		}
	}
	
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
	
	struct StudentDetails: Codable {
		let name: String
		let id: String
		let tutorGroup: String
		let image: UIImage?
		
		// MARK: Initialiser
		init(name: String, id: String, tutorGroup: String, image: UIImage?) {
			self.name = name
			self.id = id
			self.tutorGroup = tutorGroup
			self.image = image
		}
		
		// MARK: Codable
		enum CodingKeys: String, CodingKey {
			case name
			case id
			case tutorGroup
			case image
		}
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			
			self.name = try container.decode(String.self, forKey: .name)
			self.id = try container.decode(String.self, forKey: .id)
			self.tutorGroup = try container.decode(String.self, forKey: .tutorGroup)
			self.image = UIImage(data: try container.decode(Data.self, forKey: .image))
		}
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			
			try container.encode(name, forKey: .name)
			try container.encode(id, forKey: .id)
			try container.encode(tutorGroup, forKey: .tutorGroup)
			try container.encode(image?.jpegData(compressionQuality: 1), forKey: .image)
		}
	}
	
	struct TimetableEntry: Equatable, Codable {
		let classIdentifier: String
		let name: String
		let day: Int
		let startTime: Date
		let endTime: Date
		let teacher: String?
		let room: String?
		let attendanceMark: String?
	}
	
	struct Attendance {
		let overallAttendance: Int
		let overallPunctuality: Int
		let detailedAttendance: [AttendanceEntry]
	}
	
	struct AttendanceEntry {
		let classIdentifier: String
		let attendanceMark: AttendanceMark
		let date: Date
	}
	
	enum AttendanceMark: String {
		case present = "/"
		case late = "L"
		case veryLate = "V"
		case unauthorisedAbsence = "O"
		case notifiedAbsence = "N"
		case internalExam = "E"
		case permissionToMiss = "P"
		case cancelled = "C"
		case transferIntoSet = ">"
		case transferOutOfSet = "<"
		case event = "|"
		case mark = ""
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
		if let storedTimetable = CoreDataManager.manager.getStudentTimetable() {
			return storedTimetable
		} else {
			return self.studentProfile?.timetable
		}
	}
	
	public func getAttendance() -> Attendance? {
		return self.studentProfile?.attendance
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
		CoreDataManager.manager.saveTimetable(from: timetable)
		
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
