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
	
	func sendRequest(data: [String: Any], completion: (([String: Any], Error?) -> Void)?) {
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
	
	func sendRequest(data: TrainingData, completion: @escaping (String?, TrainingData?, Error?) -> Void) {
		let imageData = (data.picture as! Data).base64EncodedString()
		let labels = data.scores ?? "0,0,0,0,0,0,0,0,0,0,0"
		let json: Data
		do {
			json = try JSONSerialization.data(withJSONObject: ["img": imageData, "label": labels, "id": "Not uploaded yet", "mode": "insert"], options: .prettyPrinted)
		} catch {
			return
		}
		var request = URLRequest(url: destinationURL)
		request.httpMethod = "POST"
		request.httpBody = json
		let session = URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
			if error != nil {
				completion(nil, nil, error)
			} else {
				guard let responseData = jsonData, let json = (try? JSONSerialization.jsonObject(with: responseData, options: .mutableLeaves)) as? [String: Any], let id = json["Result"] as? String else { return }
				if id != "Failed processing image" {
					data.id = id
					data.uploading = false
					data.save()
				}
				completion(id, data, nil)
			}
		}
		session.resume()
	}
	
	func updateRequest(label: String, id: String, completion: @escaping (String?, Error?) -> Void) {
		let json: Data
		do {
			json = try JSONSerialization.data(withJSONObject: ["img": "", "label": label, "id": id, "mode": "update"], options: .prettyPrinted)
		} catch {
			return
		}
		var request = URLRequest(url: destinationURL)
		request.httpMethod = "POST"
		request.httpBody = json
		let session = URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
			if error != nil {
				completion(nil, error)
			} else {
				guard let responseData = jsonData, let json = (try? JSONSerialization.jsonObject(with: responseData, options: .mutableLeaves)) as? [String: Any], let id = json["Result"] as? String else { return }
				completion(id, nil)
			}
		}
		session.resume()
	}
	
	func deleteRequest(id: String, completion: @escaping (String?, Error?) -> Void) {
		let json: Data
		do {
			json = try JSONSerialization.data(withJSONObject: ["_id": id], options: .prettyPrinted)
		} catch {
			return
		}
		var request = URLRequest(url: destinationURL)
		request.httpMethod = "PUT"
		request.httpBody = json
		let session = URLSession.shared.dataTask(with: request) { (jsonData, response, error) in
			if error != nil {
				completion(nil, error)
			} else {
				guard let responseData = jsonData, let json = (try? JSONSerialization.jsonObject(with: responseData, options: .mutableLeaves)) as? [String: Any], let result = json["Result"] as? String else { return }
				completion(result, nil)
			}
		}
		session.resume()
	}
}
