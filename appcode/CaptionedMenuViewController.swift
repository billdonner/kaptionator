//
//  CaptionedMenuViewController.swift
//  Kaptionator
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//
import UIKit

import stikz

protocol CaptionedMenuViewDelegate : class {
    func movingtoIMessage(captionedEntry:inout AppCE)
    func changingCaption( on captionedEntry:inout AppCE,caption:String)
    func cloneWithCaption( captionedEntry:AppCE, caption:String)
}
final class CaptionedMenuViewController: UIViewController, ModalOverCurrentContext {
    var captionedEntry:AppCE! // must be set
    weak var delegate: CaptionedMenuViewDelegate?  // mig
    
    var pvc:UIViewController! // must be set
    
    @IBAction func unwindToCaptionedMenuViewController(_ segue: UIStoryboardSegue)  {}
    
    private var isAnimated  = false
    fileprivate var setup: Bool = false
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var animatedLabel: UILabel!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var webviewOverlay: UIWebView!
    @IBOutlet weak var imageCaption: UILabel!
    @IBOutlet weak var editsticker: UIButton!
    @IBOutlet weak var moveimessage: UIButton!
    //MARK:- MENU TAP ACTIONS
      
    @IBAction func cloneWithNewCaptionTapped(_ sender: AnyObject) {
        imageCaption.text = ""
        editStickerCaption(sender)
    }
    @IBAction func editStickerCaption(_ sender: AnyObject) {

        imageCaption.becomeFirstResponder()
  
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChangeCaptionViewControllerID" ) as? ChangeCaptionViewController
        if let vc = vc {
            vc.delegate = self
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            pvc.dismiss(animated: false){
                //first get rid of ourselves, then presenty on the parent
            self.pvc.present(vc,animated:true,completion:nil)
            }
        }
    }
    @IBAction func moveToIMessageHit(_ sender: AnyObject) {
        var newce = captionedEntry!
        delegate?.movingtoIMessage(captionedEntry:&newce) // elsewhere
        dismiss(animated: true,completion:nil)
    }
    internal func dismisstapped(_ s: AnyObject) {
        //// dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "UnwindToCaptionedAppVC", sender: s)
    }
    
    //MARK:- VC LIFECYLE
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loadingthe view.
        moveimessage.setTitleColor( appTheme.buttonTextColor, for: .normal)
        editsticker.setTitleColor( appTheme.buttonTextColor, for: .normal)
        isAnimated = captionedEntry.stickerOptions.contains(.generateasis)
        
        showImageFromAppCE(ce:captionedEntry,animate: isAnimated)
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
    }

}

private extension CaptionedMenuViewController {
    func showImageFromAppCE(ce:AppCE,animate:Bool) {
        
        let isAnimated = animate//remoteAsset.options.contains(.generateasis)
        if !isAnimated {
            menuImageView.isHidden = false
            // only set up once
            webviewOverlay.isHidden  = true
            if !setup {
                do {
                    let data = try  Data(contentsOf: URL(string:ce.localimagepath )!)
                    menuImageView.image = UIImage(data:data)
                    menuImageView.contentMode = .scaleAspectFit
                }
                catch {
                    menuImageView.image = nil
                }
            }
        } else {
           // self.useasisnocaption.isHidden = false
            let scale : CGFloat = 1 / 1
            ///  put up animated preview
            self.menuImageView.isHidden = true
            self.animatedLabel.isHidden = false
            
            webviewOverlay.isHidden  = false
            if !setup {
                let w = webviewOverlay.frame.width
                let h = webviewOverlay.frame.height
                let html = "<html5> <meta name='viewport' content='width=device-width, maximum-scale=1.0' /><body  style='padding:0px;margin:0px'><img  style='max-width: 100%; height: auto;' src='\(ce.localimagepath)' alt='\(ce.localimagepath) height='\(h * scale)' width='\(w * scale)' ></body></html5>"
                webviewOverlay.scalesPageToFit = true
                webviewOverlay.contentMode = .scaleAspectFit
                webviewOverlay.loadHTMLString(html, baseURL: nil)
            }
        }
        setup = true
    }
}

extension CaptionedMenuViewController :ChangeCaptionDelegate {
    func captionWasEntered(caption: String) {
       delegate?.cloneWithCaption(captionedEntry:self.captionedEntry, caption: caption )
        imageCaption.isEnabled  = false
    }
}
