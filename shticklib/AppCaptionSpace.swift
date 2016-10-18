//
//  Captionated.swift
//  ub ori
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import UIKit


/// AppCaptionSpace is a singleton global struct that is persisted
//  every instance of a user captioning a particular element is here
//   note to self: DO NOT POLLUTE THIS STRUCT with class refs

fileprivate var capSpace  = AppCaptionSpace(AppPrivateDataSpace)
//MARK: - AppCE represents a catalog entry as modified the user

struct AppCE {
    
    let id: String //stringified float millisecs since 1970
    let caption: String
    let stickerOptions: StickerMakingOptions
    let catalogpack:String
    let catalogtitle:String
    let localimagepath:String  // path of local copy of source for 
    
    /// these are the action functions that are called to move things between tabs
  

        fileprivate func serializeToJSONDict() -> JSONDict {
            let x : JSONDict = [
                kID:id as AnyObject,
                kCaption:caption  as AnyObject,
                kLocal:localimagepath as AnyObject,
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
        
        init(pack:String,
             title:String,
             imagepath:String,
             caption:String,
             options:StickerMakingOptions  ) {
            self.catalogpack = pack
            self.catalogtitle = title
            self.localimagepath = imagepath
            self.caption = caption
            self.stickerOptions = options
            self.id =   "\(AppCE.nicetime())" //: id
        }
}
// MARK: Delegates for actions from our associated menu
extension AppCE {
    // not sure we want generate asis so changed back
    
    static func makeNewCaptionAsIs(   from ra:RemoteAsset ) {
        // make captionated entry from remote asset
        do {
            let alreadyIn = SharedCaptionSpace.findMatchingAsset(path: ra.localimagepath, caption: "")
            if !alreadyIn {
                let options = StickerMakingOptions.generateasis
                
                    let _ = AppCaptionSpace.make (pack: ra.pack, title: ra.caption, imagepath: ra.localimagepath,   caption: "",  options: options)
                
                // here make the largest sticker possible and add to shared space
                let _ = try prepareStickers (pack: ra.pack, title: ra.caption, imagepath: ra.localimagepath,   caption: "",  options: options )  // cakks savetodisk N times - ugh
                SharedCaptionSpace.saveData()
            }else {
                // already in, lets just mark new sizrs and caption
            }
        }
        catch {
            print ("cant make sticker in makeNewCaptionAsIs")
        }
    }
 static func makeNewCaptionCat(   from ra:RemoteAsset, caption:String ) {
        // make captionated entry from remote asset
        do {
            let alreadyIn = SharedCaptionSpace.findMatchingAsset(path: ra.localimagepath, caption: caption)
            if !alreadyIn {
                let options = ra.options
                if caption != "" {
                    let _ = AppCaptionSpace.make (pack: ra.pack, title: ra.caption, imagepath: ra.localimagepath,   caption: caption,  options: options)
                }
                // here make the largest sticker possible and add to shared space
                let _ = try prepareStickers (pack: ra.pack, title: ra.caption, imagepath: ra.localimagepath,   caption: caption,  options: options )  // cakks savetodisk N times - ugh
                SharedCaptionSpace.saveData()
            }else {
                // already in, lets just mark new sizrs and caption
            }
        }
        catch {
            print ("cant make sticker in makenewCaptioncat")
        }
    }
}

///
extension AppCE {
      mutating func changeCaption(to caption:String) {
        let alreadyIn = AppCaptionSpace.findMatchingAsset(path: self.localimagepath, caption: caption)
        if !alreadyIn {
            // keep old and
            //AppCaptionSpace.unhinge(id:self.id) //remove old
            // make new with new caption but all else is similar
            let _ = AppCaptionSpace.make( pack: self.catalogpack, title: self.catalogtitle, imagepath: self.localimagepath, caption: caption, options: self.stickerOptions)
        }
        //
    }
     func cloneWithNewCaption(_ caption:String){
        let alreadyIn = AppCaptionSpace.findMatchingAsset(path: self.localimagepath, caption: caption)
        if !alreadyIn {
            // keep old and make another
            let _ = AppCaptionSpace.make( pack: self.catalogpack, title: self.catalogtitle, imagepath: self.localimagepath,  caption: caption,  options: self.stickerOptions )
            let _ = try? prepareStickers( pack: self.catalogpack, title: self.catalogtitle, imagepath: self.localimagepath,  caption: caption,  options: self.stickerOptions)
            SharedCaptionSpace.saveData()
        }
    }
     mutating func moveToIMessage() { // only from capspace
        // duplicate and save to other space under same id, as is
        // if there is something in there with same file and caption then forget it
        let alreadyIn = SharedCaptionSpace.findMatchingAsset(path: self.localimagepath, caption: self.caption)
        if !alreadyIn {
            do {
                //let theData = try Data(contentsOf: URL(string:self.localimagepath)!)
                let options = self.stickerOptions
                // adjust options based on size of image
                // now pass the filenames into the shared space
                // ce.localimagepath = url.absoluteString // dink with this
                let _ = try prepareStickers( pack: self.catalogpack, title: self.catalogtitle, imagepath: self.localimagepath,  caption: self.caption,  options: options)
                SharedCaptionSpace.saveData()
            }
            catch {
                print("could not makemade sticker file urls \(localimagepath)")
            }
        }
    }
}

//MARK: AppCaptionSpace collects and persists AppCEs

struct AppCaptionSpace {
    private var entries : [ AppCE] = []
    private var suite: String // partions nsuserdefaults
 
   fileprivate init(_ suite:String) {
        self.suite = suite
    }
  static  func itemCount () -> Int {
        return capSpace.entries.count
    }
 static    func itemAt(_ index:Int) -> AppCE {
        let t = capSpace.entries
        return t [index] // not horrible
    }
 static    func items () -> [AppCE] {
      return   capSpace.entries
    } 
  static   func dump() {
        print("AppCaptionSpace - \(capSpace.suite) >>>>> \(capSpace.entries.count)")
 
    }
    
    static  func make(pack:String,  title:String,imagepath:String ,caption:String,  options:StickerMakingOptions )->AppCE {
        let newself = AppCE( pack: pack, title: title,
                                      imagepath: imagepath,
                                      caption: caption,
                                      options: options )
        
        // users newce.id to CLONE
        capSpace.entries.append(newself)
        saveToDisk()
        return newself
    }
    

     static func reset() {
        capSpace.entries = []
        saveToDisk()
    }
     static func remove(id:String) -> AppCE? {
        var idx = 0
        for entry in capSpace.entries {
            if entry.id == id {
        let t = capSpace.entries[idx]
        capSpace.entries.remove(at: idx)
        return t
        }
            idx += 1
        }
        return nil
        
    }
 
   static  func findMatchingEntry(ce:AppCE) -> Bool {
        for entry in capSpace.entries {
            if entry.catalogtitle == ce.catalogtitle &&
                entry.caption == ce.caption
            {
                return true
            }
        }
        return false
    }
    
    static func findMatchingAsset(path:String,caption:String) -> Bool {
        for entry in capSpace.entries {
            if entry.localimagepath == path &&
                entry.caption ==  caption
               // entry.localimagepath == ce.localimagepath
            
            {
                return true
            }
        }
        return false
    }
    
    //put in special NSUserDefaults which can be shared
   static  func restoreAppspaceFromDisk () throws  {
        if  let defaults = UserDefaults(suiteName: capSpace.suite),
            let allcaptions = defaults.object(forKey: kAllCaptions) as? JSONArray,
            let version = defaults.object(forKey: "version") {
            print ("**** \(capSpace.suite) restoreFromDisk version \(version) count \(allcaptions.count)")
            
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
                    var options = StickerMakingOptions()
                    options.rawValue = optionsvalue
                    
                    let _ =  make(pack:p,title:ti,imagepath:i ,
                                                      caption:captiontext,
                                                      options:options)
                }
            }
        }
        else {
            print("**** \(capSpace.suite) restoreFromDisk UserDefaults failure")
            throw KaptionatorErrors.restoreFailure}
    }// restore
    
    
  static   func saveToDisk() {
        var flattened:JSONArray = []
        for val in capSpace.entries {
            flattened.append(val.serializeToJSONDict())
        }
        if let defaults  = UserDefaults(suiteName:capSpace.suite) {
            defaults.set( versionBig, forKey: "version")
            defaults.set(   flattened, forKey: "allcaptions")
            print("**** \(capSpace.suite) saveToDisk version \(versionBig) count \(flattened.count)")
        }
    }
}


