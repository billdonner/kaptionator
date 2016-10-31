//
//  ChangeCaptionViewController
//  kaptionator
//
//  Created by bill donner on 10/4/16.
//  Copyright © 2016 Bill Donner/ midnightrambler. All rights reserved.
//

import UIKit
protocol ChangeCaptionDelegate : class{
    func captionWasEntered(caption:String)
}
final class ChangeCaptionViewController: UIViewController  {
    var delegate: ChangeCaptionDelegate?//todo: figure out why cant make weak
    internal func dismisstapped(_ s: AnyObject) {
        self.performSegue(withIdentifier: "UnwindToCaptionedAppVC", sender: s)
    }
    
    @IBOutlet weak var theCaptionTextView: UITextView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
extension ChangeCaptionViewController:  UITextViewDelegate {
 
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
    
//    func te
}
