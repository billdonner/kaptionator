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
    var stickerPool:StickerPool = StickerPool()
    override func viewDidLoad() {
       
 
    /// for each JSON swatch in the extension space - expand to one ore more stickers
   
        stickerPool.stickers = []
        stickerPool.makeMSStickersFromMemspace()
        print("&&&&&&&&&& loadFromSharedDataSpace"," got ",stickerPool.stickers.count)
        self.stickerBrowserView.reloadData()
    }//loadstickers
    
    
} //SchtickerzBrowserViewController

extension SchtickerzBrowserViewController {
    func changeBrowserViewBackgroundColor(color:UIColor) {
        let pale = color.withAlphaComponent(0.1)
        stickerBrowserView.backgroundColor = pale
    }
}

extension SchtickerzBrowserViewController { //: MSStickerBrowserViewDataSource {
    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        let  t = stickerPool.stickers.count
        return t 
    }
    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return  stickerPool.stickers[index]
    }
}
