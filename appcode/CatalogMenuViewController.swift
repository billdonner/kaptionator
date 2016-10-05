//
//  CatalogMenuViewController.swift
//  ub ori
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//
import UIKit
protocol CatalogMenuViewDelegate {
    func useAsIs(remoteAsset:RemoteAsset)
    func useWithCaption(remoteAsset:RemoteAsset,caption:String)
    func useWithNoCaption(remoteAsset:RemoteAsset)
}
class CatalogMenuViewController: UIViewController,AddDismissButton {
    var remoteAsset:RemoteAsset! // must be set
    var delegate: CatalogMenuViewDelegate?  // mig
    
    private var isAnimated  = false
    fileprivate var changesMade: Bool = false
    
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
    @IBAction func useStickerNoCaptionPressed(_ sender: AnyObject) {
        delegate?.useWithNoCaption (remoteAsset:remoteAsset) // elsewhere
        dismiss(animated: true,completion:nil)
    }
    @IBAction func addCaptionToSticker(_ sender: AnyObject) {
        imageCaption.textColor = .darkGray
 
        imageCaption.becomeFirstResponder()
        imageCaption.isHidden = false
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GetCaptionViewControllerID" ) as? GetCaptionViewController
        if let vc = vc {
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc,animated:true,completion:nil)
        }
        
        
    }
    internal func dismisstapped(_ s: AnyObject) {
        dismiss(animated: true, completion: nil)
         self.performSegue(withIdentifier: "UnwindToCatalogAppVC", sender: s)
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
        isAnimated = remoteAsset.options.contains(.generateasis)
        do {
            let data = try  Data(contentsOf: URL(string:remoteAsset.localimagepath )!)
            menuImageView.image = UIImage(data:data)
            menuImageView.contentMode = .scaleAspectFit
        }
        catch {
            menuImageView.image = nil
        }
       // imageCaption.isEnabled  = false
        imageCaption.text = showVendorTitles ? remoteAsset.caption : ""  // KEEP, its first
        //imageCaption.delegate = self
        //imageCaption.textColor = .white
       // imageCaption.backgroundColor = .clear
       // imageCaption.keyboardAppearance = .dark
        // imageCaption.isHidden = imageCaption.text == ""
        if isAnimated {
            self.addcaption.isHidden = true
            self.useasisnocaption.isHidden = false
            let scale : CGFloat = 1 / 1
            ///  put up animated preview
            self.menuImageView.isHidden = true
            self.animatedLabel.isHidden = false
            webviewOverlay.isHidden  = false
            let w = webviewOverlay.frame.width
            let h = webviewOverlay.frame.height
            let html = "<html5> <meta name='viewport' content='width=device-width, maximum-scale=1.0' /><body  style='padding:0px;margin:0px'><img  style='max-width: 100%; height: auto;' src='\(remoteAsset.localimagepath)' alt='\(remoteAsset.localimagepath) height='\(h * scale)' width='\(w * scale)' ></body></html5>"
            webviewOverlay.scalesPageToFit = true
            webviewOverlay.contentMode = .scaleAspectFit
            webviewOverlay.loadHTMLString(html, baseURL: nil)
        }
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
//MARK:- CALLBACKS
//MARK: UITextFieldDelegate when the single text field gets filled in
//extension CatalogMenuViewController : UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        changesMade = true
//        delegate?.useWithCaption(remoteAsset: remoteAsset, caption: textField.text ?? "")
//        imageCaption.isEnabled  = false
//        textField.resignFirstResponder()
//        dismiss(animated: true,completion:nil)
//        return true
//    }
//}

extension CatalogMenuViewController :GetCaptionDelegate {
    func captionWasEntered(caption: String) {
        changesMade = true
        delegate?.useWithCaption(remoteAsset: remoteAsset, caption: caption )
        imageCaption.isEnabled  = false
    }
}
