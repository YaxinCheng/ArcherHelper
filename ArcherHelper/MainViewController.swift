//
//  MainViewController.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-10.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController {
	
	private let imgPicker = UIImagePickerController()
	
	private var dataset: [TrainingData] {
		return Array(try! Realm().objects(TrainingData.self))
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		imgPicker.delegate = self
		imgPicker.allowsEditing = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		print(dataset.count)
	}
	
	@IBAction func navButtonPressed(_ sender: UIBarButtonItem) {
		if sender.tag == 0 {
			imgPicker.sourceType = .photoLibrary
			present(imgPicker, animated: true, completion: nil)
		} else {
			imgPicker.sourceType = .camera
			imgPicker.cameraCaptureMode = .photo
			imgPicker.showsCameraControls = true
			present(imgPicker, animated: true, completion: nil)
		}
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
		guard let identifier = segue.identifier, identifier == "showScoreVC" else { return }
		let destinationVC = segue.destination as! ScoreViewController
		if let pickedImg = sender as? UIImage {
			destinationVC.presentingImage = pickedImg
		}
	}
	
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let image = info[UIImagePickerControllerEditedImage] as? UIImage ?? info[UIImagePickerControllerOriginalImage] as? UIImage
		picker.dismiss(animated: true) { [weak self] in
			self?.performSegue(withIdentifier: "showScoreVC", sender: image)
		}
	}
}
