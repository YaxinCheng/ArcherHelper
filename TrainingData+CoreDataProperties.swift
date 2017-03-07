//
//  TrainingData+CoreDataProperties.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-15.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreData


extension TrainingData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrainingData> {
        return NSFetchRequest<TrainingData>(entityName: "TrainingData");
    }

    @NSManaged public var id: String?
    @NSManaged public var picture: NSData?
    @NSManaged public var scores: String?
    @NSManaged public var uploading: Bool

}
