//
//  NoContentViewController.swift
//  kaptionator
//
//  Created by bill donner on 11/19/16.
//  Copyright © 2016 midnightrambler. All rights reserved.

import UIKit
protocol UserInteractionSignalDelegate {
    func backToCallerAndDismiss ()
}
final class NoCatalogContentViewController:UIViewController {
    var delegate:UserInteractionSignalDelegate?
    
    @IBAction func exitController() {
        delegate?.backToCallerAndDismiss()
    }
}
final class NoITunesContentViewController:UIViewController {
    var delegate:UserInteractionSignalDelegate?
    
    @IBAction func exitController() {
        delegate?.backToCallerAndDismiss()
    }
}
final class NoMessagesContentViewController:UIViewController {
    var delegate:UserInteractionSignalDelegate?
    
    @IBAction func exitController() {
        delegate?.backToCallerAndDismiss()
    }
}
final class NoHistoryContentViewController:UIViewController {
    var delegate:UserInteractionSignalDelegate?
    
    @IBAction func exitController() {
        delegate?.backToCallerAndDismiss()
    }
}
