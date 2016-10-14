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
    
@IBOutlet weak     var pic: UIImageView!
    
    @IBOutlet weak var topLabel: UILabel!
    
static var first = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let count = SharedCaptionSpace.itemCount()
        pic.image = UIImage(named:backgroundImagePath)
        topLabel.text = count == 0 ? "Welcome to " + extensionScheme : "you have \(count) stickers in the Messages app"
        
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

