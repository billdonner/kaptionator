//
//  GetCaptionViewController.swift
//  kaptionator
//
//  Created by bill donner on 10/4/16.
//  Copyright © 2016 Bill Donner/ midnightrambler. All rights reserved.
//

import UIKit

//import stikz
/// this delegate CAN NOT be weak because it must outlive the viewcontroller that spawned it
protocol GetCaptionDelegate { //:  class {
    func captionWasEntered(caption: String)
}
final class GetCaptionViewController: UIViewController  {
      var delegate: GetCaptionDelegate! // why ant be weak? 
    var backgroundImage: UIImage!
    
    internal func dismisstapped(_ s: AnyObject) {
        
        //delegate?.refreshLayout() //make this better
        self.presentingViewController?.dismiss(animated: true, completion: nil) 
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var theCaptionTextView: UITextView!
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = backgroundImage
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
        theCaptionTextView.delegate = self
        theCaptionTextView.returnKeyType = .go
        theCaptionTextView.becomeFirstResponder()
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension GetCaptionViewController:  UITextViewDelegate {
 
//MARK:- CALLBACKS
////MARK: UITextFieldDelegate when the single text field gets filled in  UITextFieldDelegate {
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        // same as hitting x in upper left
        self.dismisstapped(self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            
            delegate?.captionWasEntered(  caption: textView.text ?? "")
            textView.resignFirstResponder()
            
            // unwindd all the way back
            self.dismisstapped(self)
        }
        return true
    }
 
}
