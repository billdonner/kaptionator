//
//  HelpDropdownViewController.swift
//  kaptionator
//
//  Created by bill donner on 10/15/16.
//  Copyright © 2016 Bill Donner/ midnightrambler. All rights reserved.
//

import UIKit


final class HelpDropdownViewController: UIViewController, AddDismissButton  , UINavigationControllerDelegate  {
    let supportedCloudUTIs =
        ["com.compuserve.gif",
         "public.png",
         "public.jpeg"]
    
    private var imagePicker = UIImagePickerController()
    
   // var pvc: UIViewController! // must be set by caller to masterview
    func dismisstapped(_ s: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func hitITunesAction(_ sender: AnyObject) {
       RemoteAsset.loadFromITunesSharing(){status, title, allofme in
        print("loaded \(allofme.count) files")
            if allofme.count == 0 {
                 IOSSpecialOps.blurt(self ,title:"no files loaded",mess:"go to ITunes > your device > apps")
            } else {
            IOSSpecialOps.blurt(self ,title:"loaded \(allofme.count) files",mess:"available in catalog")
            }
        }
    }
    
    
    @IBAction func hitICloud(_ sender: AnyObject) {
        let importMenu = UIDocumentPickerViewController(documentTypes:  supportedCloudUTIs, in: .import)
        importMenu.delegate = self
        self.present (importMenu, animated: true, completion: nil)
    }
    
    @IBAction func hitPhotoImport(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present (imagePicker, animated: true, completion: nil)
    }
    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var hitITunes: UIButton!
    @IBOutlet weak var hitICloudButton: UIButton!
    @IBOutlet weak var hitWebHelpButton: UIButton!
    @IBOutlet weak var hitArtistsSiteButton: UIButton!
    @IBOutlet weak var hitPhotoImportButton: UIButton!

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    
    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let count = SharedCaptionSpace.itemCount()
        let remcount = RemSpace.itemCount()
        let s = count == 1 ? "" : "s"
        subLabel.text =  "Currently you have \(count) sticker" + s + " in the Messages App"
        bodyLabel.text = remcount != 1 ? "You have \(remcount) catalog entries as sources to make stickers" :"You have one catalog entry as a sticker source"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        // the icloud and itunes options are only present in kaptionator variants
        let showmore =  showCatalogID == "ShowITunesID"
        hitICloudButton.isEnabled = showmore
        hitICloudButton.isHidden =  !showmore
        hitITunes.isEnabled =  showmore
        hitITunes.isHidden =  !showmore
        hitPhotoImportButton.isEnabled = showmore
        hitPhotoImportButton.isHidden = !showmore
        
        hitWebHelpButton.isEnabled = !showmore
        hitWebHelpButton.isHidden = showmore
        hitArtistsSiteButton.isEnabled = !showmore
        hitArtistsSiteButton.isHidden = showmore
        
        
        topLabel.text =  extensionScheme
        imageview.image = UIImage(named:backgroundImagePath)
        
        
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
        
    }
}
//MARK: - UIDocumentPickerDelegate
extension HelpDropdownViewController : UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("cancelled from doc picker")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("picked new document at \(url)")
         RemoteAsset.QuietlyAddNewURL(url,options:StickerMakingOptions.generatemedium)
    }
}

//MARK: - UIImagePickerControllerDelegate
extension HelpDropdownViewController :UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let newimage = StickerFileFactory.resizeImage(image: image,targetSize:(CGSize(width:618.0,height:618.0)))
            
       // turn this into a file wit a url
           let url = RemSpace.writeImageToURL(newimage)
            RemoteAsset.QuietlyAddNewURL(url,options:StickerMakingOptions.generatelarge)
        }
        dismiss (animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }

}
