//
//  CatalogMenuViewController.swift
//  ub ori
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//

import UIKit
protocol CatalogMenuViewDelegate {
    func useAsIs(remoteAsset:RemoteAsset,keepCaption:Bool)
    func useWithCaption(remoteAsset:RemoteAsset,caption:String)
}

class CatalogMenuViewController: UIViewController,AddDismissButton {
    var remoteAsset:RemoteAsset! // must be set 
    var delegate: CatalogMenuViewDelegate?  // mig
    
    @IBAction func unwindToCatalogMenuViewController(_ segue: UIStoryboardSegue)  {
    }
    
    private var isAnimated  = false
    fileprivate var changesMade: Bool = false
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var imageCaption: UITextField!
    @IBOutlet weak var useasis: UIButton!
    @IBOutlet weak var useasisnocaption: UIButton!
    @IBOutlet weak var addcaption: UIButton!
    
    @IBOutlet weak var webViewOverlay: UIWebView!
      //MARK:- MENU TAP ACTIONS 
    @IBAction func websitetapped(_ sender: AnyObject) {
        IOSSpecialOps.openwebsite(self)
        //dismiss(animated: true,completion:nil)
    }

    @IBOutlet weak var animatedLabel: UILabel!
    @IBAction func useStickerAsIsPressed(_ sender: AnyObject) {
    delegate?.useAsIs(remoteAsset:remoteAsset,keepCaption:true) // elsewhere
        dismiss(animated: true,completion:nil)
    }

    @IBAction func useStickerNoCaptionPressed(_ sender: AnyObject) {
        delegate?.useAsIs(remoteAsset:remoteAsset,keepCaption:false) // elsewhere
        dismiss(animated: true,completion:nil)
    }
    
    @IBAction func addCaptionToSticker(_ sender: AnyObject) {
        imageCaption.textColor = .darkGray
        imageCaption.backgroundColor = .white
        imageCaption.isEnabled = true
        imageCaption.becomeFirstResponder()
    }
    func dismisstapped(_ s: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
  //MARK:- VC LIFECYLE

    override func viewDidLoad() {
        super.viewDidLoad()
        
        useasis.setTitleColor(appTheme.buttonTextColor, for: .normal)
        useasisnocaption.setTitleColor(appTheme.buttonTextColor, for: .normal)
        addcaption.setTitleColor(appTheme.buttonTextColor, for: .normal)
        
        
        // Do any additional setup after loading the view.
        
        isAnimated = remoteAsset.options.contains(.generateasis)
        do {
            let data = try  Data(contentsOf: URL(string:remoteAsset.localimagepath )!)
            menuImage.image = UIImage(data:data)
            menuImage.contentMode = .scaleAspectFit
        }
        catch {
            menuImage.image = nil
        }
        imageCaption.isEnabled  = false
        imageCaption.text = remoteAsset.caption
        imageCaption.delegate = self
        
        imageCaption.textColor = .white
        imageCaption.backgroundColor = .clear
        
        imageCaption.keyboardAppearance = .dark
        animatedLabel.alpha = 0
        if isAnimated {
            self.addcaption.isEnabled = false
            self.addcaption.removeFromSuperview()
            self.useasisnocaption.isEnabled = false
            self.useasisnocaption.removeFromSuperview()
            UIView.animate(withDuration: 10.0, animations: {
                  self.animatedLabel.alpha = 1
            })
        }
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
        
//        let imageurl = remoteAsset.localimagepath
//        let w = self.view.frame.width - 60
//        let h = self.view.frame.height - 60
//      
//          let html = "<html5><body  style='padding:0px;margin:0px'><img src='\(imageurl)' width='\(w)' height='\(h)' alt='\(imageurl)' /></body></html5>"
//        
//
//        webViewOverlay.contentMode = .scaleAspectFit
//        webViewOverlay.loadHTMLString(html, baseURL: nil)
//        webViewOverlay.isHidden = false
        
        

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
extension CatalogMenuViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changesMade = true
        delegate?.useWithCaption(remoteAsset: remoteAsset, caption: imageCaption.text ?? "")
        textField.resignFirstResponder()
        dismiss(animated: true,completion:nil)
        return true
    }
}
