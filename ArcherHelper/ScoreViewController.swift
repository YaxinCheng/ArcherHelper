//
//  ViewController.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-05.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet var scoreFields: [UITextField]!
	@IBOutlet weak var deleteButton: UIBarButtonItem!
	
	private var screenUp: Bool = false
	
	var presentingImage: UIImage?
	var presentingDataSource: TrainingData?
	var presentingDataSourceIndex: Int?
	
	weak var delegate: ScoreViewDelegate?
	
	override var previewActionItems: [UIPreviewActionItem] {
		let delete = UIPreviewAction(title: "Delete", style: .destructive) { (action, viewController) in
			guard let vc = viewController as? ScoreViewController else { return }
			if vc.presentingDataSource?.id != nil {
				vc.deleteData(7)
			} else if let index = vc.presentingDataSourceIndex {
				let notification = Notification(name: Notification.Name("ItemDeleted"), object: nil, userInfo: ["index": index])
				NotificationCenter.default.post(notification)
			}
		}
		return [delete]
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowup(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardClose(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
		deleteButton.isEnabled = false
		if presentingImage != nil {
			imageView.image = presentingImage
		} else if let datasource = presentingDataSource {
			deleteButton.isEnabled = true
			imageView.image = UIImage(data: datasource.picture as! Data)
			guard let allScores = datasource.scores?.components(separatedBy: ",") else { return }
			for (eachField, score) in zip(scoreFields, allScores) {
				eachField.text = score
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		navigationController?.isNavigationBarHidden = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		guard let image = imageView.image, let imageData = UIImageJPEGRepresentation(image, 0.5) else {
			return
		}
		if presentingDataSource == nil {
			guard let trainingData = TrainingData.construct() else { return }
			trainingData.picture = imageData as NSData
			let labels = gatherInfo()
			trainingData.scores = labels.joined(separator: ",")
			trainingData.save()
			delegate?.newDataCreated(trainingData: trainingData)
		} else {
			presentingDataSource!.scores = gatherInfo().joined(separator: ",")
			presentingDataSource!.uploading = true
			presentingDataSource!.save()
		}
	}

	
	func keyboardShowup(notification: Notification) {
		guard let size = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect else { return }
		if screenUp == false {
			view.center.y -= size.height
			screenUp = true
		}
	}
	
	func keyboardClose(notification: Notification) {
		guard let size = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect else { return }
		if screenUp == true {
			view.center.y += size.height
			screenUp = false
		}
	}
	
	fileprivate func clearFields() {
		for each in scoreFields {
			each.text = ""
		}
	}
	
	private func format(_ data: String?) -> String {
		return (data ?? "").isEmpty ? "0" : data!
	}
	
	private func gatherInfo() -> [String] {
		 return scoreFields.map { format($0.text) }
	}
	
	@IBAction func touchToCloseKeyboard(_ sender: Any) {
		view.endEditing(true)
	}
	
	@IBAction func deleteData(_ sender: Any) {
		guard let index = self.presentingDataSourceIndex else { return }
		let queue = DispatchQueue.global(qos: .background)
		let id = presentingDataSource?.id
		queue.async { [weak self] in
			let server = ServerConnector()
			guard id != nil else { return }
			let complish = {
				let notification = Notification(name: Notification.Name("ItemDeleted"), object: nil, userInfo: ["index": index])
				NotificationCenter.default.post(notification)
				if !(sender is Int) {
					DispatchQueue.main.async { [weak self] in
						_ = self?.navigationController?.popViewController(animated: true)
					}
				}
			}
			if id! == "Not uploaded yet" {
				complish()
				return
			}
			server.deleteRequest(id: id!) { result, error in
				if error != nil {
					
				} else {
					complish()
				}
			}
		}
	}
}
