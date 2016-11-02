//
//  SFViewController.swift
//  shtickerz
//
//  Created by bill donner on 7/14/16.
//  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
//

import UIKit
import SafariServices
import stikz

public    func openwebsite(_ presentor:UIViewController) {
    
    let url = URL(string:websitePath)!
    let vc = SFViewController(url: url)
    let nav = UINavigationController(rootViewController: vc)
    vc.delegate =  vc
    presentor.present(nav, animated: true, completion: nil)
}
public   func openInAnotherApp(url:URL)->Bool {
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url,options:[:]){ b in }
        return true
    }
    return false
}
/// SFViewController wraps sfafari
class SFViewController: SFSafariViewController {
 
    func done(_:AnyObject){
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.done)) 
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

