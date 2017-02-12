//
//  ScoreViewDelegate.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-12.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import Foundation

protocol ScoreViewDelegate: class {
	func newDataCreated(trainingData: TrainingData)
	func dataDeleted(index: Int)
}
