//
//  UIAlertAction+Cancel.swift
//  ArcherHelper
//
//  Created by Yaxin Cheng on 2017-02-12.
//  Copyright © 2017 Yaxin Cheng. All rights reserved.
//

import Foundation
import UIKit.UIAlertController

extension UIAlertAction {
	static var cancel: UIAlertAction {
		return UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
	}
}
