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
	
	private var screenUp: Bool = false
	
	var presentingImage: UIImage?
	var presentingDataSource: TrainingData?
	weak var delegate: ScoreViewDelegate?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowup(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardClose(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
		if presentingImage != nil {
			imageView.image = presentingImage
		} else if let datasource = presentingDataSource {
			imageView.image = UIImage(data: datasource.picture as! Data)
			guard let allScores = datasource.scores?.components(separatedBy: ",") else { return }
			for (eachField, score) in zip(scoreFields, allScores) {
				eachField.text = score
			}
		}
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
}


