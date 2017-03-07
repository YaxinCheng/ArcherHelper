//
//  TrainingData+CoreDataClass.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-11.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import Foundation
import CoreData
import UIKit.UIApplication

@objc(TrainingData)
public class TrainingData: NSManagedObject {
	
	private let delegate = UIApplication.shared.delegate as! AppDelegate
	
	func save() {
		delegate.saveContext()
	}
	
	static func construct(img: UIImage? = nil) -> TrainingData? {
		let delegate = UIApplication.shared.delegate as! AppDelegate
		let context = delegate.managedObjectContext
		guard let model = NSEntityDescription.insertNewObject(forEntityName: "TrainingData", into: context) as? TrainingData else {
			return nil
		}
		if let image = img {
			model.picture = UIImagePNGRepresentation(image) as NSData?
		}
		model.uploading = true
		model.id = "Not uploaded yet"
		model.scores = "0,0,0,0,0,0,0,0,0,0,0,0"
		let notification = Notification(name: Notification.Name("NewDataCreated"))
		NotificationCenter.default.post(notification)
		return model
	}
	
	static func findAll() -> [TrainingData] {
		let request = NSFetchRequest<TrainingData>(entityName: "TrainingData");
		let delegate = UIApplication.shared.delegate as! AppDelegate
		let context = delegate.managedObjectContext
		return (try? context.fetch(request)) ?? []
	}
	
	func delete() {
		let context = delegate.managedObjectContext
		context.delete(self)
		save()
	}
}
