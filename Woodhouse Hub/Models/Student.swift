//
//  Student.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 18/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

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
			
			for entry in self.studentProfile!.timetable {
				entry.updateTimesForCurrentWeek()
			}
		}
	}
	
	// MARK: Properties
	private(set) var studentProfile: StudentProfile?
	private(set) var updateNotifications: [UpdateNotification] = []
	
	// MARK: Structs
	struct UpdateNotification {
		let title: String
		let body: String
		let date: Date
	}
	
	struct StudentProfile {
		var details: StudentDetails?
		var timetable: [TimetableEntry]
		var attendance: Attendance?
		var ucasPredictions: [UCASPredictions]
		var exams: Exams?
		var markbook: [SubjectMarkbook]
		var pastoral: Pastoral?
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
	
	class TimetableEntry: Equatable, Codable {
		let classIdentifier: String
		let name: String
		let day: Int
		private(set) var startTime: Date
		private(set) var endTime: Date
		let teacher: String?
		let teacherCode: String?
		let room: String?
		let attendanceMark: String?
		
		// MARK: Initialiser
		init(classIdentifier: String, name: String, day: Int, startTime: Date, endTime: Date, teacher: String?, teacherCode: String?, room: String?, attendanceMark: String?) {
			self.classIdentifier = classIdentifier
			self.name = name
			self.day = day
			self.startTime = startTime
			self.endTime = endTime
			self.teacher = teacher
			self.teacherCode = teacherCode
			self.room = room
			self.attendanceMark = attendanceMark
			
			self.updateTimesForCurrentWeek()
		}
		
		// MARK: Methods
		func updateTimesForCurrentWeek() {
			self.startTime = Date().getMondayOfWeek().addDays(value: startTime.dayOfWeek() - 1).usingTime(startTime.dateComponents().hour!, startTime.dateComponents().minute!, startTime.dateComponents().second!)
			self.endTime = Date().getMondayOfWeek().addDays(value: endTime.dayOfWeek() - 1).usingTime(endTime.dateComponents().hour!, endTime.dateComponents().minute!, endTime.dateComponents().second!)
		}
		
		// MARK: Equatable
		static func == (lhs: Student.TimetableEntry, rhs: Student.TimetableEntry) -> Bool {
			return lhs.classIdentifier == rhs.classIdentifier && lhs.day == rhs.day && lhs.startTime == rhs.startTime
		}
	}
	
	struct Attendance {
		let overallAttendance: Int
		let overallPunctuality: Int
		let detailedAttendance: [AttendanceEntry]
	}
	
	class AttendanceEntry: Comparable {
		let classIdentifier: String
		let attendanceMark: AttendanceMark
		let date: Date
		let correspondingTimetableEntry: TimetableEntry?
		
		// MARK: Initialiser
		init(classIdentifier: String, attendanceMark: AttendanceMark, date: Date) {
			self.classIdentifier = classIdentifier
			self.attendanceMark = attendanceMark
			self.date = date
			
			if let timetable = Student.current.getTimetable(), let matchingEntry = timetable.first(where: {$0.classIdentifier == classIdentifier}) {
				self.correspondingTimetableEntry = matchingEntry
			} else {
				self.correspondingTimetableEntry = nil
			}
		}
		
		func prettyAttendanceMark() -> String {
			switch self.attendanceMark {
			case .present:
				return "Present"
			case .late:
				return "Late"
			case .veryLate:
				return "Very Late"
			case .unauthorisedAbsence:
				return "Unauthorised Absence"
			case .notifiedAbsence:
				return "Notified Absence"
			case .internalExam:
				return "Internal Exam"
			case .permissionToMiss:
				return "Permission to Miss Lesson"
			case .cancelled:
				return "Cancelled"
			case .transferIntoSet:
				return "Transfer In"
			case .transferOutOfSet:
				return "Transfer Out"
			case .event:
				return "Event"
			case .mark:
				return ""
			}
		}
		
		// MARK: Equatable
		static func == (lhs: AttendanceEntry, rhs: AttendanceEntry) -> Bool {
			return lhs.date == rhs.date && lhs.classIdentifier == rhs.classIdentifier && lhs.attendanceMark == rhs.attendanceMark
		}
		
		// MARK: Comparable
		static func < (lhs: AttendanceEntry, rhs: AttendanceEntry) -> Bool {
			return lhs.date < rhs.date
		}
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
	
	struct MarkbookGrade: Comparable {
		let name: String
		let markingType: String
		let weighting: Double
		let date: Date
		let mark: String
		let percentage: Int
		
		// MARK: Comparable
		static func < (lhs: MarkbookGrade, rhs: MarkbookGrade) -> Bool {
			return lhs.date > rhs.date
		}
	}
	
	struct Pastoral {
		let generalStatus: PastoralStatus
		let praise: Int
		let neutral: Int
		let concern: Int
		let pastoralHistory: [PastoralHistory]
	}
	
	struct PastoralHistory {
		let status: PastoralStatus
		let manager: String
		let startDate: Date
	}
	
	struct PastoralMessage {
		let type: PastoralMessageType
		let creationDate: Date
		let lastUpdateDate: Date
		let writtenBy: String
		let relevantPersons: [String]
		let comments: [PastoralComment]
		let responses: [PastoralResponse]
	}
	
	struct PastoralComment {
		let creator: String
		let date: Date
		let body: String
	}
	
	struct PastoralResponse {
		let creator: String
		let date: Date
		let body: String
	}
	
	enum PastoralMessageType: String {
		case praise = "Praise"
		case concern = "Concern"
	}
	
	enum PastoralStatus: String {
		case good = "Ok"
		case unknown = ""
		
		case academicZero = "Academic Stage 0"
		case academicOne = "Academic Stage 1"
		case academicTwo = "Academic Stage 2"
		case academicThree = "Academic Stage 3"
		case academicFour = "Academic Stage 4"
		
		case attendanceZero = "Attendance Stage 0"
		case attendanceOne = "Attendance Stage 1"
		case attendanceTwo = "Attendance Stage 2"
		case attendanceThree = "Attendance Stage 3"
		case attendanceFour = "Attendance Stage 4"
		
		case behaviourZero = "Behaviour Stage 0"
		case behaviourOne = "Behaviour Stage 1"
		case behaviourTwo = "Behaviour Stage 2"
		case behaviourThree = "Behaviour Stage 3"
		case behaviourFour = "Behaviour Stage 4"
	}
	
	// MARK: Sign Out
	public func signOut() {
		self.studentProfile = nil
		self.updateNotifications = []
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
	
	public func getMarkbook() -> [SubjectMarkbook]? {
		if let markbook = self.studentProfile?.markbook, markbook.count > 0 {
			return markbook
		} else {
			return nil
		}
	}
	
	public func getPredictions() -> [UCASPredictions]? {
		if let predictions = self.studentProfile?.ucasPredictions, predictions.count > 0 {
			return predictions
		} else {
			return nil
		}
	}
	
	public func getExams() -> Exams? {
		return self.studentProfile?.exams
	}
	
	public func getPastoral() -> Pastoral? {
		return self.studentProfile?.pastoral
	}
	
	// MARK: Setter Methods
	public func addDetails(from details: StudentDetails) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: [], pastoral: student.pastoral)
			Settings().studentDetails = details
		} else {
			self.studentProfile = StudentProfile(details: details, timetable: [], attendance: nil, ucasPredictions: [], exams: nil, markbook: [], pastoral: nil)
		}
		
		CoreDataManager.manager.saveStudentDetails(from: details)
	}
	
	public func addTimetable(from timetable: [TimetableEntry]) {
		CoreDataManager.manager.saveTimetable(from: timetable)
		
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: [], pastoral: student.pastoral)
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: timetable, attendance: nil, ucasPredictions: [], exams: nil, markbook: [], pastoral: nil)
		}
	}
	
	public func addAttendance(from attendance: Attendance) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: [], pastoral: student.pastoral)
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: attendance, ucasPredictions: [], exams: nil, markbook: [], pastoral: nil)
		}
	}
	
	public func addUCASPredictions(from predictions: [UCASPredictions]) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: predictions, exams: student.exams, markbook: [], pastoral: student.pastoral)
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: nil, ucasPredictions: predictions, exams: nil, markbook: [], pastoral: nil)
		}
	}
	
	public func addExamTimetable(from examTimetable: [ExamEntry]) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: [], pastoral: student.pastoral)
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: nil, ucasPredictions: [],  exams: nil, markbook: [], pastoral: nil)
		}
	}
	
	public func addExams(from exams: Exams) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: exams, markbook: student.markbook, pastoral: student.pastoral)
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: nil, ucasPredictions: [], exams: exams, markbook: [], pastoral: nil)
		}
	}
	
	public func addMarkbook(from markbook: [SubjectMarkbook]) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: markbook, pastoral: student.pastoral)
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: nil, ucasPredictions: [], exams: nil, markbook: markbook, pastoral: nil)
		}
	}
	
	public func addPastoral(from pastoral: Pastoral) {
		if let student = self.studentProfile {
			self.studentProfile = StudentProfile(details: student.details, timetable: student.timetable, attendance: student.attendance, ucasPredictions: student.ucasPredictions, exams: student.exams, markbook: student.markbook, pastoral: pastoral)
		} else {
			self.studentProfile = StudentProfile(details: nil, timetable: [], attendance: nil, ucasPredictions: [], exams: nil, markbook: [], pastoral: pastoral)
		}
	}
	
}
