//
//  CoreDataManager.swift
//  Woodhouse Hub
//
//  Created by George Nick Gorzynski on 18/01/2020.
//  Copyright © 2020 g30r93g. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
	
	// MARK: Shared Instance
	static let manager = CoreDataManager()
	
	// MARK: Initialisers
	init() {
//		self.deleteAndRebuild()
	}
	
	// MARK: Properties
	
	// MARK: Core Data Stack
	lazy var persistentContainer: NSPersistentContainer = {
	    /*
	     The persistent container for the application. This implementation
	     creates and returns a container, having loaded the store for the
	     application to it. This property is optional since there are legitimate
	     error conditions that could cause the creation of the store to fail.
	    */
	    let container = NSPersistentContainer(name: "Woodhouse_Hub")
	    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
	        if let error = error as NSError? {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	             
	            /*
	             Typical reasons for an error here include:
	             * The parent directory does not exist, cannot be created, or disallows writing.
	             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
	             * The device is out of space.
	             * The store could not be migrated to the current model version.
	             Check the error message to determine what the actual problem was.
	             */
	            fatalError("Unresolved error \(error), \(error.userInfo)")
	        }
	    })
	    return container
	}()

	func saveContext() {
	    let context = persistentContainer.viewContext
	    if context.hasChanges {
	        do {
	            try context.save()
	        } catch {
	            // Replace this implementation with code to handle the error appropriately.
	            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	            let nserror = error as NSError
	            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	        }
	    }
	}
	
	func deleteAndRebuild() {
		let coordinator = persistentContainer.persistentStoreCoordinator
		for store in coordinator.persistentStores where store.url != nil {
			try? coordinator.remove(store)
			try? FileManager.default.removeItem(atPath: store.url!.path)
		}
    }
	
	// MARK: Read Methods
	public func getStudentDetails() -> Student.StudentDetails? {
		let managedContext = self.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StudentDetails")
		
		var studentDetails: Student.StudentDetails?
		do {
			guard let fetchedDetails = try managedContext.fetch(fetchRequest).first else { return studentDetails }
			
			if let name = fetchedDetails.value(forKey: "name") as? String, let id = fetchedDetails.value(forKey: "studentNumber") as? String, let tutorGroup = fetchedDetails.value(forKey: "tutorGroup") as? String, let imageData = fetchedDetails.value(forKey: "image") as? Data {
				studentDetails = Student.StudentDetails(name: name, id: id, tutorGroup: tutorGroup, image: UIImage(data: imageData))
			}
		} catch let error as NSError {
		  print("Could not fetch. \(error), \(error.userInfo)")
		}
		
		return studentDetails
	}
	
	public func getStudentTimetable() -> [Student.TimetableEntry]? {
		return nil
		
		let managedContext = self.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Timetable")
		
		var timetable: [Student.TimetableEntry] = []
		
		do {
			let fetchedTimetable = try managedContext.fetch(fetchRequest)
			
			for entry in fetchedTimetable {
				if let lessonName = entry.value(forKey: "lessonName") as? String, let day = entry.value(forKey: "dayOfWeek") as? Int, let startTime = entry.value(forKey: "startTime") as? String, let endTime = entry.value(forKey: "endTime") as? String, let room = entry.value(forKey: "room") as? String?, let teacher = entry.value(forKey: "teacherName") as? String? {
					
					let startHour = Int(startTime.split(separator: ":")[0].trimmingCharacters(in: .whitespacesAndNewlines))!
					let startMinute = Int(startTime.split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines))!
					let startDate = Date().getMondayOfWeek().addDays(value: day).usingTime(startHour, startMinute, 00)
					
					let endHour = Int(startTime.split(separator: ":")[0].trimmingCharacters(in: .whitespacesAndNewlines))!
					let endMinute = Int(startTime.split(separator: ":")[1].trimmingCharacters(in: .whitespacesAndNewlines))!
					let endDate = Date().getMondayOfWeek().addDays(value: day).usingTime(endHour, endMinute, 00)
					
					let entry = Student.TimetableEntry(name: lessonName, day: day, startTime: startDate, endTime: endDate, teacher: teacher, room: room, attendanceMark: nil)
					
					timetable.append(entry)
				}
			}
		} catch let error as NSError {
			  print("Could not fetch. \(error), \(error.userInfo)")
		}
		
		if timetable.isEmpty {
			return nil
		} else {
			return timetable
		}
	}
	
	// MARK: Write Methods
	public func saveStudentDetails(from data: Student.StudentDetails, overwrite: Bool = true) {
		let managedContext = self.persistentContainer.viewContext
		
		guard let studentDetailsEntity = NSEntityDescription.entity(forEntityName: "StudentDetails", in: managedContext) else { return }
		
		if overwrite {
			// TODO: Drop table and add new details
		}
		
		let studentDetails = NSManagedObject(entity: studentDetailsEntity, insertInto: managedContext)
		studentDetails.setValue(data.name, forKey: "name")
		studentDetails.setValue(data.id, forKey: "studentNumber")
		studentDetails.setValue(data.tutorGroup, forKey: "tutorGroup")
		studentDetails.setValue(data.image!.jpegData(compressionQuality: 1), forKey: "image")
		
		do {
		   try managedContext.save()
		 } catch let error as NSError {
			print("[CoreDataManager] Couldn't save student details - \(error.localizedDescription)")
		 }
	}
	
	public func saveStudentTimetable(from data: [Student.TimetableEntry], overwrite: Bool = true) {
		let managedContext = self.persistentContainer.viewContext
		
		guard let timetableEntity = NSEntityDescription.entity(forEntityName: "Timetable", in: managedContext) else { return }
		
		if overwrite {
			// TODO: Drop table and add new details
		}
		
		for timetableEntry in data {
			let entry = NSManagedObject(entity: timetableEntity, insertInto: managedContext)
			entry.setValue(timetableEntry.name, forKey: "lessonName")
			entry.setValue(timetableEntry.day, forKey: "dayOfWeek")
			entry.setValue(timetableEntry.startTime.time(), forKey: "startTime")
			entry.setValue(timetableEntry.endTime.time(), forKey: "endTime")
			entry.setValue(timetableEntry.room, forKey: "room")
			entry.setValue(timetableEntry.teacher, forKey: "teacherName")
		}
		
		do {
		  try managedContext.save()
		} catch let error as NSError {
		   print("[CoreDataManager] Couldn't save student details - \(error.localizedDescription)")
		}
	}
	
	public func clearAll() {
		
	}
	
}
