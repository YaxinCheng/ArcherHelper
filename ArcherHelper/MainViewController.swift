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
	
	fileprivate var dataset: [TrainingData] {
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
		
		let queue = DispatchQueue.global(qos: .background)
		queue.async { [weak self] in
			let server = ServerConnector()
			for eachData in self?.dataset ?? [] {
				if eachData.uploading == false { continue }
				if eachData.id == "Not uploaded yet" {
					server.sendRequest(data: eachData) { (id, data, error) in
						if error != nil {
							
						} else if let dataID = id, let trainingData = data {
							try! Realm().write {
								trainingData.id = dataID
								trainingData.uploading = false
							}
						}
					}
				} else {
					server.updateRequest(label: eachData.labels.map({String($0.score)}).joined(separator: ","), id: eachData.id) { (id, error) in
						
					}
				}
			}
		}
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
		} else if let dataSource = sender as? TrainingData {
			destinationVC.presentingDataSource = dataSource
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

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataset.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else { return UICollectionViewCell() }
		let dataSource = dataset[indexPath.row]
		let image = UIImage(data: dataSource.picture)
		cell.imageView.image = image
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let dataSource = dataset[indexPath.row]
		performSegue(withIdentifier: "showScoreVC", sender: dataSource)
		collectionView.deselectItem(at: indexPath, animated: true)
	}
}
