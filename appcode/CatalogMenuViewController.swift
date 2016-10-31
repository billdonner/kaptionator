//
//  CatalogMenuViewController.swift
//  Kaptionator
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//
import UIKit
protocol CatalogMenuViewDelegate : class {
    func useAsIs(remoteAsset:RemoteAsset)
    func useWithCaption(remoteAsset:RemoteAsset,caption:String)
    func useWithNoCaption(remoteAsset:RemoteAsset)
}
final class CatalogMenuViewController: UIViewController,ModalOverCurrentContext {
    var remoteAsset:RemoteAsset! // must be set
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
    
    @IBOutlet weak var animationSwitch: UISwitch!
    
    @IBAction func animationSwitchTapped(_ sender: AnyObject) {
        
        addcaption.isEnabled = !animationSwitch.isOn
        addcaption.setTitleColor(animationSwitch.isOn ? .darkGray : .lightGray,for: .normal)
        var  options = remoteAsset.options
        if animationSwitch.isOn {
            options.insert(.generateasis)
        } else {
            options.remove(.generateasis)
        }
        // to persist this seemingly trivial process we must make a whole new RemoteAsset
        let newra = remoteAsset.copyWithNewOptions(stickerOptions: options)
        
        RemSpace.remove(ra:remoteAsset)
        RemSpace.addasset(ra: newra)
        RemSpace.saveToDisk()
        
    }
    @IBAction func useStickerNoCaptionPressed(_ sender: AnyObject) {
        
        pvc.dismiss(animated: true) {
            self.delegate?.useWithNoCaption (remoteAsset:self.remoteAsset) // elsewhere
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
        pvc.dismiss(animated: true, completion: nil)
        //         self.performSegue(withIdentifier: "UnwindToCatalogAppVC", sender: s)
    }
    //MARK:- VC LIFECYLE
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        useasisnocaption.setTitleColor(appTheme.buttonTextColor, for: .normal)
        addcaption.setTitleColor(appTheme.buttonTextColor, for: .normal)
        // Do any additional setup after loading the view.
        
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
//MARK:- CALLBACKS

private extension CatalogMenuViewController {
    func showImageFromLocalAsset(remoteAsset:RemoteAsset,animate:Bool) {
        
        let isAnimated = animate//remoteAsset.options.contains(.generateasis)
        if !isAnimated {
            menuImageView.isHidden = false
            // only set up once
            webviewOverlay.isHidden  = true
            if !setup {
                do {
                    let data = try  Data(contentsOf: URL(string:remoteAsset.localimagepath )!)
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
                let html = "<html5> <meta name='viewport' content='width=device-width, maximum-scale=1.0' /><body  style='padding:0px;margin:0px'><img  style='max-width: 100%; height: auto;' src='\(remoteAsset.localimagepath)' alt='\(remoteAsset.localimagepath) height='\(h * scale)' width='\(w * scale)' ></body></html5>"
                webviewOverlay.scalesPageToFit = true
                webviewOverlay.contentMode = .scaleAspectFit
                webviewOverlay.loadHTMLString(html, baseURL: nil)
            }
        }
        setup = true
        
    }
}
extension CatalogMenuViewController : GetCaptionDelegate {
    func captionWasEntered(caption: String) {
        delegate?.useWithCaption(remoteAsset: remoteAsset, caption: caption )
        imageCaption.isEnabled  = false
    }
}
