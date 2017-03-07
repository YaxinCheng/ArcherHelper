//
//  MainViewController.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-10.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import UIKit
import NohanaImagePicker
import Photos

class MainViewController: UIViewController {
	
	private let imgPicker = NohanaImagePickerController()
	@IBOutlet weak var collectionView: UICollectionView!
	
	fileprivate lazy var dataset: [TrainingData] = {
		return TrainingData.findAll().reversed()
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		imgPicker.delegate = self
		imgPicker.maximumNumberOfSelection = 199
		NotificationCenter.default.addObserver(self, selector: #selector(refreshCollectionView), name: Notification.Name("NewDataCreated"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(syncingData), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(dataDeleted(notification:)), name: NSNotification.Name("ItemDeleted"), object: nil)
		
		if traitCollection.forceTouchCapability == .available {
			registerForPreviewing(with: self, sourceView: view)
		}
	}
	
	func refreshCollectionView() {
		collectionView.reloadData()
	}
	
	func dataDeleted(notification: Notification) {
		guard let userInfo = notification.userInfo as? [String: Int], let index = userInfo["index"] else { return }
		let dataSourceDeleted = dataset[index]
		dataset.remove(at: index)
		dataSourceDeleted.delete()
		DispatchQueue.main.async { [weak self] in
			self?.collectionView.reloadData()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.isNavigationBarHidden = true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		syncingData()
	}
	
	func syncingData() {
		guard InternetDetector.isReachableViaWifi else { return }
		let queue = DispatchQueue.global(qos: .background)
		queue.sync { [weak self] in
			let server = ServerConnector()
			for (index, eachData) in (self?.dataset ?? []).enumerated() {
				guard
					eachData.uploading == true,
					let cell = self?.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? ImageCell
				else { continue }
				
				cell.syncing()
				if eachData.id == "Not uploaded yet" {
					server.sendRequest(data: eachData) { (id, data, error) in
						if error != nil {
							let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
							alert.addAction(.cancel)
							self?.present(alert, animated: true, completion: nil)
							cell.failedSync()
						} else if let dataID = id, let trainingData = data {
							if dataID == "Failed processing image" {
								cell.failedSync()
							} else if trainingData.scores == "0,0,0,0,0,0,0,0,0,0,0,0" {
								cell.queuing()
							} else {
								cell.completeSync()
							}
						}
					}
				} else {
					guard eachData.scores != "0,0,0,0,0,0,0,0,0,0,0,0" else { continue }
					server.updateRequest(label: eachData.scores!, id: eachData.id!) { (id, error) in
						if error != nil {
							let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
							alert.addAction(.cancel)
							self?.present(alert, animated: true, completion: nil)
							cell.failedSync()
						} else if let dataID = id, dataID != "Failed processing image" {
							eachData.uploading = false
							cell.completeSync()
							eachData.save()
						} else {
							cell.failedSync()
						}
					}
				}
			}
		}
	}
	
	@IBAction func navButtonPressed(_ sender: AnyObject) {
		present(imgPicker, animated: true, completion: nil)
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
		guard let identifier = segue.identifier, identifier == "showScoreVC" else { return }
		let destinationVC = segue.destination as! ScoreViewController
		destinationVC.delegate = self
		if let Sender = sender as? Array<Any>, let dataSource = Sender[0] as? TrainingData, let index = Sender[1] as? Int {
			destinationVC.presentingDataSource = dataSource
			destinationVC.presentingDataSourceIndex = index
		}
	}
	
}

// MARK: - Image Picker

extension MainViewController: NohanaImagePickerControllerDelegate {
	private func PH2Image(asset: PHAsset) -> UIImage? {
		let manager = PHImageManager.default()
		let option = PHImageRequestOptions()
		option.isSynchronous = true
		var image: UIImage? = UIImage()
		manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: option) { (result, info) in
			image = result
		}
		return image
	}
	
	func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
	
	func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts: [PHAsset]) {
		guard !pickedAssts.isEmpty else { return }
		let images = pickedAssts.map { PH2Image(asset: $0) }
		let models = images.flatMap { TrainingData.construct(img: $0) }
		dataset.insert(contentsOf: models, at: 0)
		models.forEach { $0.save() }
		picker.dismiss(animated: true, completion: nil)
	}
}

// MARK: - Collection View
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataset.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else { return UICollectionViewCell() }
		let dataSource = dataset[indexPath.row]
		let image = UIImage(data: dataSource.picture as! Data)
		cell.imageView.image = image
		if dataSource.uploading == true || dataSource.scores == "0,0,0,0,0,0,0,0,0,0,0,0" {
			cell.queuing()
		} else {
			cell.completeSync()
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let dataSource = dataset[indexPath.row]
		performSegue(withIdentifier: "showScoreVC", sender: [dataSource, indexPath.row])
		collectionView.deselectItem(at: indexPath, animated: true)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = collectionView.bounds.width
		return CGSize(width: width/3, height: width/3)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}
}

// MARK: - New Data
extension MainViewController: ScoreViewDelegate {
	func newDataCreated(trainingData: TrainingData) {
		dataset.insert(trainingData, at: 0)
		collectionView.reloadData()
	}
}

extension MainViewController: UIViewControllerPreviewingDelegate {
	@available(iOS 9.0, *)
	public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
		if let vc = viewControllerToCommit as? ScoreViewController {
			vc.delegate = self
			navigationController?.show(vc, sender: self)
		} else {
			navigationController?.show(viewControllerToCommit, sender: self)
		}
	}

	func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
		let point = collectionView.convert(location, from: collectionView.superview)
		guard
			let indexPath = collectionView.indexPathForItem(at: point),
			let cell = collectionView.cellForItem(at: indexPath),
		let scoreVC = storyboard?.instantiateViewController(withIdentifier: "ScoreViewController") as? ScoreViewController else {
			return nil
		}
		scoreVC.presentingDataSource = dataset[indexPath.row]
		scoreVC.presentingDataSourceIndex = indexPath.row
		previewingContext.sourceRect = cell.frame
		return scoreVC
	}
}
