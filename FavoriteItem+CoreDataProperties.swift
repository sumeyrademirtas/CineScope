//
//  FavoriteItem+CoreDataProperties.swift
//  CineScope
//
//  Created by Sümeyra Demirtaş on 3/13/25.
//
//

import Foundation
import CoreData


extension FavoriteItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteItem> {
        return NSFetchRequest<FavoriteItem>(entityName: "FavoriteItem")
    }

    @NSManaged public var id: Int64
    @NSManaged public var posterURL: String?
    @NSManaged public var itemType: String?

}

extension FavoriteItem : Identifiable {

}
