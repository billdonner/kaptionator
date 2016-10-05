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

/// All the heavy lifting and file manipulation is done on this side of the fence
/// The Messages Extension code passes the filepaths to msSticker API without ever touching them, for a fast start

class MessagesAppMenuViewController: UIViewController ,AddDismissButton {
    
    var captionedEntry:SharedCE! // must be set
    var delegate: MessagesAppMenuViewDelegate?  // mig
    
    @IBAction func unwindToMessagesAppMenuViewController(_ segue: UIStoryboardSegue)  {}
    
    private var isAnimated  = false
    fileprivate var changesMade: Bool = false
    
    @IBOutlet weak var webviewOverlay: UIWebView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var imageCaption: UITextField!
    @IBOutlet weak var openinimessage: UIButton!
    @IBOutlet weak var removefromimessage: UIButton!
    @IBOutlet weak var animatedLabel: UILabel!
    @IBOutlet weak var smallSwitch: UISwitch!
    @IBOutlet weak var mediumSwitch: UISwitch!
    @IBOutlet weak var largeSwitch: UISwitch!
    
    /// delete files to correspond to current state of the shared space
    
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
        let _ = SharedCaptionSpace.remove(id: id)
    }
    
    /// go back with manual unwind so caller (MessageViewController) can repaint with new data model
    internal func dismisstapped(_ s: AnyObject) {
        //// dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "UnwindToMessagesAppVC", sender: s)
    }

        //MARK:- MENU TAP ACTIONS
    @IBAction func smallSwitchToggled(_ sender: AnyObject) {
        let ce = captionedEntry!
        var options: StickerMakingOptions = StickerMakingOptions()
        if smallSwitch.isOn {
            do {  // make image of precise size for messages app
                options.insert(.generatesmall)
                let _  =  try prepareStickers(pack:ce.catalogpack, title:ce.catalogtitle, imagepath: ce.localimagepath, caption: ce.caption, options: options)
                SharedCaptionSpace.saveData()
            }
            catch {
                print("could not prepareStickers")
            }
        } else {  // delete the image
            unprepareStickers(ce,"S")
        }
        SharedCaptionSpace.saveData()
    }
    @IBAction func mediumSwitchToggled(_ sender: AnyObject) {
        let ce = captionedEntry!
        var options: StickerMakingOptions = StickerMakingOptions()
        if mediumSwitch.isOn {
            do {  // make image of precise size for messages app
                options.insert(.generatemedium)
                let _  =  try prepareStickers(pack:ce.catalogpack, title:ce.catalogtitle, imagepath: ce.localimagepath, caption: ce.caption, options: options)
                SharedCaptionSpace.saveData()
            }
            catch {
                print("could not prepareStickers")
            }
        } else {  // delete the image
            unprepareStickers(ce,"M")
        }
        SharedCaptionSpace.saveData()
    }
    @IBAction func largeSwithToggled(_ sender: AnyObject) {
        let ce = captionedEntry!
        var options: StickerMakingOptions = StickerMakingOptions()
        if largeSwitch.isOn {
            do {  // make image of precise size for messages app
                options.insert(.generatelarge)
                let _  =  try prepareStickers(pack:ce.catalogpack, title:ce.catalogtitle, imagepath: ce.localimagepath, caption: ce.caption, options: options)
                SharedCaptionSpace.saveData()
            }
            catch {
                print("could not prepareStickers")
            }
        } else {  // delete the image
            unprepareStickers(ce,"L")
        }
        SharedCaptionSpace.saveData()
    }
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
        let options = captionedEntry.stickerOptions
        isAnimated = options.contains(.generateasis)
        imageCaption.isEnabled  = false
        imageCaption.textColor = .white
        imageCaption.backgroundColor = .clear
        do {
            let path = captionedEntry.stickerPaths[0]
            let data = try  Data(contentsOf: URL(string:path)!)
            menuImageView.image = UIImage(data:data)
            menuImageView.contentMode = .scaleAspectFit
        }
        catch {
            menuImageView.image = nil
        }
        imageCaption.text =  captionedEntry.caption
        let imgsize = menuImageView.image!.size
        smallSwitch.isEnabled = false
        mediumSwitch.isEnabled = false
        largeSwitch.isEnabled = false
        if isAnimated {
            smallSwitch.isOn = false
            mediumSwitch.isOn = false
            largeSwitch.isOn = false
            if imgsize.width >= kStickerLargeSize {
                largeSwitch.isOn = true
            } else
                if imgsize.width >= kStickerMediumSize {
                    mediumSwitch.isOn = true
                } else
                    if imgsize.width >= kStickerSmallSize {
                        smallSwitch.isOn = true
            }
        } else {
            
            /// set switch ON only if file variant exists in correct size
            largeSwitch.isOn = checkForFileVariant(captionedEntry,"L")
            mediumSwitch.isOn = checkForFileVariant(captionedEntry,"M")
            smallSwitch.isOn = checkForFileVariant(captionedEntry,"S")
            
            /// enable switches only if supplied file is large enough
            if imgsize.width >= kStickerLargeSize {
                largeSwitch.isEnabled = true
            }
            if imgsize.width >= kStickerMediumSize {
                mediumSwitch.isEnabled = true
            }
            if imgsize.width >= kStickerSmallSize {
                smallSwitch.isEnabled = true
            }
        }
        if isAnimated {
            //
            let scale : CGFloat = 1 / 1
            ///  put up animated preview
            self.menuImageView.isHidden = true
            self.animatedLabel.isHidden = false
            webviewOverlay.isHidden  = false
            let w = webviewOverlay.frame.width
            let h = webviewOverlay.frame.height
            let html = "<html5> <meta name='viewport' content='width=device-width, maximum-scale=1.0' /><body  style='padding:0px;margin:0px'><img  style='max-width: 100%; height: auto;' src='\(captionedEntry.localimagepath)' alt='\(captionedEntry.localimagepath) height='\(h * scale)' width='\(w * scale)' ></body></html5>"
            webviewOverlay.scalesPageToFit = true
            webviewOverlay.contentMode = .scaleAspectFit
            webviewOverlay.loadHTMLString(html, baseURL: nil)
            ///  end of animated preview overlay
        }
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
