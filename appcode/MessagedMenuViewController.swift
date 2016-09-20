//
//  MessagesAppMenuViewController.swift
//  ub ori
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//

import UIKit
protocol MessagesAppMenuViewDelegate {
    func openinIMessage(captionedEntry:SharedCE)
    func removeFromIMessage(on captionedEntry:inout SharedCE )
}

class MessagesAppMenuViewController: UIViewController , AddDismissButton {
    var captionedEntry:SharedCE! // must be set
    var delegate: MessagesAppMenuViewDelegate?  // mig
    @IBAction func unwindToMessagesAppMenuViewController(_ segue: UIStoryboardSegue)  {}
    
    private var isAnimated  = false
    fileprivate var changesMade: Bool = false
    
    @IBOutlet weak var menuImage: UIImageView!
    
    @IBOutlet weak var imageCaption: UITextField!
    
    @IBOutlet weak var openinimessage: UIButton!
    
    @IBOutlet weak var removefromimessage: UIButton!
    
    @IBOutlet weak var animatedLabel: UILabel!
    
    //MARK:- MENU TAP ACTIONS
    
    
    @IBAction func websitetapped(_ sender: AnyObject) {
        IOSSpecialOps.openwebsite(self) 
    }
    @IBAction func removeimessagetapped(_ sender: AnyObject) {
        delegate?.removeFromIMessage(on: &captionedEntry!)
        dismiss(animated: true,completion:nil)
    }
    @IBAction func openimessagetapped(_ sender: AnyObject) {
        delegate?.openinIMessage(captionedEntry: captionedEntry)
        
        dismiss(animated: true,completion:nil)
    }
    
    
    @IBOutlet weak var veryBottomButton: UIButton!
    //MARK:- VC LIFECYLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //openinimessage.setTitleColor( appTheme.buttonTextColor, for: .normal)
      //  removefromimessage.setTitleColor( appTheme.buttonTextColor, for: .normal)
        veryBottomButton.setTitleColor( appTheme.buttonTextColor, for: .normal)
        
        isAnimated = captionedEntry.stickerOptions.contains(.generateasis)
        
        imageCaption.text = captionedEntry.caption
        imageCaption.isEnabled  = false
        //     imageCaption.delegate = self
        
        imageCaption.textColor = .white
        imageCaption.backgroundColor = .clear

        do {
            let data = try  Data(contentsOf: URL(string:captionedEntry.stickerimagepath )!)
            menuImage.image = UIImage(data:data)
            menuImage.contentMode = .scaleAspectFit
        }
        catch {
            menuImage.image = nil
        }
        
        imageCaption.text = captionedEntry.caption
        
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
        
        
        if isAnimated {
            animatedLabel.textColor = appTheme.redColor
            animatedLabel.text = "animated"
            let w = self.view.frame.width - 100
            let offs = (self.view.frame.width - w) / 2
            let frem = CGRect(x:offs,y:offs,width:w,height:w)
            let imageurl = captionedEntry.localimagepath
            let webViewOverlay = animatedViewOf(frame:frem, imageurl: imageurl)
            self.view.addSubview(webViewOverlay)
            
            
        }
        
    }
    func dismisstapped(_ s: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
