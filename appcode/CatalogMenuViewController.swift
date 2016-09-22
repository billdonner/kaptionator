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
    
    @IBAction func unwindToCatalogMenuViewController(_ segue: UIStoryboardSegue)  {
    }
    @IBOutlet weak var outerView: UIView!
    
    @IBOutlet weak var veryBottomButton: UIButton!
    private var isAnimated  = false
    fileprivate var changesMade: Bool = false
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var imageCaption: UITextField!
    @IBOutlet weak var useasis: UIButton!
    @IBOutlet weak var useasisnocaption: UIButton!
    @IBOutlet weak var addcaption: UIButton!
    
    
    var webViewOverlay: UIWebView?
    //MARK:- MENU TAP ACTIONS

    @IBOutlet weak var animatedLabel: UILabel!
    @IBAction func useStickerAsIsPressed(_ sender: AnyObject) {
     delegate?.useAsIs(remoteAsset:remoteAsset) // elsewhere
     dismiss(animated: true,completion:nil)
    }
    
    @IBAction func useStickerNoCaptionPressed(_ sender: AnyObject) {
    delegate?.useWithNoCaption (remoteAsset:remoteAsset) // elsewhere
        dismiss(animated: true,completion:nil)
    }
    
    @IBAction func addCaptionToSticker(_ sender: AnyObject) {
        imageCaption.textColor = .darkGray
        imageCaption.backgroundColor = .white
        imageCaption.isEnabled = true
        imageCaption.becomeFirstResponder()
        
        imageCaption.isHidden = false
    }
    func dismisstapped(_ s: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    //MARK:- VC LIFECYLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //veryBottomButton.setTitleColor( appTheme.buttonTextColor, for: .normal)
        
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
        
        imageCaption.isHidden = imageCaption.text == ""
        if isAnimated {
            self.addcaption.isHidden = true
            self.useasisnocaption.isHidden = true
            
           // self.useasis.isHidden = true
            
            self.animatedLabel.isHidden = true
            self.menuImage.isHidden = true 
            
            webViewOverlay = animatedViewOf(frame:self.view.frame, size:menuImage.image!.size, imageurl: remoteAsset.localimagepath)
            self.view.addSubview(webViewOverlay!)

            addDismissButtonToViewController(self , named:appTheme.dismissButtonImageName,#selector(dismisstapped))
            
            return
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
extension CatalogMenuViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changesMade = true
        delegate?.useWithCaption(remoteAsset: remoteAsset, caption: imageCaption.text ?? "")
        
        imageCaption.isEnabled  = false
        textField.resignFirstResponder()
        dismiss(animated: true,completion:nil)
        return true
    }
}
