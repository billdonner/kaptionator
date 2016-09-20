//
//  stickerfactory.swift
//  shtickerz
//
//  Created by bill donner on 7/26/16.
//  Copyright © 2016 martoons. All rights reserved.
//

import UIKit


var stickerFileFactory = StickerFileFactory()

struct Snapsupport {
    static let sz = 1200
    static func makewebview(html:String) -> UIView  {
        let wframe = CGRect(x:0,y:0,width:sz/2,height:sz)
        let wv = UIWebView(frame:wframe)
        wv.loadHTMLString(html, baseURL: nil)
        wv.backgroundColor = .red
        return wv
    }
    static func getsnapweb(wv:UIView ) {
        
        
        let asset = "gallery"
        
        let dir = FileManager.default.urls (for: .documentDirectory, in : .userDomainMask)
        let documentsUrl =  dir.first!
        do {
            let thepath = ("\(asset)")
            let urlpath =  documentsUrl.appendingPathComponent(thepath)
            let rul = urlpath
            do {
                let snapshotimage = try   snap(view: wv)
                guard let data = UIImagePNGRepresentation(snapshotimage) else {
                    fatalError ("cant UIImagePNGRepresentation")
                }
                try data.write(to:rul)
            }
            catch  let error as NSError {
                fatalError ("cant snapshot \(error)")
            }
        }
        //return wv
    }// getsnapweb
    
    static func snap(view viewtosnap:UIView) throws -> UIImage {
        let s = CGSize(width:viewtosnap.frame.size.width,height: viewtosnap.frame.size.height)
        UIGraphicsBeginImageContext(s)
        if  let context = UIGraphicsGetCurrentContext() {
            viewtosnap.layer.render(in: context)
            if let image = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return image
            }
        }
        throw KaptionatorErrors.cant
    }
}

/// only for use by extnesion
struct StickerFileFactory {

   mutating func createStickerFileFrom(imageData:Data,captionedEntry:AppCE) -> URL {
        var returls:[URL] = []
        let options = captionedEntry.stickerOptions
        let assep = (captionedEntry.localimagepath as NSString).lastPathComponent
        let type = (assep as NSString).pathExtension
        let label =  captionedEntry.id + "_" + assep
    
    
    
    do {
            if options.contains(.generateasis) {
                // if asis, the size is just for decoration
                let rul = try makeStickerAndURLfromData(imageData:imageData, label:label ,type:type, size:0.0)
                returls.append(rul)
                
            } else
                // only one now
                if options.contains(.generatesmall) {
                    let rul =  try createTextSticker(imageData:imageData,caption:captionedEntry.caption,
                                                     label:label ,type:type,size:CGFloat(300), proportion:0.8, fontSize:CGFloat(24))
                    returls.append(rul)
                } else
                if options.contains(.generatemedium) {
                    let rul =  try createTextSticker(imageData:imageData,caption:captionedEntry.caption,label:label ,type:type,size:CGFloat(408), proportion:0.8, fontSize:CGFloat(32) )
                    returls.append(rul)
                } else
                if options.contains(.generatelarge) {
                    let rul =  try createTextSticker(imageData:imageData,caption:captionedEntry.caption,label:label ,type:type,size:CGFloat(618), proportion:0.8, fontSize:CGFloat(40))
                    returls.append(rul)
                }
            
            //print("processed labelled row from asset \(label)")
        }
        catch {
            print ("cant create labelled text sticker in row for \(label) \(error)")
        }
        //}// remoteasset = remotasset
        return returls[0] // only take one
    }
    
    // generates 0 or more stickers
    
       private mutating func
        makeStickerAndURLfromData(imageData:Data,
                                  label:String,type:String,size:CGFloat) throws -> URL {
        
        /// now write this view to the local file system 
        
        let rul = sharedAppContainerDirectory().appendingPathComponent("\(label)")
        //let rul = URL(fileURLWithPath:newurl)
        do {
            
            try imageData.write(to:rul)
        }
        catch  let error as NSError {
            
            print ("cant snapshot \(error)")
            throw KaptionatorErrors.cant
        }
        
        /// do not make stiker here but rather in init of extension
        
        return rul
        
    }
    
    private  mutating func createTextSticker(imageData:Data,caption:String, label:String,type:String,size:CGFloat, proportion: CGFloat, fontSize:CGFloat ) throws -> URL {
        
        let image = UIImage(data:imageData) // can scale here
        if let image = image {  // make sure not nil
            let ms =  try makeCaptionatedStickerFile(label:label, image: image,type:type,size:size, proportion: proportion, fontSize:fontSize, caption: caption  )
            
            //print ("Making sticker with url  \(ms) = \( caption)")
            return ms
        }
        
        throw KaptionatorErrors.assetnotfound
    }//createTextStickerFromDefaults
    
    private mutating func makeCaptionatedStickerFile(label:String,image:UIImage,type:String,size:CGFloat, proportion: CGFloat, fontSize:CGFloat ,caption: String) throws -> URL {
        let majik = CGFloat(0.7)
        
        let oframe = CGRect(x:0,y:0,width:size,height:size)
        let oview = UIView(frame:oframe)
        oview.backgroundColor = .clear
        let fsize = size *   proportion
        let diff = size - fsize
        let frame = CGRect(x:diff/2,y:diff/2,width:fsize,height:fsize)
        let v = UIImageView(frame:frame)
        oview.addSubview(v)
        v.backgroundColor = .clear
        v.contentMode = .scaleAspectFit
        v.image = image
        v.alpha  = 1.0
        /// if a proportion is specified as nonzero, it is for a the part on top
        if proportion < 1.0 {
            /// add label overlay to v
            let labelheight =  majik * (1.0 - proportion) * size
            let labelypos = size - labelheight
            let lframe = CGRect(x:0,y:labelypos ,width:size,height:labelheight)
            let label = UILabel(frame:lframe)
            oview.addSubview(label)
            label.text = caption
            label.textColor = .black
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: fontSize)
            label.adjustsFontSizeToFitWidth = true
            label.numberOfLines = 0
            label.lineBreakMode = .byTruncatingTail
            label.backgroundColor = .clear
        }
        /// now write this view to the local file system
        //let sz = Int(floor(size)) ?? 0
        let rul = sharedAppContainerDirectory().appendingPathComponent   ("\(label)")/////// + type)
        
        do {
            let snapshotimage = try  Snapsupport.snap(view: oview)
            guard let data = UIImagePNGRepresentation(snapshotimage) else {
                fatalError ("cant UIImagePNGRepresentation")
            }
            try data.write(to:rul)
        }
        catch  let error as NSError {
            fatalError ("cant snapshot \(error)")
        }
        print(">>>>>> created on disk sticker now at \(rul)")
        return rul
    }// end of create stickerX into local file system

}
