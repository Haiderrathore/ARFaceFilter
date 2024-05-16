//
//  PersistentStorage.swift
//  TargetofsAssessment
//
//  Created by Zohaib Afzal on 24/04/2024.
//

import Foundation
import CoreData

final class PersistentStorage {
    
    static let shared = PersistentStorage()
    
    // so no other instance can be created of this class
    private init(){}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "TargetofsAssesmentStore")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Core Data Fetching support
    
    func fetchManagedObject<T: NSManagedObject>(managedObject: T.Type) -> [T]? {
        do {
            let request = managedObject.fetchRequest()
            guard let result = try PersistentStorage.shared.context.fetch(request) as? [T] else {return nil}
            return result
        } catch let error {
            debugPrint(error)
        }
        return nil
    }
    
    func fetchRecord<T: NSManagedObject>(managedObject: T.Type, withId id: String) -> T? {
        let managedContext = context
        
        let fetchRequest = managedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            guard let record = try PersistentStorage.shared.context.fetch(fetchRequest) as? [T] else {return nil}
            return record.first // Return the first record if found
        } catch {
            print("Error fetching record: \(error)")
            return nil
        }
    }
}
