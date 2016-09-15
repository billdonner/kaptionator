//
//  CaptionedMenuViewController.swift
//  ub ori
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//

import UIKit
protocol CaptionedMenuViewDelegate {
    func movetoIMessage(captionedEntry:inout CaptionedEntry)
    func changeCaption( on captionedEntry:inout CaptionedEntry, caption:String)
    func cloneWithCaption( captionedEntry:CaptionedEntry, caption:String)
}

class CaptionedMenuViewController: UIViewController, AddDismissButton {
    var captionedEntry:CaptionedEntry! // must be set
    var delegate: CaptionedMenuViewDelegate?  // mig
    
    
    @IBAction func unwindToCaptionedMenuViewController(_ segue: UIStoryboardSegue)  {
    }
    private var isAnimated  = false
    fileprivate var changesMade: Bool = false
    
    @IBOutlet weak var animatedLabel: UILabel!
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var imageCaption: UITextField!
   
    @IBOutlet weak var addwithnewcap: UIButton!
    @IBOutlet weak var editsticker: UIButton!
    @IBOutlet weak var moveimessage: UIButton!

      //MARK:- MENU TAP ACTIONS 
    @IBAction func websitetapped(_ sender: AnyObject) {
        IOSSpecialOps.openwebsite(self)
       // dismiss(animated: true,completion:nil)
    }
    
    @IBAction func cloneWithNewCaptionTapped(_ sender: AnyObject) {
        imageCaption.text = ""
        editStickerCaption(sender)
    }
    @IBAction func editStickerCaption(_ sender: AnyObject) { 
        imageCaption.textColor = appTheme.textFieldColor
        imageCaption.backgroundColor = appTheme.textFieldBackgroundColor
        imageCaption.isEnabled = true
        imageCaption.becomeFirstResponder()
    }
    @IBAction func moveToIMessage(_ sender: AnyObject) {
        var newce = captionedEntry!
        delegate?.movetoIMessage(captionedEntry:&newce) // elsewhere
        dismiss(animated: true,completion:nil)
    }
    
    //MARK:- VC LIFECYLE
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
 
    }
    
    @IBOutlet weak var veryBottomButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loadingthe view.
        
        addwithnewcap.setTitleColor( appTheme.buttonTextColor, for: .normal)
        moveimessage.setTitleColor( appTheme.buttonTextColor, for: .normal)
        editsticker.setTitleColor( appTheme.buttonTextColor, for: .normal)
         veryBottomButton.setTitleColor( appTheme.buttonTextColor, for: .normal)
        
        isAnimated = captionedEntry.stickerOptions.contains(.generateasis)
        
        do {
        let data = try  Data(contentsOf: URL(string:captionedEntry.localimagepath )!)
            menuImage.image = UIImage(data:data)
            menuImage.contentMode = .scaleAspectFit
        }
        catch {
            menuImage.image = nil
        }
        
        imageCaption.text = captionedEntry.caption
        imageCaption.isEnabled  = false
        imageCaption.keyboardAppearance = .dark
        imageCaption.delegate = self
        imageCaption.textColor = .white
        imageCaption.backgroundColor = .clear
        if isAnimated {
            addwithnewcap.isEnabled = false
            addwithnewcap.removeFromSuperview()
          //  moveimessage.isEnabled = false
          //  moveimessage.removeFromSuperview()
            editsticker.isEnabled = false
            editsticker.removeFromSuperview()
            
            animatedLabel.textColor = appTheme.redColor
            animatedLabel.text = "animated"
            let w = self.view.frame.width - 100
            let offs = (self.view.frame.width - w) / 2
            let frem = CGRect(x:offs,y:offs,width:w,height:w)
            let imageurl = captionedEntry.localimagepath
            let webViewOverlay = animatedViewOf(frame:frem, imageurl: imageurl)
            self.view.addSubview(webViewOverlay)
        }
        
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped)) 
        
    }
    func dismisstapped(_ s: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

//MARK: UITextFieldDelegate when the single text field gets filled in
extension CaptionedMenuViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        changesMade = true
        
        delegate?.cloneWithCaption(captionedEntry:self.captionedEntry,  caption: imageCaption.text ?? "<!none!>")
        
        
        textField.resignFirstResponder()
        
        dismiss(animated: true,completion:nil)
        return true
    }
}
