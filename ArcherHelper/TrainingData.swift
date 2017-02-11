//
//  TrainingData.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-09.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import Foundation
import RealmSwift

class TrainingData: Object {
	dynamic var picture: Data = Data()
	var labels = List<Score>()
	
	func save() {
		let realm = try! Realm()
		try! realm.write {
			realm.add(self)
		}
	}
}

class Score: Object {
	dynamic var score: Int = 0
}
