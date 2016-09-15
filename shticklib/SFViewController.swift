//
//  SFViewController.swift
//  shtickerz
//
//  Created by bill donner on 7/14/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

import UIKit
import SafariServices

/// SFViewController wraps sfafari
class SFViewController: SFSafariViewController {
 
    func done(_:AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done))
        self.navigationItem.title = remSpace.catalogTitle
    }
}

extension SFViewController : SFSafariViewControllerDelegate {
    func allDone(_:AnyObject) {
        print ("AllDone ")
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        print("+++++ safariViewControllerDidFinish  \(controller)")
    }
    
    private func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: NSURL, title: String?) -> [UIActivity] {
        print("+++++ safariViewController activityItemsFor  \(controller)")
        return []
    }
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        print("+++++ safariViewController didCompleteInitialLoad  \(controller)")
        
        
    }
}

