//
//  Captionated.swift
//  ub ori
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import UIKit


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

//MARK: AppCaptionSpace collects and persists AppCEs

struct AppCaptionSpace {
    private var entries : [String:AppCE] = [:]
    private var suite: String // partions nsuserdefaults
    static func unhinge(id:String) {
        // unhinge the entry
        let _ =  capSpace.remove(id:id)
        capSpace.entries[id] = nil
    }
    init(_ suite:String) {
        self.suite = suite
    }
    func itemCount () -> Int {
        return entries.count
    }
    func itemAt(_ index:Int) -> AppCE {
        let t = entries.map { key, value in return value }
        return t [index] // horrible 
    }
    func items () -> [AppCE] {
      return   entries.map { key, value in return value }
    } 
    func dump() {
        print("AppCaptionSpace - \(suite) >>>>>")
        for (key,val) in entries {
            print("\(key):\(val),")
        }
    }
    
    static  func make(pack:String,  title:String,imagepath:String ,caption:String,  options:StickerMakingOptions )->AppCE {
        let newself = AppCE( pack: pack, title: title,
                                      imagepath: imagepath,
                                      caption: caption,
                                      options: options )
        
        // users newce.id to CLONE
        capSpace.entries[newself.id] = newself
        capSpace.saveToDisk()
        return newself
    }
    

    mutating func reset() {
        entries = [:]
        saveToDisk()
    }
    mutating func remove(id:String) -> AppCE? {
        let t = entries[id]
        entries[id] = nil
        return t
        
    }
    func  findAppCE(id:String) -> AppCE? {
        return entries[id]
    }
    func findMatchingEntry(ce:AppCE) -> Bool {
        for (_,entry) in entries {
            if entry.catalogtitle == ce.catalogtitle &&
                entry.caption == ce.caption
                // entry.localimagepath == ce.localimagepath
                
            {
                return true
            }
        }
        return false
    }
    
    func findMatchingAsset(path:String,caption:String) -> Bool {
        for (_,entry) in entries {
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
    func restoreAppspaceFromDisk () throws  {
        if  let defaults = UserDefaults(suiteName: suite),
            let allcaptions = defaults.object(forKey: kAllCaptions) as? JSONArray,
            let version = defaults.object(forKey: "version") {
            print ("**** \(suite) restoreFromDisk version \(version) count \(allcaptions.count)")
            
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
                    
                    let _ = AppCaptionSpace.make(pack:p,title:ti,imagepath:i ,
                                                      caption:captiontext,
                                                      options:options)
                }
            }
        }
        else {
            print("**** \(suite) restoreFromDisk UserDefaults failure")
            throw KaptionatorErrors.restoreFailure}
    }// restore
    
    
    func saveToDisk() {
        var flattened:JSONArray = []
        for (_,val) in entries {
            flattened.append(val.serializeToJSONDict())
        }
        if let defaults  = UserDefaults(suiteName:suite) {
            defaults.set( versionBig, forKey: "version")
            defaults.set(   flattened, forKey: "allcaptions")
            print("**** \(suite) saveToDisk version \(versionBig) count \(flattened.count)")
        }
    }
}


