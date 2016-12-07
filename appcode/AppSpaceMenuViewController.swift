//
//  AppSpaceMenuViewController.swift
//  Kaptionator
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//
import UIKit

//import stikz

protocol AppSpaceMenuDelegate : class {
    func movingtoIMessage(captionedEntry:inout AppCE)
    //func changingCaption( on captionedEntry:inout AppCE,caption:String)
    func cloneWithCaption( captionedEntry:AppCE, caption:String)
    func refreshLayout() 
}
final class AppSpaceMenuViewController: UIViewController, ModalOverCurrentContext {
    var captionedEntry:AppCE! // must be set
    weak var delegate: AppSpaceMenuDelegate?  // mig
    
    var pvc:UIViewController! // must be set
     
    @IBOutlet weak var isAnimatedSignifier: UIImageView!
    private var isAnimated  = false
    fileprivate var setup: Bool = false
    @IBOutlet weak var outerView: UIView!
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
        
        delegate?.refreshLayout() //make this better 
        self.presentingViewController?.dismiss(animated: true, completion: nil)
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
        
        imageCaption.text = captionedEntry.caption
        showImageFromAppCE(ce:captionedEntry,animate: isAnimated)
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
    }

}

private extension AppSpaceMenuViewController {
    func showImageFromAppCE(ce:AppCE,animate isAnimated:Bool) {
       let imgurl = ce.imageurl
         
          self.isAnimatedSignifier.isHidden = !isAnimated
        if !isAnimated {
            menuImageView.isHidden = false
            // only set up once
            webviewOverlay.isHidden  = true
            if !setup {
                do {
                    let data = try  Data(contentsOf:imgurl)
                    menuImageView.image = UIImage(data:data)
                    menuImageView.contentMode = .scaleAspectFit
                }
                catch {
                    menuImageView.image = nil
                }
            }
        } else {
            ///  put up animated preview
            self.menuImageView.isHidden = true 
            if !setup {
                IO.setupAnimationPreview(wv:webviewOverlay,imgurl:imgurl)
            }
            
            webviewOverlay.isHidden  = false
         
        }
        setup = true
    }
}

extension AppSpaceMenuViewController :ChangeCaptionDelegate {
    func captionWasChanged(caption: String) {
       delegate?.cloneWithCaption(captionedEntry:self.captionedEntry, caption: caption )
        imageCaption.isEnabled  = false
    }
}
