//
//  Captionated.swift
//  Kaptionator
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//

import UIKit
//import stikz

/// AppCaptionSpace is a singleton global struct that is persisted
//  every instance of a user captioning a particular element is here
//   note to self: DO NOT POLLUTE THIS STRUCT with class refs

fileprivate var appCaptionSpace  = AppCaptionSpace(kAppPrivateDataSpace)


/// non-mutating public funcs


//MARK: - AppCE represents a catalog entry as modified the user

public struct AppCE {
    
    public let id: String //stringified float millisecs since 1970
    public let caption: String
    public let stickerOptions: StickerOptions
    public let catalogpack:String
    public let catalogtitle:String
    public let imageurl:URL  // path of local copy of source for
    
    /// these are the action functions that are called to move things between tabs
    
    fileprivate func serializeToJSONDict() -> JSONDict {
        
        let imurl =  (imageurl.absoluteString)  as String
        
        let x : JSONDict = [
            kID:id as AnyObject,
            kCaption:caption  as AnyObject,
            kLocal:imurl as AnyObject,
            kPack:catalogpack as AnyObject,
            kTitle:catalogtitle as AnyObject,
            kOptions:stickerOptions.rawValue as AnyObject ]
        return x
    }
    //// core
    static private  func intWithLeadingZeros (_ thing:Int64,digits:Int) -> String  {
        return String(format:"%0\(digits)lu", (thing) )
    }
    
    static private  func nicetime () -> String  {
        let now = CFAbsoluteTimeGetCurrent()*100000000.0
        let intnow = Int64(now)
        return intWithLeadingZeros( intnow, digits: 20)
    }
    
    public init(pack:String,
                 title:String,
                 imageurl:URL,
                 caption:String,
                 options:StickerOptions  ) {
        self.catalogpack = pack
        self.catalogtitle = title
        self.imageurl = imageurl
        self.caption = caption
        self.stickerOptions = options
        self.id =   "\(AppCE.nicetime())" //: id
    }
    
    // MARK: Delegates for actions from our associated menu
    
    // not sure we want generate asis so changed back
    
    public  static func makeNewCaptionAsIs(   from ra:StickerAsset ) {
        // make captionated entry from remote asset
        do {
            let alreadyIn = SharedCaptionSpace.findMatchingAssetInSharedSpace(url: ra.localurl!, caption: "")
            if !alreadyIn {
                let options = ra.options
                
                //StickerOptions.generateasis
                
                let _ = AppCaptionSpace.make (pack: ra.packID, title: ra.assetName, imageurl: ra.localurl!,   caption: "",  options: options)
                
                // here make the largest sticker possible and add to shared space
                let _ = try IO.prepareStickers (pack: ra.packID, title: ra.assetName, imageurl: ra.localurl!,   caption: "",  options: options )  // cakks savetodisk N times - ugh
                SharedCaptionSpace.saveData()
            }else {
                // already in, lets just mark new sizrs and caption
            }
        }
        catch {
            print ("cant make sticker in makeNewCaptionAsIs")
        }
    }
    public  static func makeNewCaptionCat(   from ra:StickerAsset, caption:String ) {
        // make captionated entry from remote asset
        do {
            let alreadyIn = SharedCaptionSpace.findMatchingAssetInSharedSpace(url: ra.localurl!, caption: caption)
            if !alreadyIn {
                let options = ra.options
                if caption != "" && !options.contains(.generateasis) { // dont include animateds
                    let _ = AppCaptionSpace.make (pack: ra.packID, title: ra.assetName, imageurl: ra.localurl!,   caption: caption,  options: options)
                }
                // here make the largest sticker possible and add to shared space
                let _ = try IO.prepareStickers (pack: ra.packID, title: ra.assetName, imageurl: ra.localurl!,   caption: caption,  options: options )  // cakks savetodisk N times - ugh
                SharedCaptionSpace.saveData()
            }else {
                // already in, lets just mark new sizrs and caption
            }
        }
        catch {
            print ("cant make sticker in makenewCaptioncat")
        }
    }

    public func changeCaptionForAppCE(to caption:String) {
        let alreadyIn = AppCaptionSpace.findMatchingAsset(url: imageurl, caption: caption)
        if !alreadyIn {
            // keep old and
            //AppCaptionSpace.unhinge(id:self.id) //remove old
            // make new with new caption but all else is similar
            let _ = AppCaptionSpace.make( pack: self.catalogpack, title: self.catalogtitle, imageurl: self.imageurl, caption: caption, options: self.stickerOptions)
        }
        //
    }
    public func cloneWithNewCaption(_ caption:String){
        let alreadyIn = AppCaptionSpace.findMatchingAsset(url:  imageurl, caption: caption)
        if !alreadyIn {
            // keep old and make another
            let _ = AppCaptionSpace.make( pack: self.catalogpack, title: self.catalogtitle, imageurl: self.imageurl,  caption: caption,  options: self.stickerOptions )
            let _ = try? IO.prepareStickers( pack: self.catalogpack, title: self.catalogtitle, imageurl: self.imageurl,  caption: caption,  options: self.stickerOptions)
            SharedCaptionSpace.saveData()
        }
    }
    public  func cemoveToIMessage() { // only from appCaptionSpace
        // duplicate and save to other space under same id, as is
        // if there is something in there with same file and caption then forget it
        let alreadyIn = SharedCaptionSpace.findMatchingAssetInSharedSpace(url: self.imageurl, caption: self.caption)
        if !alreadyIn {
            do {
                //let theData = try Data(contentsOf: URL(string:self.imageurl)!)
                let options = self.stickerOptions
                // adjust options based on size of image
                // now pass the filenames into the shared space
                // ce.imageurl = url.absoluteString // dink with this
                let _ = try IO.prepareStickers( pack: self.catalogpack, title: self.catalogtitle, imageurl: self.imageurl,  caption: self.caption,  options: options)
                SharedCaptionSpace.saveData()
            }
            catch {
                print("could not makemade sticker file urls \(imageurl)")
            }
        }
    }
}

/// non-mutating public funcs

//MARK: AppCaptionSpace collects and persists AppCEs

public struct AppCaptionSpace {
    private var entries : [ AppCE] = []
    private let suite: String // partions nsuserdefaults
    
    fileprivate init(_ suite:String) {
        self.suite = suite
    }
    public static  func itemCount () -> Int {
        return appCaptionSpace.entries.count
    }
    public static    func itemAt(_ index:Int) -> AppCE {
        let t = appCaptionSpace.entries
        return t [index] // not horrible
    }
    public static    func items () -> [AppCE] {
        return   appCaptionSpace.entries
    }
    public static   func dump() {
        print("AppCaptionSpace - \(appCaptionSpace.suite) >>>>> \(appCaptionSpace.entries.count)")
        
    }
    
    public static  func make(pack:String,  title:String,imageurl:URL ,caption:String,  options:StickerOptions )->AppCE {
        let newself = AppCE( pack: pack, title: title,
                             imageurl: imageurl,
                             caption: caption,
                             options: options )
        
        // users newce.id to CLONE
        appCaptionSpace.entries.append(newself)
        saveToDisk()
        return newself
    }
    
    public static func reset() {
        appCaptionSpace.entries = []
        saveToDisk()
    }
    public static func remove(id:String) -> AppCE? {
        var idx = 0
        for entry in appCaptionSpace.entries {
            if entry.id == id {
                let t = appCaptionSpace.entries[idx]
                appCaptionSpace.entries.remove(at: idx)
                return t
            }
            idx += 1
        }
        return nil
    }
    
    public static   func findMatchingEntry(ce:AppCE) -> Bool {
        for entry in appCaptionSpace.entries {
            if entry.catalogtitle == ce.catalogtitle &&
                entry.caption == ce.caption
            {
                return true
            }
        }
        return false
    }
    
    fileprivate static  func findMatchingAsset(url:URL,caption:String) -> Bool {
        for entry in appCaptionSpace.entries {
            if entry.imageurl == url &&
                entry.caption ==  caption
            {
                return true
            }
        }
        return false
    }
    
    //put in special NSUserDefaults which can be shared
    public static  func restoreAppspaceFromDisk () throws  {
        if  let defaults = UserDefaults(suiteName: appCaptionSpace.suite),
            let allcaptions = defaults.object(forKey: kAllCaptions) as? JSONArray,
            let version = defaults.object(forKey: "version") {
            print ("**** \(appCaptionSpace.suite) restoreFromDisk version \(version) count \(allcaptions.count)")
            
            for acaption in allcaptions {
                if let  optionsvalue = acaption [kOptions] as? Int,
                    let captiontext = acaption [kCaption] as? String,
                    let i = acaption[kLocal] as? String,
                    let p = acaption[kPack] as? String,
                    let _ = acaption[kID] as? String
                {
                    var ti = ""
                    if
                        let capt  = acaption[kTitle] as? String {
                        ti = capt
                    }
                    var options = StickerOptions()
                    options.rawValue = optionsvalue
                    
                    let iurl = URL(string:i)!
                    let _ =  make(pack:p,title:ti,imageurl:iurl ,
                                  caption:captiontext,
                                  options:options)
                }
            }
        }
        else {
            print("**** \(appCaptionSpace.suite) restoreFromDisk UserDefaults failure")
            throw KaptionatorErrors.restoreFailure}
    }// restore
    
    public static   func saveToDisk() {
        var flattened:JSONArray = []
        for val in appCaptionSpace.entries {
            flattened.append(val.serializeToJSONDict())
        }
        if let defaults  = UserDefaults(suiteName:appCaptionSpace.suite) {
            defaults.set( versionBig, forKey: "version")
            defaults.set(   flattened, forKey: "allcaptions")
            print("**** \(appCaptionSpace.suite) saveToDisk version \(versionBig) count \(flattened.count)")
        }
    }
}


