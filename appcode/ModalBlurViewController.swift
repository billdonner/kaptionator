//
//  CaptionedMenuViewController.swift
//  ub ori
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//

import UIKit
// This is useful for building help overlays in Storyboard View Controller Panels

class InnerBlurViewController: UIViewController {
    
}
class StartupHelpViewController: ReverseModalBlurViewController {
    
@IBOutlet    var pic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pic.image = UIImage(named:backgroundImagePath)
        
    }
}
class ReverseModalBlurViewController: InnerBlurViewController, AddDismissButton {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loadingthe view.
        
        //print("ModalBlurViewController")
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
        
    }
    func dismisstapped(_ s: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}
class ModalBlurViewController: InnerBlurViewController, AddDismissButton {
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loadingthe view.

        //print("ModalBlurViewController")
        addDismissButtonToViewController(self , named:appTheme.dismissButtonImageName,#selector(dismisstapped)) 
        
    }
    func dismisstapped(_ s: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}

