//
//  MoreMenuViewController.swift
//  kaptionator
//
//  Created by bill donner on 9/21/16.
//  Copyright © 2016 Bill Donner/ midnightrambler. All rights reserved.
//

import UIKit

import stikz


final class MoreMenuViewController: UIViewController, ModalOverCurrentContext  {
    func dismisstapped(_ s: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    // place to open website
    
    @IBAction func websitetapped(_ sender: AnyObject) {
        IOSSpecialOps.openwebsite(self)
        // dismiss(animated: true,completion:nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
    }
}
