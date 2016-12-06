//
//  CatalogMenuViewController.swift
//  Kaptionator
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//
import UIKit

import stikz

protocol CatalogMenuViewDelegate : class {
    func catUseAsIs(stickerAsset:StickerAsset)
    func catUseWithCaption(stickerAsset:StickerAsset,caption:String)
   // func zuseWithNoCaption(stickerAsset:StickerAsset)
    func refreshLayout()
}
final class CatalogMenuViewController: UIViewController,ModalOverCurrentContext {
    var stickerAsset:StickerAsset! // must be set
    weak var delegate: CatalogMenuViewDelegate?  // mig
    
    var pvc:UIViewController! // must be set
    //private var isAnimated  = false
    fileprivate var setup: Bool = false
  
    
    @IBAction func unwindToCatalogMenuViewController(_ segue: UIStoryboardSegue)  {
    }
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var webviewOverlay: UIWebView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var imageCaption: UILabel!
    @IBOutlet weak var useasis: UIButton!
    @IBOutlet weak var useasisnocaption: UIButton!
    @IBOutlet weak var addcaption: UIButton!
    //MARK:- MENU TAP ACTIONS
    @IBOutlet weak var animatedLabel: UILabel!
    
   // @IBOutlet weak var animationSwitch: UISwitch!
    
    @IBOutlet weak var isAnimatedSignifier: UIImageView!
    

    @IBAction func useStickerNoCaptionPressed(_ sender: AnyObject) {
        
        pvc.dismiss(animated: true) {
            
                self.delegate?.catUseAsIs(stickerAsset:self.stickerAsset) // elsewhere
            
//            AppCE.makeNewCaptionCat( from: self.stickerAsset, caption: "" )
            
            // self.delegate?.useWithNoCaption (stickerAsset:self.stickerAsset) // elsewhere
        }
    }
    @IBAction func addCaptionToSticker(_ sender: AnyObject) {
        imageCaption.textColor = .darkGray
        imageCaption.becomeFirstResponder()
        imageCaption.isHidden = false
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GetCaptionViewControllerID" ) as? GetCaptionViewController
        if let vc = vc {
            vc.delegate = self
            
            vc.backgroundImage = menuImageView.image
            vc.unwinder = "UnwindToCatalogAppVC"
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            pvc.dismiss(animated: false) {
                self.pvc.present(vc,animated:true,completion:nil)
            }
        }
    }
    internal func dismisstapped(_ s: AnyObject) {
        
        delegate?.refreshLayout() //make this better
        pvc.dismiss(animated: true, completion: nil)
        //         self.performSegue(withIdentifier: "UnwindToCatalogAppVC", sender: s)
    }
    //MARK:- VC LIFECYLE
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        delegate?.refreshLayout()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCaption.text = stickerAsset.assetName
        useasisnocaption.setTitleColor(appTheme.buttonTextColor, for: .normal)
        addcaption.setTitleColor(appTheme.buttonTextColor, for: .normal)
        // Do any additional setup after loading the view.
        
        let isAnimated = stickerAsset.options.contains(.generateasis)
        showImageFromLocalAsset(stickerAsset:stickerAsset,animate: isAnimated)
        // animated can not me modified
       // animationSwitch.setOn(isAnimated ,animated:true)
        let captionable = !isAnimated || showCatalogID == "ShowITunesID"
        //animationSwitch.isEnabled = showCatalogID == "ShowITunesID"
        
        addcaption.isEnabled = captionable
        addcaption.setTitleColor( captionable ? .white : .darkGray,for: .normal)
  
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
    }
}
//MARK:- CALLBACKS

private extension CatalogMenuViewController {
    func showImageFromLocalAsset(stickerAsset:StickerAsset,animate isAnimated:Bool) {
        if let imgurl = stickerAsset.localurl {
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
                self.useasisnocaption.isHidden = false
                ///  put up animated preview
                self.menuImageView.isHidden = true
                self.animatedLabel.isHidden = false
                
                if !setup {
                    IO.setupAnimationPreview(wv:webviewOverlay,imgurl:imgurl)
                }
                webviewOverlay.isHidden  = false
            }
            setup = true
        }
    }
}

extension CatalogMenuViewController : GetCaptionDelegate {
    func captionWasEntered(caption: String) {
        delegate?.catUseWithCaption(stickerAsset: stickerAsset, caption: caption )
        imageCaption.isEnabled  = false
    }
}
