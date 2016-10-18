//
//  HelpDropdownViewController.swift
//  kaptionator
//
//  Created by bill donner on 10/15/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

import UIKit
final class HelpDropdownViewController: ReverseModalBlurViewController {
    
    @IBOutlet weak var imageview: UIImageView!
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var subLabel: UILabel!
  
    @IBOutlet weak var bodyLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let count = SharedCaptionSpace.itemCount()
        let remcount = RemSpace.itemCount()
        topLabel.text =  extensionScheme
        subLabel.text =  "Currently you have \(count) stickers in the Messages App"
           bodyLabel.text =  "You have \(remcount) catalog entries as sources to make stickers"
                imageview.image = UIImage(named:backgroundImagePath)
    }
}
