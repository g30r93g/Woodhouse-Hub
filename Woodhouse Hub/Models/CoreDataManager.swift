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
	
	// MARK: Structs
	struct Timetable_Codable: Codable {
		
		// MARK: Properties
		var timetable: [Student.TimetableEntry] = []
		
		init(timetable: [Student.TimetableEntry]) {
			self.timetable = timetable
		}
		
	}
	
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
		if let data = UserDefaults.data.object(forKey: "Student-Timetable") as? Data {
			let decoder = JSONDecoder()
			if let decodedTimetable = try? decoder.decode(Timetable_Codable.self, from: data) {
				if !decodedTimetable.timetable.isEmpty {
					return decodedTimetable.timetable
				}
			}
		}
		
		return nil
	}
	
	// MARK: Write Methods
	public func saveStudentDetails(from studentDetails: Student.StudentDetails, overwrite: Bool = true) {
		let managedContext = self.persistentContainer.viewContext
		
		guard let studentDetailsEntity = NSEntityDescription.entity(forEntityName: "StudentDetails", in: managedContext) else { return }
		
		if overwrite {
			// TODO: Drop table and add new details
		}
		
		let studentDetailsEntry = NSManagedObject(entity: studentDetailsEntity, insertInto: managedContext)
		studentDetailsEntry.setValue(studentDetails.name, forKey: "name")
		studentDetailsEntry.setValue(studentDetails.id, forKey: "studentNumber")
		studentDetailsEntry.setValue(studentDetails.tutorGroup, forKey: "tutorGroup")
		studentDetailsEntry.setValue(studentDetails.image!.jpegData(compressionQuality: 1), forKey: "image")
		
		do {
		   try managedContext.save()
		 } catch let error as NSError {
			print("[CoreDataManager] Couldn't save student details - \(error.localizedDescription)")
		 }
	}
	
	public func saveTimetable(from data: [Student.TimetableEntry]) {
		let timetable = Timetable_Codable(timetable: data)
		
		let encoder = JSONEncoder()
		if let data = try? encoder.encode(timetable).self {
			UserDefaults.data.set(data, forKey: "Student-Timetable")
		} else {
			print("[CoreDataManager] Couldn't persist student timetable")
		}
	}
	
	public func clearAll() {
		
	}
	
}
