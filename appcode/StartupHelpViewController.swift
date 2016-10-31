//
//  StartupHelpViewController.swift
//  kaptionator
//
//  Created by bill donner on 10/13/16.
//  Copyright © 2016 Bill Donner/ midnightrambler. All rights reserved.
//

import UIKit

final class StartupHelpViewController:  UIViewController, AddDismissButton  {
    
    @IBOutlet weak var pic: UIImageView!
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var topBlurb: UILabel!
    
    
    static var first = true
    func dismisstapped(_ s: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let count = SharedCaptionSpace.itemCount()
        pic.image = UIImage(named:backgroundImagePath)
        topLabel.text = count == 0 ? "Welcome to " + extensionScheme : "you have \(count) stickers in the Messages app"
        topBlurb.text = bigBlurb
        
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
        
    }
}
