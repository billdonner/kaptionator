//
//  HelpDropdownViewController.swift
//  kaptionator
//
//  Created by bill donner on 10/15/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

import UIKit


final class HelpDropdownViewController: ReverseModalBlurViewController , UINavigationControllerDelegate  {
    let supportedCloudUTIs =
        ["com.compuserve.gif",
         "public.png",
         "public.jpeg"]
    
    
    
    @IBOutlet var imageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    var pvc: UIViewController! // must be set by caller to masterview
    
    @IBAction func hitITunesAction(_ sender: AnyObject) {
        loadFromITunesSharing(){status, title, allofme in
        print("loaded \(allofme.count) files")
        }
    }
    
    
    @IBOutlet weak var hitITunes: UIButton!
    @IBAction func hitICloud(_ sender: AnyObject) {
        didHitICloud ()
    }
    
    @IBOutlet weak var hitICloudButton: UIButton!
    @IBAction func hitPhotoImport(_ sender: AnyObject) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present (imagePicker, animated: true, completion: nil)
    }

    func didHitICloud () {
        let importMenu = UIDocumentPickerViewController(documentTypes:  supportedCloudUTIs, in: .import)
        importMenu.delegate = self
        self.present (importMenu, animated: true, completion: nil)
    }
    
    @IBOutlet weak var hitWebHelpButton: UIButton!
    @IBOutlet weak var hitArtistsSiteButton: UIButton!
    @IBOutlet weak var hitPhotoImportButton: UIButton!

    @IBOutlet weak var imageview: UIImageView!
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var subLabel: UILabel!
  
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        let count = SharedCaptionSpace.itemCount()
        let remcount = RemSpace.itemCount()
        
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
        let s = count == 1 ? "" : "s"
        subLabel.text =  "Currently you have \(count) sticker" + s + " in the Messages App"
        bodyLabel.text = remcount != 1 ? "You have \(remcount) catalog entries as sources to make stickers" :"You have one catalog entry as a sticker source"
            imageview.image = UIImage(named:backgroundImagePath)
    }
}
extension HelpDropdownViewController :UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("cancelled from doc picker")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print("picked new document at \(url)")
         QuietlyAddNewURL(url,options:StickerMakingOptions.generatemedium)
    }
}
//http://stackoverflow.com/questions/31314412/how-to-resize-image-in-swiftfunc 

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / image.size.width
    let heightRatio = targetSize.height / image.size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

extension HelpDropdownViewController :   UIImagePickerControllerDelegate {
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let newimage = resizeImage(image: image,targetSize:(CGSize(width:618.0,height:618.0)))
            
       // turn this into a file wit a url
           let t = RemSpace.loadFromImage(newimage)
            let url = URL(string:t)
            if let url = url {
                QuietlyAddNewURL(url,options:StickerMakingOptions.generatelarge)
            }
        }
        
        dismiss (animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }

}
