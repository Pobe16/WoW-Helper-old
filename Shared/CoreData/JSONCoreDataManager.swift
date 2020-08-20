//
//  JSONCoreDataManager.swift
//  WoWWidget
//
//  Created by Mikolaj Lukasik on 16/08/2020.
//

import CoreData

struct JSONCoreDataManager {
    
    static let shared = JSONCoreDataManager()
    
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
    func createJSONData(name: String, data: Data) -> JSONData? {
        let context = persistentContainer.viewContext
        
        let newData = NSEntityDescription.insertNewObject(forEntityName: "JSONData", into: context) as! JSONData
        
        newData.name = name
        newData.data = data
        newData.creationDate = Date()
        
        do {
            try context.save()
            return newData
        } catch let createError {
            print("Failed to create: \(createError)")
        }
        
        return nil
    }
    
    func fetchAllJSONData() -> [JSONData]? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<JSONData>(entityName: "JSONData")
        
        do {
            let allData = try context.fetch(fetchRequest)
            return allData
        } catch let fetchError {
            print("Failed to fetch all: \(fetchError)")
        }
        
        return nil
    }
    
    func fetchJSONData(withName name: String, maximumAgeInDays age: Int = 30) -> JSONData? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<JSONData>(entityName: "JSONData")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let dataArray = try context.fetch(fetchRequest)
            let data = dataArray.first
            let interval = Double(age * 24 * 60 * 60 * -1)
            
            guard let finalData = data,
                  let creationDate = finalData.creationDate else { return nil }
            
            if creationDate.timeIntervalSinceNow < interval {
                return nil
            } else {
                print("fetching \(name)")
                return data
            }
            
        } catch let fetchError {
            print("Failed to fetch \(name): \(fetchError)")
        }
        
        return nil
    }
    
    func updateJSONData(name: String, data: Data) {
        let context = persistentContainer.viewContext
//        print("trying to update")
        if let current = fetchJSONData(withName: name, maximumAgeInDays: 10000) {
            current.data = data
            current.creationDate = Date()
            
            do {
//                print("updating")
                try context.save()
                
            } catch let updateError {
                print("Failed to update picture \(String(describing: name)): \(updateError)")
            }
            
        } else {
            createJSONData(name: name, data: data)
        }
        
    }
    
    func deleteJSONData(data: JSONData) {
        
        let context = persistentContainer.viewContext
        context.delete(data)
        
        do {
            try context.save()
            
        } catch let deleteError {
            print("Failed to delete picture \(String(describing: data.name)): \(deleteError)")
        }
        
    }
    
    func saveJSON(_ data: Data, withURL url: URL) {
        let stringFromURL = url.absoluteString.split(separator: "?")[0]
        print("saving data for " + String(stringFromURL))
        self.updateJSONData(name: String(stringFromURL), data: data)
    }
    
}
