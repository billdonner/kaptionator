//
//  HelpOverlayViewController.swift
//  Re-Kaptionator
//
//  Created by bill donner on 8/17/16.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//

import UIKit
protocol AddDismissButton {
func dismisstapped(_ s:AnyObject)
}
class HelpOverlayViewController: UIViewController, UIWebViewDelegate,AddDismissButton {

    
    @IBOutlet weak var webView: UIWebView!
 
    
    let html = "<center><div style='color:#fff; font-family:-apple-system, Helvetica, Arial, sans-serif;'><h2 style='color:#ff8c00; margin:0px 0 0px 0;'>CANDIDATEZ HELP</h2><hr style='margin-left:100px;margin-right:100px;'><h3 style='color:#ff8c00; margin-bottom:5px;'>1-Select Candidatez Image</h3>From the Catalog Page<br /><span style='font-weight:900;'>&#8226;</span><h3 style='color:#ff8c00; margin:0px 0 0px 0;'>2-Decide on Caption Element</h3>Use the built-in captions or reCaption yourself.<br /><span style='color:#ff8c00;'>(Animated images can not be customized).</span><br /><span style='font-weight:900;'>&#8226;</span><h3 style='color:#b22222; margin:0px 0 0px 0;'>3-Stickerz Are Placed in Stickerz list</h3>Selected items from this list move into iMessage list.<br /><span style='font-weight:900;'>&#8226;</span><h3 style='color:#249bfa; margin:0px 0 0px 0;'>4-Manage Messages Stickerz</h3>These are the Shtikerz you've selected to use in Messages. Keep them sorted here.<br /><span style='font-weight:900;'></span><hr <hr style='margin-left:100px;margin-right:100px;'><h3 style='color:#ff8c00; margin:0px 0 5px 0;'>More tips</h2>Stikerz captions in RED are animated.<br />To delete an item from the list swipe left and select 'Delete'.</div></center>"
    
    
    //"<center><div style='color:#fff; font-family:-apple-system, Helvetica, Arial, sans-serif;'><h2 style='color:#ff8c00; margin:0px 0 0px 0;'>SHTIKERZ HELP</h2><hr><h3 style='color:#ff8c00; margin-bottom:5px;'>1-Select Shtikerz Image</h3>From the Catalog Page<br /><span style='font-weight:900;'>&#8226;</span><h3 style='color:#ff8c00; margin:0px 0 0px 0;'>2-Decide on Caption Element</h3>Use the built-in captions or reCaption yourself.<br /><span style='color:#ff8c00;'>(Animated images can not be customized).</span><br /><span style='font-weight:900;'>&#8226;</span><h3 style='color:#b22222; margin:0px 0 0px 0;'>3-Shtikerz Are Placed in SHTIKERZ list</h3>"//"<center><div style='padding-top:20px;color:#fff; font-family:-apple-system, Helvetica, Arial, sans-serif;'><h2 style='color:#ff8c00; margin:0px 0 -10px 0;'>STICKERS HELP</h2><br /><span style='color:#ff8c00; font-weight:900; font-size:14px;'>1-ADD CAPTIONS</span> <span style='font-weight:900;'>&#8226;</span> <span style='color:#cc0000; font-weight:900; font-size:14px;'>2-CHOOSE</span> <span style='font-weight:900;'>&#8226;</span> <span style='color:#249bfa; font-weight:900; font-size:14px;'>3-USE</span> <hr><h3 style='color:#ff8c00; margin-bottom:5px;'>1-Add Captions to Images From Left Tab</h3>Or use the built-in captions.<span style='color:#ff8c00;'><br />(Animated images can not be customized).</span><br /><span style='font-weight:900;'>&#8226;</span><h3 style='color:#cc0000; margin-bottom:5px;'>2-Choose Stickers For iMessage</h3>Select a bunch of pre-captioned stickers.<br /><span style='font-weight:900;'>&#8226;</span><h3 style='color:#249bfa; margin-bottom:5px;'>3-Manage Your iMessage Stickers</h3>These are the stickers you've selected to use in iMessage. Keep them sorted here.<br /><span style='font-weight:900;'>&#8226;</span></div></center>"
    
    
    // put button in left hand corner
    
    func dismisstapped (_ s:AnyObject) {
        dismiss(animated: true)
    }
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return appTheme.altstatusBarStyle
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        let request = URLRequest(url:URL(string:"http://shtikerz.com/candidatez/apphelp.html")!)
        self.webView.delegate = self
        self.webView.loadRequest(request)
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        addDismissButtonToViewController(self ,named:appTheme.dismissButtonAltImageName, #selector(self.dismisstapped))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
      let x = error as NSError
        
            IOSSpecialOps.blurt(self,title: "Network error code = \(x.code)",mess: error.localizedDescription)
    }
}
