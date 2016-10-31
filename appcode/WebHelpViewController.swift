//
//  WebHelpViewController.swift
//  Re-Kaptionator
//
//  Created by bill donner on 8/17/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//

import UIKit


final class WebsiteOverlayViewController:UIViewController, UIWebViewDelegate,ModalOverCurrentContext  {
    let  urlRequest : URLRequest = {
        return URLRequest(url:URL(string: websitePath )!)
    }()
    
    @IBOutlet weak var webView: UIWebView!
    
    func dismisstapped (_ s:AnyObject) {dismiss(animated: true)}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.webView.delegate = self
        self.webView.loadRequest(urlRequest)
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        addDismissButtonToViewController(self ,named:appTheme.dismissButtonAltImageName, #selector(self.dismisstapped))
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let x = error as NSError
        IOSSpecialOps.blurt(self,title: "Network error code = \(x.code)",mess: error.localizedDescription)
    }

}
final class WebHelpViewController:UIViewController, UIWebViewDelegate,ModalOverCurrentContext  {
    let  urlRequest : URLRequest = {
        return URLRequest(url:URL(string:websitePath +  "/apphelp.html" )!)
    }()
    
    @IBOutlet weak var webView: UIWebView!
    
    func dismisstapped (_ s:AnyObject) {dismiss(animated: true)}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.webView.delegate = self
        self.webView.loadRequest(urlRequest)
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        addDismissButtonToViewController(self ,named:appTheme.dismissButtonAltImageName, #selector(self.dismisstapped))
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let x = error as NSError
        IOSSpecialOps.blurt(self,title: "Network error code = \(x.code)",mess: error.localizedDescription)
    }

}
final class AltWebHelpViewController:UIViewController, UIWebViewDelegate,ModalOverCurrentContext  {
    
    
let  urlRequest : URLRequest = {
        return URLRequest(url:URL(string:websitePath +  "/help.html" )!)
    }()
    
    @IBOutlet weak var webView: UIWebView!
    
    func dismisstapped (_ s:AnyObject) {dismiss(animated: true)}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.webView.delegate = self
        self.webView.loadRequest(urlRequest)
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        addDismissButtonToViewController(self ,named:appTheme.dismissButtonAltImageName, #selector(self.dismisstapped))
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let x = error as NSError
        IOSSpecialOps.blurt(self,title: "Network error code = \(x.code)",mess: error.localizedDescription)
    }

}
