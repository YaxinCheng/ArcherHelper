//
//  InternetDetector.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-11.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import Foundation
import ReachabilitySwift

struct InternetDetector {
	private static let reachability = Reachability()
	static var isReachableViaWifi: Bool {
		return reachability?.isReachableViaWiFi ?? false
	}
	static var isReachableViaCellular: Bool {
		return reachability?.isReachableViaWWAN ?? false
	}
}
