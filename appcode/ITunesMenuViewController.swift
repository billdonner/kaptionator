//
//  ITunesMenuViewController
//  Kaptionator
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//

import UIKit

import stikz

protocol ITunesMenuViewDelegate : class {
    func changedAnimationState(stickerAsset:StickerAsset)
    func deleteAsset(stickerAsset:StickerAsset)
    func useAsIs(stickerAsset:StickerAsset)
    func useWithCaption(stickerAsset:StickerAsset,caption:String)
   // func xuseWithNoCaption(stickerAsset:StickerAsset)
    func refreshLayout() 
}
final class ITunesMenuViewController: UIViewController,ModalOverCurrentContext {
    var pvc:UIViewController! // must be set
    var stickerAsset:StickerAsset! // must be set
    weak var delegate: ITunesMenuViewDelegate?  // mig
    fileprivate var setup = false
    
    @IBAction func unwindToITunesMenuViewController(_ segue: UIStoryboardSegue)  {}
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var webviewOverlay: UIWebView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var imageCaption: UITextField!
    @IBOutlet weak var useasisnocaption: UIButton!
    @IBOutlet weak var addcaption: UIButton!
    @IBOutlet weak var animationSwitch: UISwitch!
    
    @IBOutlet weak var isAnimatedSignifier: UIImageView!
    
    @IBAction func animationSwitchTapped(_ sender: AnyObject) {
        addcaption.isEnabled = !animationSwitch.isOn
        addcaption.setTitleColor(animationSwitch.isOn ?
                    .darkGray : .lightGray,for: .normal)
        var  options = stickerAsset.options
        if animationSwitch.isOn {
            options.insert(.generateasis)
        } else {
            options.remove(.generateasis)
        }
        setup = false
        // to persist this seemingly trivial process we must make a whole new StickerAsset
        let newra = stickerAsset.copyWithNewOptions(stickerOptions: options)
        StickerAssetSpace.remove(ra:stickerAsset)
        StickerAssetSpace.addasset(ra: newra)
        // draw or redraw
        showImageFromLocalAsset(stickerAsset: newra,animate:animationSwitch.isOn)
        StickerAssetSpace.saveToDisk()
        stickerAsset = newra // IMPORTANT - point to new asset
        self.delegate?.changedAnimationState(stickerAsset: newra)
    }
    @IBAction func deleteAsset(_ sender: AnyObject) {
        pvc.dismiss(animated: true) {
        self.delegate?.deleteAsset(stickerAsset:self.stickerAsset) // elsewhere
        }
    }
    @IBAction func useStickerNoCaptionPressed(_ sender: AnyObject) {
        pvc.dismiss(animated: true) {
            self.delegate?.useAsIs(stickerAsset:self.stickerAsset) // elsewhere
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
            vc.unwinder = "UnwindToITunesAppVC"
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            pvc.dismiss(animated: false) {
                self.pvc.present(vc,animated:true,completion:nil)
            }
        }
    }
    func dismisstapped(_ s: AnyObject) {
        delegate?.refreshLayout() //make this better
        pvc.dismiss(animated: true, completion: nil)
    }
    //MARK:- VC LIFECYLE
    override func didMove(toParentViewController parent: UIViewController?) {
        delegate?.refreshLayout()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        useasisnocaption.setTitleColor(appTheme.buttonTextColor, for: .normal)
        addcaption.setTitleColor(appTheme.buttonTextColor, for: .normal)
        
        // Do any additional setup after loading the view.
        
        imageCaption.isEnabled  = true
        imageCaption.text = stickerAsset.assetName != "" ? stickerAsset.assetName : "-no caption-"
        
        let isAnimated = stickerAsset.options.contains(.generateasis)
        showImageFromLocalAsset(stickerAsset:stickerAsset,animate: isAnimated)
        
        // animated can not me modified
        animationSwitch.setOn(isAnimated ,animated:true)
        let captionable = !isAnimated || showCatalogID == "ShowITunesID"
        animationSwitch.isEnabled = showCatalogID == "ShowITunesID"
        
        addcaption.isEnabled = captionable
        addcaption.setTitleColor( captionable ? .white : .darkGray,for: .normal)
        
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
    }
}
private extension ITunesMenuViewController {
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
            if !setup {
                IO.setupAnimationPreview(wv:webviewOverlay,imgurl:imgurl)
            }
            webviewOverlay.isHidden  = false
        }
        setup = true
    }
    }
}
//MARK:- CALLBACKS
extension ITunesMenuViewController : GetCaptionDelegate {
    func captionWasEntered(caption: String) {
        delegate?.useWithCaption(stickerAsset: stickerAsset, caption: caption )
        imageCaption.isEnabled  = false
    }
}
