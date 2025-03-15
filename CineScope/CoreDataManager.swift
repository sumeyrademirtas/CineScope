//
//  CoreDataManager.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/13/25.
//

import CoreData
import UIKit

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    // Persistent Container
    /// Centralizing the persistentContainer in CoreDataManager allows us to manage all Core Data operations in one place
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CineScopeDataModel")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error loading Core Data store: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // Context
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Core Data Save
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("Context saved successfully.")
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Favori İşlemleri
    
    /// Favori ekler
    func addFavorite(id: Int64, posterURL: String, itemType: String) {
        let favoriteItem = FavoriteItem(context: context)
        favoriteItem.id = id
        favoriteItem.posterURL = posterURL
        favoriteItem.itemType = itemType
        print("Adding favorite: id=\(id), posterURL=\(posterURL), itemType=\(itemType)")
        saveContext()
    }
    
    /// Favoriden çıkarır
    func removeFavorite(id: Int64) {
        let request: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)
        
        do {
            let results = try context.fetch(request)
            if let itemToDelete = results.first {
                context.delete(itemToDelete)
                saveContext()
            }
        } catch {
            print("Error removing favorite: \(error.localizedDescription)")
        }
    }
    
    /// Favori olup olmadığını kontrol eder
    func isFavorite(id: Int64) -> Bool {
        let request: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Error checking favorite status: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Tüm favori öğeleri döndürür
    func fetchFavorites() -> [FavoriteItem] {
        let request: NSFetchRequest<FavoriteItem> = FavoriteItem.fetchRequest()
        do {
            let favorites = try context.fetch(request)
            print("Fetched favorites count: \(favorites.count)")
            return favorites
        } catch {
            print("Error fetching favorites: \(error.localizedDescription)")
            return []
        }
    }
}
