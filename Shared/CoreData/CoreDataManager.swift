//
//  CoreDataManager.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 15/08/2020.
//

import CoreData

struct CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "MyData")
        container.loadPersistentStores { (storeDesctiption, error) in
            if let error = error {
                fatalError("Loading of store failed \(error)")
            }
        }
        
        return container
    }()
    
    @discardableResult
    func createPicture(name: String, data: Data) -> CDPicture? {
        let context = persistentContainer.viewContext
        
        let picture = NSEntityDescription.insertNewObject(forEntityName: "CDPicture", into: context) as! CDPicture
        
        picture.name = name
        picture.data = data
        picture.creationDate = Date()
        
        do {
            try context.save()
            return picture
        } catch let createError {
            print("Failed to create: \(createError)")
        }
        
        return nil
    }
    
    func fetchPictures() -> [CDPicture]? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<CDPicture>(entityName: "CDPicture")
        
        do {
            let allPictures = try context.fetch(fetchRequest)
            return allPictures
        } catch let fetchError {
            print("Failed to fetch all: \(fetchError)")
        }
        
        return nil
    }
    
    func fetchPicture(withName name: String, maximumAgeInDays age: Int = 7) -> CDPicture? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<CDPicture>(entityName: "CDPicture")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let pic = try context.fetch(fetchRequest)
            let picture = pic.first
            let interval = Double(age * 24 * 60 * 60 * -1)
            guard let finalPicture = picture,
                  let creationDate = finalPicture.creationDate else { return nil }
            
            if creationDate.timeIntervalSinceNow < interval {
                return nil
            } else {
                return picture
            }
            
        } catch let fetchError {
            print("Failed to fetch \(name): \(fetchError)")
        }
        
        return nil
    }
    
    func updatePicture(name: String, data: Data) {
        let context = persistentContainer.viewContext
        
        if let current = fetchPicture(withName: name) {
            current.data = data
            current.creationDate = Date()
            
            do {
                try context.save()
                
            } catch let updateError {
                print("Failed to update picture \(String(describing: name)): \(updateError)")
            }
            
        } else {
            createPicture(name: name, data: data)
        }
        
    }
    
    func deletePicture(picture: CDPicture) {
        
        let context = persistentContainer.viewContext
        context.delete(picture)
        
        do {
            try context.save()
            
        } catch let deleteError {
            print("Failed to delete picture \(String(describing: picture.name)): \(deleteError)")
        }
        
    }
    
}
