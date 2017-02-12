//
//  ImageCell.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-11.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var syncIndicator: UIImageView!
	private lazy var animation: CABasicAnimation = {
		let animation = CABasicAnimation(keyPath: "transform.rotation.z")
		animation.fromValue = Double.pi
		animation.toValue = 0
		animation.duration = 1
		animation.repeatCount = 10
		animation.fillMode = kCAFillModeForwards
		animation.isRemovedOnCompletion = false
		return animation
	}()
	
	func queuing() {
		syncIndicator.image = #imageLiteral(resourceName: "ic_cloud_queue")
	}
	
	func syncing() {
		DispatchQueue.main.async { [weak self] in
			self?.syncIndicator.image = #imageLiteral(resourceName: "ic_cached")
			guard let animation = self?.animation else { return }
			self?.syncIndicator.layer.add(animation, forKey: nil)
		}
	}
	
	func failedSync() {
		DispatchQueue.main.async { [weak self] in
			self?.syncIndicator.layer.removeAllAnimations()
			self?.syncIndicator.image = #imageLiteral(resourceName: "ic_sync_problem")
		}
	}
	
	func completeSync() {
		DispatchQueue.main.async { [weak self] in
			self?.syncIndicator.layer.removeAllAnimations()
			self?.syncIndicator.image = UIImage()
		}
	}
}
