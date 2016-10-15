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
 
final class WebsiteOverlayViewController:InnerOverlayViewController {
    override func getreq () -> URLRequest {
        let urlasstring = websitePath ///+ extensionScheme.lowercased()
        return URLRequest(url:URL(string: urlasstring )!)
    }
}
final class HelpOverlayViewController:InnerOverlayViewController {
    override func getreq () -> URLRequest {
    let urlasstring = websitePath // + extensionScheme.lowercased()
        +  "/apphelp.html"
    return URLRequest(url:URL(string:urlasstring )!)
    }
}
final class AltHelpOverlayViewController:InnerOverlayViewController {
    override func getreq () -> URLRequest {
        let urlasstring = websitePath // + extensionScheme.lowercased()
            +  "/help.html"
        return URLRequest(url:URL(string:urlasstring )!)
        
    }
}
class InnerOverlayViewController: UIViewController, UIWebViewDelegate,AddDismissButton {

    func getreq () -> URLRequest {
        fatalError("must subclass")
    }
    
    @IBOutlet weak var webView: UIWebView!
 
    // put button in left hand corner
    
    func dismisstapped (_ s:AnyObject) {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
      
        self.webView.delegate = self
        let request = getreq()
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
