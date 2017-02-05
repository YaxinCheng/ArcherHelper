//
//  ServerConnector.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-05.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import Foundation

struct ServerConnector {
	private let destination: String
	private let destinationURL: URL
	init() {
		destination = "https://archerhelper.herokuapp.com"
		destinationURL = URL(string: destination)!
	}
	
	func sendRequest(with data: [String: Any], completion: (([String: Any], Error?) -> Void)?) {
		let json: Data
		do {
			json = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
		} catch {
			return
		}
		var request = URLRequest(url: destinationURL)
		request.httpMethod = "POST"
		request.httpBody = json
		let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
			if error != nil {
				completion?([:], error)
			} else {
				guard let responseData = data, let json = (try? JSONSerialization.jsonObject(with: responseData, options: .mutableLeaves)) as? [String: Any] else { return }
				completion?(json, error)
			}
		}
		session.resume()
	}
}
