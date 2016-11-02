//  MessagesAppMenuViewController.swift
//  Kaptionator
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//
import UIKit
import stikz

protocol MessagesAppMenuViewDelegate: class  {
    func removingFromIMessage(on captionedEntry:inout SharedCE )
}

/// All the heavy lifting and file manipulation is done on this side of the fence
/// The Messages Extension code passes the filepaths to msSticker API without ever touching them, for a fast start

final class MessagesAppMenuViewController: UIViewController ,ModalOverCurrentContext {
    
    var captionedEntry:SharedCE! // must be set
    weak var delegate: MessagesAppMenuViewDelegate?  // mig
     
    @IBAction func unwindToMessagesAppMenuViewController(_ segue: UIStoryboardSegue)  {}
    
    private var isAnimated  = false
    fileprivate var setup: Bool = false
    
    @IBOutlet weak var webviewOverlay: UIWebView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var imageCaption: UILabel! 
    @IBOutlet weak var animatedLabel: UILabel!
    @IBOutlet weak var smallSwitch: UISwitch!
    @IBOutlet weak var mediumSwitch: UISwitch!
    @IBOutlet weak var largeSwitch: UISwitch!
    
    /// delete files to correspond to current state of the shared space
    
    private func unprepareStickers(_ ce:SharedCE , _ size:String) {
        let id = ce.id
        if let imgurl =  ce.appimageurl {
            let pe = imgurl.absoluteString
      
        let hashval = "\(ce.caption.hash)"
        let lpc = (pe as NSString).lastPathComponent
        let type = (pe as NSString).pathExtension
        let lsp = (lpc as NSString).deletingPathExtension
        let path = (pe as NSString).deletingLastPathComponent
        let stickerpath = path + "/" + lsp + "-\(size)-\(hashval)." + type
        StickerFileFactory.removeStickerFilesFrom([stickerpath])
        let _ = SharedCaptionSpace.remove(id: id)
        }
    }
    
    /// go back with manual unwind so caller (MessageViewController) can repaint with new data model
    internal func dismisstapped(_ s: AnyObject) {
        //// dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "UnwindToMessagesAppVC", sender: s)
    }

        //MARK:- MENU TAP ACTIONS
    @IBAction func share(_ sender: UIButton) {
        do {
            if let url = captionedEntry.stickerurl {
           // stickerPath[0] doesnt work
        let data = try  Data(contentsOf:url )
        let image = UIImage(data:data)
        let titl = captionedEntry.caption == "" ? "<no caption>" : captionedEntry.caption
            // set up activity view controller
            let imageToShare:[Any]  = [titl , image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
            }
        }
        catch {
        }
    }
    private func  swhel(_ options:StickerMakingOptions){
        do {  // make image of precise size for messages app
             let ce = captionedEntry!
            let _  =  try IO.prepareStickers(pack:ce.catalogpack,
                                             title:ce.catalogtitle,
                                             imageurl: ce.appimageurl!,
                                             caption: ce.caption,
                                             options: options)
        }
        catch {
            print("could not prepareStickers")
        }
    }
    @IBAction func smallSwitchToggled(_ sender: AnyObject) {
        var options: StickerMakingOptions = StickerMakingOptions()
        if smallSwitch.isOn {
            options.insert(.generatesmall)
            swhel(options)
        } else {  // delete the image
            unprepareStickers(captionedEntry,"S")
        }
        SharedCaptionSpace.saveData()
    }
    @IBAction func mediumSwitchToggled(_ sender: AnyObject) {
        var options: StickerMakingOptions = StickerMakingOptions()
        if smallSwitch.isOn {
            options.insert(.generatemedium)
            swhel(options)
        } else {  // delete the image
            unprepareStickers(captionedEntry,"M")
        }
        SharedCaptionSpace.saveData()
    }
    @IBAction func largeSwithToggled(_ sender: AnyObject) {
        var options: StickerMakingOptions = StickerMakingOptions()
        if smallSwitch.isOn {
            options.insert(.generatelarge)
            swhel(options)
        } else {  // delete the image
            unprepareStickers(captionedEntry,"L")
        }
        SharedCaptionSpace.saveData()
    }
    @IBAction func websitetapped(_ sender: AnyObject) {
         openwebsite(self)
    }
    @IBAction func removeimessagetapped(_ sender: AnyObject) {
        delegate?.removingFromIMessage(on: &captionedEntry!)
        dismiss(animated: true,completion:nil)
    }
 
    //MARK:- VC LIFECYLE
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        isAnimated = captionedEntry.stickerOptions.contains(.generateasis)
        
        showImageFromSharedCE(ce:captionedEntry,animate: isAnimated)

        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private extension MessagesAppMenuViewController {
    func showImageFromSharedCE(ce:SharedCE,animate:Bool) {
        let imageurl = ce.appimageurl!
        let isAnimated = animate//remoteAsset.options.contains(.generateasis)
        if !isAnimated {
            menuImageView.isHidden = false
            // only set up once
            webviewOverlay.isHidden  = true
            if !setup {
                do {
                    let data = try  Data(contentsOf:imageurl)
                    menuImageView.image = UIImage(data:data)
                    menuImageView.contentMode = .scaleAspectFit
                }
                catch {
                    menuImageView.image = nil
                }
            }
        } else {
           // self.useasisnocaption.isHidden = false
            let scale : CGFloat = 1 / 1
            ///  put up animated preview
            self.menuImageView.isHidden = true
            self.animatedLabel.isHidden = false
            
            webviewOverlay.isHidden  = false
            if !setup {
                let w = webviewOverlay.frame.width
                let h = webviewOverlay.frame.height
                let html = "<html5> <meta name='viewport' content='width=device-width, maximum-scale=1.0' /><body  style='padding:0px;margin:0px'><img  style='max-width: 100%; height: auto;' src='\(imageurl)' alt='\(imageurl) height='\(h * scale)' width='\(w * scale)' ></body></html5>"
                webviewOverlay.scalesPageToFit = true
                webviewOverlay.contentMode = .scaleAspectFit
                webviewOverlay.loadHTMLString(html, baseURL: nil)
            }
        }
        setup = true
    }
}
