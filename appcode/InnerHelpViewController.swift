//
//  StartupHelpViewController.swift
//  kaptionator
//
//  Created by bill donner on 10/13/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

import UIKit

final class InnerHelpViewController: ReverseModalBlurViewController {
    
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var topBlurb: UILabel!
    static var first = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let count = SharedCaptionSpace.itemCount()
     
        topLabel.text = count == 0 ? "How To Use " + extensionScheme : "you have \(count) stickers in the Messages app"
        topBlurb.text = innerBlurb
        
    }
}
