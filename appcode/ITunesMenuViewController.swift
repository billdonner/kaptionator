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
    func changedAnimationState(remoteAsset:StickerAsset)
    func deleteAsset(remoteAsset:StickerAsset)
    func useAsIs(remoteAsset:StickerAsset)
    func useWithCaption(remoteAsset:StickerAsset,caption:String)
    func useWithNoCaption(remoteAsset:StickerAsset)
    func refreshLayout() 
}
final class ITunesMenuViewController: UIViewController,ModalOverCurrentContext {
    var pvc:UIViewController! // must be set
    var remoteAsset:StickerAsset! // must be set
    weak var delegate: ITunesMenuViewDelegate?  // mig
    fileprivate var setup = false
    
    @IBAction func unwindToITunesMenuViewController(_ segue: UIStoryboardSegue)  {}
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var webviewOverlay: UIWebView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var imageCaption: UITextField!
    @IBOutlet weak var useasisnocaption: UIButton!
    @IBOutlet weak var addcaption: UIButton!
    @IBOutlet weak var animatedLabel: UILabel!
    @IBOutlet weak var animationSwitch: UISwitch!
    
    @IBAction func animationSwitchTapped(_ sender: AnyObject) {
        addcaption.isEnabled = !animationSwitch.isOn
        addcaption.setTitleColor(animationSwitch.isOn ?
                    .darkGray : .lightGray,for: .normal)
        var  options = remoteAsset.options
        if animationSwitch.isOn {
            options.insert(.generateasis)
        } else {
            options.remove(.generateasis)
        }
        setup = false
        // to persist this seemingly trivial process we must make a whole new StickerAsset
        let newra = remoteAsset.copyWithNewOptions(stickerOptions: options)
        
        StickerAssetSpace.remove(ra:remoteAsset)
        StickerAssetSpace.addasset(ra: newra)
        
        // draw or redraw
        showImageFromLocalAsset(remoteAsset: newra,animate:animationSwitch.isOn)
        StickerAssetSpace.saveToDisk()
        remoteAsset = newra // IMPORTANT - point to new asset
        self.delegate?.changedAnimationState(remoteAsset: newra)
        
    }
    @IBAction func deleteAsset(_ sender: AnyObject) {
        pvc.dismiss(animated: true) {
        self.delegate?.deleteAsset(remoteAsset:self.remoteAsset) // elsewhere
        }
    }
    @IBAction func useStickerNoCaptionPressed(_ sender: AnyObject) {
        pvc.dismiss(animated: true) {
            self.delegate?.useAsIs(remoteAsset:self.remoteAsset) // elsewhere
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
        imageCaption.text = remoteAsset.assetName != "" ? remoteAsset.assetName : "-no caption-"
        
        let isAnimated = remoteAsset.options.contains(.generateasis)
        showImageFromLocalAsset(remoteAsset:remoteAsset,animate: isAnimated)
        
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
    func showImageFromLocalAsset(remoteAsset:StickerAsset,animate:Bool) {
        if let imgurl = remoteAsset.localurl {
        let isAnimated = animate//remoteAsset.options.contains(.generateasis)
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
            let scale : CGFloat = 1 / 1
            ///  put up animated preview
            self.menuImageView.isHidden = true
            self.animatedLabel.isHidden = false
            
            webviewOverlay.isHidden  = false
            if !setup {
                let w = webviewOverlay.frame.width
                let h = webviewOverlay.frame.height
                let html = "<html5> <meta name='viewport' content='width=device-width, maximum-scale=1.0' /><body  style='padding:0px;margin:0px'><img  style='max-width: 100%; height: auto;' src='\(imgurl)' alt='\(imgurl) height='\(h * scale)' width='\(w * scale)' ></body></html5>"
                webviewOverlay.scalesPageToFit = true
                webviewOverlay.contentMode = .scaleAspectFit
                webviewOverlay.loadHTMLString(html, baseURL: nil)
            }
        }
        setup = true
    }
    }
}
//MARK:- CALLBACKS

extension ITunesMenuViewController : GetCaptionDelegate {
    func captionWasEntered(caption: String) {
        delegate?.useWithCaption(remoteAsset: remoteAsset, caption: caption )
        imageCaption.isEnabled  = false
    }
}
