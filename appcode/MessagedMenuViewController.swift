
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

class MessagesAppMenuViewController: UIViewController ,AddDismissButton {
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
    
    @IBOutlet weak var smallSwitch: UISwitch!
    
    @IBOutlet weak var mediumSwitch: UISwitch!
    
    @IBOutlet weak var largeSwitch: UISwitch!
    private func unprepareStickers(_ ce:SharedCE , _ size:String) {
        let id = ce.id
        let pe = ce.localimagepath
        let hashval = "\(ce.caption.hash)"
        let lpc = (pe as NSString).lastPathComponent
        let type = (pe as NSString).pathExtension
        let lsp = (lpc as NSString).deletingPathExtension
        let path = (pe as NSString).deletingLastPathComponent
        let stickerpath = path + "/" + lsp + "-\(size)-\(hashval)." + type
        StickerFileFactory.removeStickerFilesFrom([stickerpath])
        let _ = memSpace.remove(id: id)
    }
    @IBAction func smallSwitchToggled(_ sender: AnyObject) {
        
        let ce = captionedEntry!
        var options: StickerMakingOptions = StickerMakingOptions()
        if smallSwitch.isOn {
            do {  // make image of precise size for messages app
            options.insert(.generatesmall)
           let _  =  try prepareStickers(pack:ce.catalogpack, title:ce.catalogtitle, imagepath: ce.localimagepath, caption: ce.caption, options: options)
            }
            catch {
                print("could not prepareStickers")
            }
        } else {  // delete the image
            unprepareStickers(ce,"S")
                 }
    }
    @IBAction func mediumSwitchToggled(_ sender: AnyObject) {
        let ce = captionedEntry!
        var options: StickerMakingOptions = StickerMakingOptions()
        if mediumSwitch.isOn {
            do {  // make image of precise size for messages app
                options.insert(.generatemedium)
                let _  =  try prepareStickers(pack:ce.catalogpack, title:ce.catalogtitle, imagepath: ce.localimagepath, caption: ce.caption, options: options)
            }
            catch {
                print("could not prepareStickers")
            }
        } else {  // delete the image
            unprepareStickers(ce,"M")
        }    }
    
    @IBAction func largeSwithToggled(_ sender: AnyObject) {
        let ce = captionedEntry!
        var options: StickerMakingOptions = StickerMakingOptions()
        if largeSwitch.isOn {
            do {  // make image of precise size for messages app
                options.insert(.generatelarge)
                let _  =  try prepareStickers(pack:ce.catalogpack, title:ce.catalogtitle, imagepath: ce.localimagepath, caption: ce.caption, options: options)
            }
            catch {
                print("could not prepareStickers")
            }
        } else {  // delete the image
            unprepareStickers(ce,"L")
        }
    }
 
    var webViewOverlay: UIWebView?
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
    
    //MARK:- VC LIFECYLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //openinimessage.setTitleColor( appTheme.buttonTextColor, for: .normal)
      //  removefromimessage.setTitleColor( appTheme.buttonTextColor, for: .normal)
        //veryBottomButton.setTitleColor( appTheme.buttonTextColor, for: .normal)
        let options = captionedEntry.stickerOptions
        isAnimated = options.contains(.generateasis)
        
       
        
        imageCaption.isEnabled  = false
        
        imageCaption.textColor = .white
        imageCaption.backgroundColor = .clear

        do {
            let data = try  Data(contentsOf: URL(string:captionedEntry.localimagepath)!)
            menuImage.image = UIImage(data:data)
            menuImage.contentMode = .scaleAspectFit
        }
        catch {
            menuImage.image = nil
        }
        
        imageCaption.text =  captionedEntry.caption 
        
        
        
        let imgsize = menuImage.image!.size
        
            smallSwitch.isEnabled = false
            mediumSwitch.isEnabled = false
            largeSwitch.isEnabled = false
       
            //if imgsize.width >= CGFloat(618) {
                largeSwitch.isOn = checkForFileVariant(captionedEntry,"L")
            //}
            
            //if imgsize.width >= CGFloat(408) {
                mediumSwitch.isOn = checkForFileVariant(captionedEntry,"M")
            //}
            
            //if imgsize.width >= CGFloat(300) {
                smallSwitch.isOn = checkForFileVariant(captionedEntry,"S")
//}
        
        if !isAnimated {
            if imgsize.width >= CGFloat(618) {
                largeSwitch.isEnabled = true
            }
            
            if imgsize.width >= CGFloat(408) {
                mediumSwitch.isEnabled = true
            }
            
            if imgsize.width >= CGFloat(300) {
                smallSwitch.isEnabled = true
            }
        }
        
        
       
        if isAnimated {
            
            self.menuImage.isHidden = true
            self.animatedLabel.isHidden = false
        
            webViewOverlay = animatedViewOf(frame:self.view.frame, size:menuImage.image!.size, imageurl: captionedEntry.localimagepath)
            self.view.addSubview(webViewOverlay!)
            addDismissButtonToViewController(self , named:appTheme.dismissButtonImageName,#selector(dismisstapped))
            
            return
        }
        
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
        
        
    }
    func dismisstapped(_ s: AnyObject) {
       //// dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "UnwindToMessagesAppVC", sender: s)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
