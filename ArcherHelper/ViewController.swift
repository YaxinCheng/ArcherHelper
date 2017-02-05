//
//  ViewController.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-05.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var zeroField: UITextField!
	@IBOutlet weak var oneField: UITextField!
	@IBOutlet weak var twoField: UITextField!
	@IBOutlet weak var threeField: UITextField!
	@IBOutlet weak var fourField: UITextField!
	@IBOutlet weak var fiveField: UITextField!
	@IBOutlet weak var sixField: UITextField!
	@IBOutlet weak var sevenField: UITextField!
	@IBOutlet weak var eightField: UITextField!
	@IBOutlet weak var nineField: UITextField!
	@IBOutlet weak var tenField: UITextField!
	
	private let imgPicker = UIImagePickerController()
	
	private var screenUp: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		imgPicker.delegate = self
		imgPicker.allowsEditing = true
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowup(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardClose(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
		zeroField.text = ""
		oneField.text = ""
		twoField.text = ""
		threeField.text = ""
		fourField.text = ""
		fiveField.text = ""
		sixField.text = ""
		sevenField.text = ""
		eightField.text = ""
		nineField.text = ""
		tenField.text = ""
	}
	
	private func format(_ data: String) -> String {
		return data.isEmpty ? "0" : data
	}
	
	private func gatherInfo() -> String? {
		guard
			let zero = zeroField.text,
			let one = oneField.text,
			let two = twoField.text,
			let three = threeField.text,
			let four = fourField.text,
			let five = fiveField.text,
			let six = sixField.text,
			let seven = sevenField.text,
			let eight = eightField.text,
			let nine = nineField.text,
			let ten = tenField.text
		else { return nil }
		return String(format: "%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@", format(zero), format(one), format(two), format(three), format(four), format(five), format(six), format(seven), format(eight), format(nine), format(ten))
	}

	@IBAction func confirmPressed(_ sender: UIButton) {
		let server = ServerConnector()
		guard let label = gatherInfo() else { return }
		guard let image = imageView.image, let imageData = UIImageJPEGRepresentation(image, 0.5)?.base64EncodedString() else {
			let alert = UIAlertController(title: "No image", message: nil, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
			present(alert, animated: true, completion: nil)
			return
		}
		navigationItem.title = "Uploading ..."
		server.sendRequest(with: ["img": imageData, "label": label]) { [weak self] (json, error) in
			if error != nil {
				let alert = UIAlertController(title: nil, message: error?.localizedDescription, preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
				self?.navigationItem.title = "Failed"
				self?.present(alert, animated: true, completion: nil)
			} else {
				if json["Result"] as! String == "Success" {
					self?.navigationItem.title = "Success"
					self?.clearFields()
				} else {
					self?.navigationItem.title = "Failed"
					let alert = UIAlertController(title: "Failed", message: nil, preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
					self?.present(alert, animated: true, completion: nil)
				}
			}
		}
	}

	@IBAction func imageViewPressed(_ sender: UIControl) {
		let alert = UIAlertController(title: nil, message: "Pick a way to get image", preferredStyle: .actionSheet)
		let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
			self?.imgPicker.sourceType = .camera
			self?.imgPicker.cameraCaptureMode = .photo
			self?.imgPicker.showsCameraControls = true
			guard let picker = self?.imgPicker else { return }
			self?.present(picker, animated: true, completion: nil)
		}
		let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
			self?.imgPicker.sourceType = .photoLibrary
			guard let picker = self?.imgPicker else { return }
			self?.present(picker, animated: true, completion: nil)
		}
		alert.addAction(cameraAction)
		alert.addAction(libraryAction)
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	@IBAction func touchToCloseKeyboard(_ sender: Any) {
		view.endEditing(true)
	}
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
		clearFields()
		picker.dismiss(animated: true, completion: nil)
	}
}
