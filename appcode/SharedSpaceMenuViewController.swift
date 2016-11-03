//  SharedSpaceMenuViewController.swift
//  Kaptionator
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//
import UIKit
import stikz

protocol SharedSpaceMenuDelegate: class  {
    func removingFromIMessage(on captionedEntry:inout SharedCE )
    func refreshLayout() 
}

/// All the heavy lifting and file manipulation is done on this side of the fence
/// The Messages Extension code passes the filepaths to msSticker API without ever touching them, for a fast start

final class SharedSpaceMenuViewController: UIViewController ,ModalOverCurrentContext {
    
    var captionedEntry:SharedCE! // must be set
    weak var delegate: SharedSpaceMenuDelegate?  // mig
     
    @IBAction func unwindToSharedSpaceMenuViewController(_ segue: UIStoryboardSegue)  {}
    
    private var isAnimated  = false
    fileprivate var setup: Bool = false
    
    @IBOutlet weak var isAnimatedSignifier: UIImageView!
    @IBOutlet weak var webviewOverlay: UIWebView!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var imageCaption: UILabel! 
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
        
        delegate?.refreshLayout() //make this better
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
    private func  swhel(_ options:StickerOptions){
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
        var options: StickerOptions = StickerOptions()
        if smallSwitch.isOn {
            options.insert(.generatesmall)
            swhel(options)
        } else {  // delete the image
            unprepareStickers(captionedEntry,"S")
        }
        SharedCaptionSpace.saveData()
    }
    @IBAction func mediumSwitchToggled(_ sender: AnyObject) {
        var options: StickerOptions = StickerOptions()
        if smallSwitch.isOn {
            options.insert(.generatemedium)
            swhel(options)
        } else {  // delete the image
            unprepareStickers(captionedEntry,"M")
        }
        SharedCaptionSpace.saveData()
    }
    @IBAction func largeSwithToggled(_ sender: AnyObject) {
        var options: StickerOptions = StickerOptions()
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

        imageCaption.text = captionedEntry.caption
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

private extension SharedSpaceMenuViewController {
    func showImageFromSharedCE(ce:SharedCE,animate isAnimated:Bool) {
        let imgurl = ce.appimageurl!
     //   self.isAnimatedSignifier.isHidden = isAnimated
        if !isAnimated {
            menuImageView.isHidden = false
            // only set up once
            webviewOverlay.isHidden  = true
            if !setup {
                do {
                    let data = try  Data(contentsOf:imgurl)
                    menuImageView.image = UIImage(data:data)
                    menuImageView.contentMode = .scaleAspectFit
                }
                catch {
                    menuImageView.image = nil
                }
            }
        } else {
            ///  put up animated preview
            self.menuImageView.isHidden = true
            if !setup {
                IO.setupAnimationPreview(wv:webviewOverlay,imgurl:imgurl)
            }
            
            webviewOverlay.isHidden  = false

        }
        setup = true
    }
}
