//
//  ImageEntity+CoreDataProperties.swift
//  TargetofsAssessment
//
//  Created by Zohaib Afzal on 24/04/2024.
//
//

import Foundation
import CoreData


extension ImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageEntity> {
        return NSFetchRequest<ImageEntity>(entityName: "ImageEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var localUrl: String?

}

extension ImageEntity : Identifiable {
    func convertToImage() -> String? {
        return self.localUrl
    }
}
