//
//  CoreDataManager.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/13.
//

import UIKit
import CoreData
import Combine

final class CoreDataManager {
    private let context: NSManagedObjectContext

    var didChangeObjectsNotification: AnyPublisher<NotificationCenter.Publisher.Output, Never> {
        NotificationCenter.default.publisher(for: NSManagedObjectContext.didChangeObjectsNotification, object: context)
            .eraseToAnyPublisher()
    }

    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
    }

    func createResult(result: SpeedmeterResult) {
        let newResult = SavedResult(context: context)
        newResult.time = Int64(result.time)
        newResult.distance = result.distance
        newResult.averageSpeed = result.averageSpeed
        newResult.topSpeed = result.topSpeed
        newResult.altitude = result.altitude
        newResult.mapView = result.mapView?.pngData()
        newResult.image = result.image?.pngData()
        newResult.title = result.title
        newResult.startDate = result.startDate
        newResult.endDate = result.endDate
        newResult.image = result.image?.pngData()
        newResult.isCompleted = true
        saveContext()
    }

    private func saveContext() {
//        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }

    // Read
    func fetchResults() -> [SavedResult] {
        let fetchRequest = NSFetchRequest<SavedResult>(entityName: "SavedResult")

        fetchRequest.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: true))

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]

        do {
            let items = try context.fetch(fetchRequest)
            return items
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }

    // Update
    func updateItem(itemToUpdate: SavedResult, newName: String, newCategory: String) {
        //       itemToUpdate.name = newName
        //       itemToUpdate.category = newCategory

        saveContext()
    }

    // Delete
    func deleteItem(itemToDelete : SavedResult){
        context.delete(itemToDelete)
        saveContext()
    }

    func reset() {
        let fetchRequest = NSFetchRequest<SavedResult>(entityName: "SavedResult")
        fetchRequest.includesPropertyValues = false // Only fetch the managedObjectID
        do {
            let items = try context.fetch(fetchRequest)

            for item in items {
                context.delete(item)
            }

            // Save Changes
            saveContext()

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
