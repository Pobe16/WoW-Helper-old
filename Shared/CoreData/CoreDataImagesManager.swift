//
//  CoreDataManager.swift
//  WoWHelper 
//
//  Created by Mikolaj Lukasik on 15/08/2020.
//

import CoreData

struct CoreDataImagesManager {
    
    static let shared = CoreDataImagesManager()
    
    let persistentContainer: NSPersistentContainer = {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: UserDefaultsKeys.appUserGroup)!
        let storeURL = containerURL.appendingPathComponent("MyData.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        
        let container = NSPersistentContainer(name: "MyData")
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { (storeDesctiption, error) in
            if let error = error {
                fatalError("Loading of store failed \(error)")
            }
        }
        
        return container
    }()
    
    @discardableResult
    func createImage(name: String, data: Data) -> CDImage? {
        let context = persistentContainer.viewContext
        
        let picture = NSEntityDescription.insertNewObject(forEntityName: "CDImage", into: context) as! CDImage
        
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
    
    func fetchAllImages() -> [CDImage]? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<CDImage>(entityName: "CDImage")
        
        do {
            let allPictures = try context.fetch(fetchRequest)
            return allPictures
        } catch let fetchError {
            print("Failed to fetch all: \(fetchError)")
        }
        
        return nil
    }
    
    func fetchImage(withName name: String, maximumAgeInDays age: Int = 7) -> CDImage? {
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<CDImage>(entityName: "CDImage")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            
            let pic = try context.fetch(fetchRequest)
            let picture = pic.first
            let interval = Double(age * 24 * 60 * 60 * -1)
            guard let finalPicture = picture,
                  let creationDate = finalPicture.creationDate else {
                return nil
            }
            
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
    
    func getImage(using name: String) -> Data? {
        guard let storedImage = fetchImage(withName: name, maximumAgeInDays: 9999) else {
            print("fail loading \(name) image object from CD")
            return nil
        }
        
        guard let imageData = storedImage.data else {
            print("fail loding \(name) image data")
            return nil
        }
        
        return imageData
    }
    
    func updateImage(name: String, data: Data) {
        let context = persistentContainer.viewContext
//        print("trying to update")
        if let current = fetchImage(withName: name, maximumAgeInDays: 10000) {
            current.data = data
            current.creationDate = Date()
            
            do {
//                print("updating")
                try context.save()
                
            } catch let updateError {
                print("Failed to update picture \(String(describing: name)): \(updateError)")
            }
            
        } else {
            createImage(name: name, data: data)
        }
        
    }
    
    func deleteImage(image: CDImage) {
        
        let context = persistentContainer.viewContext
        context.delete(image)
        
        do {
            try context.save()
            
        } catch let deleteError {
            print("Failed to delete picture \(String(describing: image.name)): \(deleteError)")
        }
        
    }
    
}
