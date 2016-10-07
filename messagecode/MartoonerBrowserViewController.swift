//
//  shtickerzBrowserViewController.swift
//  shtickerz
//
//  Created by bill donner on 6/22/16.
//  Copyright © 2016 martoons. All rights reserved.
//

import UIKit
import Messages

// creates a set of stickers first time up or when refreshed


final class SchtickerzBrowserViewController : MSStickerBrowserViewController {
    var mesExtVC: MessagesExtensionViewController!
    override func viewDidLoad() {
        
        // the messages extension vc has the sticker pool under its watch
                mesExtVC.resetStickerPool()

              self.stickerBrowserView.reloadData()
    }//loadstickers
    
    
} //SchtickerzBrowserViewController

extension SchtickerzBrowserViewController {
    func changeBrowserViewBackgroundColor(color:UIColor) {
        let pale = color.withAlphaComponent(0.1)
        stickerBrowserView.backgroundColor = pale
    }
}
