//
//  shtickerzBrowserViewController.swift
//  shtickerz
//
//  Created by bill donner on 6/22/16.
//  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
//

import UIKit
import Messages
import stikz

// creates a set of stickers first time up or when refreshed


final class SchtickerzBrowserViewController : MSStickerBrowserViewController {
    var mesExtVC: MessagesExtensionViewController!
    override func viewDidLoad() {
        
        print("SchtickerzBrowserViewController  >>>>> \(tagLine)")
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
