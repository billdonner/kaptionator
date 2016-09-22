//
//  MoreMenuViewController.swift
//  kaptionator
//
//  Created by bill donner on 9/21/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

import UIKit

class MoreMenuViewController: ReverseModalBlurViewController {
    
    // place to open website
    
    @IBAction func websitetapped(_ sender: AnyObject) {
        IOSSpecialOps.openwebsite(self)
        // dismiss(animated: true,completion:nil)
    }
    
}
