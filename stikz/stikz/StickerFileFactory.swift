//
//  stickerfactory.swift
//  shtickerz
//
//  Created by bill donner on 7/26/16.
//  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
//

import UIKit

fileprivate struct Snapsupport {
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
             
            do {
                let snapshotimage = try   snap(view: wv)
                guard let data = UIImagePNGRepresentation(snapshotimage) else {
                    fatalError ("cant UIImagePNGRepresentation")
                }
                try data.write(to:urlpath)
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

public struct StickerFileFactory {
 
    public static  func removeStickerFilesFrom(_ urls:[String]) -> Swift.Void {
        for url in urls {
            do {
                try FileManager.default.removeItem(at: URL(string:url)!)
            }
            catch  {
                print("Could not delete \(url)")
            }
        }
    }
    public static func createStickerFileFrom(imageData:Data,imageurl:URL, caption:String,options:StickerOptions) -> URL? {
        var returls:[String] = []
        let assep = (imageurl.absoluteString as NSString).lastPathComponent
        let type = (assep as NSString).pathExtension
        let label = // captionedEntry.id + "_" +
            ( assep as NSString).deletingPathExtension
        do {
            if options.contains(.generateasis)
                //|| caption == ""
            {
                // if asis, the size is just for decoration
                let rul = try makeStickerAndURLfromAsIsData(   label:label  ,type:type ).absoluteString
                returls.append(rul)
                // only one now
                
            } else {
                // can return more than one
                if options.contains(.generatesmall) {
                    let rul =  try createTextSticker(imageData:imageData,caption:caption,  label:label + "-S" ,type:type,size:kStickerSmallSize, proportion:kStickerSmallImageRatio, fontSize:kStickerSmallFontSize)
                    returls.append(rul.absoluteString)
                }
                if options.contains(.generatemedium) {
                    let rul =  try createTextSticker(imageData:imageData,caption:caption,
                        label:label + "-M" ,type:type,size:kStickerMediumSize, proportion:kStickerMediumImageRatio, fontSize:kStickerMediumFontSize )
                    returls.append(rul.absoluteString)
                }
                if options.contains(.generatelarge) {
                    let rul =  try createTextSticker(imageData:imageData,caption:caption,label:label + "-L" ,type:type,size:kStickerLargeSize, proportion:kStickerLargeImageRatio, fontSize:kStickerLargeFontSize)
                    returls.append(rul.absoluteString)
                }
            }
        }
        catch {
            print ("cant create labelled text sticker in row for \(label) \(error)")
            return nil
        }
        return URL(string:returls[0])!
    }
    // generates 0 or more stickers
    private static func
        makeStickerAndURLfromAsIsData( label:String,type:String ) throws -> URL {
        
        /// do not make stiker here but rather in init of extension 
        let hashval = ""//"-AnImAtEd"
        return sharedAppContainerDirectory().appendingPathComponent("\(label)\(hashval).\(type)")
    }
    private  static func createTextSticker(imageData:Data,caption:String, label:String,type:String,size:CGFloat, proportion: CGFloat, fontSize:CGFloat ) throws -> URL {
        let hashval = "-\(caption.hash)"
        let image = UIImage(data:imageData) // can scale here
        if let image = image {  // make sure not nil
            let ms =  try makeCaptionatedStickerFile(label:label + hashval, image: image,type:type,size:size, proportion: proportion, fontSize:fontSize, caption: caption  )
            
            return ms
        }
        
        throw KaptionatorErrors.assetnotfound
    }//createTextStickerFromDefaults
    
    private static func makeCaptionatedStickerFile(label:String,image:UIImage,type:String,size:CGFloat, proportion: CGFloat, fontSize:CGFloat ,caption: String) throws -> URL {
        
        // if caption is blank then just return the incoming
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
        let rul = sharedAppContainerDirectory().appendingPathComponent   ("\(label).\(type)")
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
