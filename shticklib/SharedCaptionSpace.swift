//
//  SharedCE.swift
//  ub ori
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import UIKit


//MARK: - AppCE represents a catalog entry modified the user

struct SharedCE {
    
    // write once
    let id: String //stringified float millisecs since 1970
    let caption: String
    let stickerOptions: StickerMakingOptions
    let catalogpack:String
    let catalogtitle:String
    let localimagepath:String
 //   let stickerimagepath:String // this is what the extension uses to make stickers
    
    /// these are the action functions that are called to move things between tabs
    
    fileprivate func serializeToJSONDict() -> JSONDict {
        let x : JSONDict = [//"params":params.query,
            "caption":caption as AnyObject,
            "id":id as AnyObject,
            "local":localimagepath as AnyObject,
            //"sticker":stickerimagepath as AnyObject,
            "pack":catalogpack as AnyObject,
            "title":catalogtitle as AnyObject,
            "options":  stickerOptions.rawValue as AnyObject ]
        return x
    }
    
    
    static private  func intWithLeadingZeros (_ thing:Int64,digits:Int) -> String  {
        return String(format:"%0\(digits)lu", (thing) )
    }
    
    static private  func nicetime () -> String  {
        let now = CFAbsoluteTimeGetCurrent()*100000000.0
        let intnow = Int64(now)
        return intWithLeadingZeros( intnow, digits: 20)
    }
    
    init(pack:String,title:String,imagepath:String,
         //stickerpath:String,
         caption:String,
         options:StickerMakingOptions,
         id:String = ""  ) {
        self.catalogpack = pack
        self.catalogtitle = title
        self.localimagepath = imagepath
       // self.stickerimagepath = stickerpath
        self.caption = caption // == "" ? title : caption
        self.stickerOptions = options
        self.id =  id == "" ? "\(SharedCE.nicetime())" : id
    }
}

//MARK: AppCaptionSpace collects and persists AppCEs

struct SharedCaptionSpace {
    private var entries : [String:SharedCE] = [:]
    private  var suite: String // partions nsuserdefaults
 
    init(_ suite:String) {
        self.suite = suite
    }
    static func unhinge(id:String) {
        // unhinge the entry
        let _ =  memSpace.remove(id:id)
        memSpace.entries[id] = nil
    }
    func itemCount () -> Int {
        return entries.count
    }
    func itemAt(_ index:Int) -> SharedCE {
        let t = entries.map { key, value in return value }
        return t [index] // horrible
    }
    func items () -> [SharedCE] {
        return   entries.map { key, value in return value }
    }
    func dump() {
        print("AppCaptionSpace - \(suite) >>>>>")
        for (key,val) in entries {
            print("\(key):\(val),")
        }
    }
    //    mutating func addSharedCE(_ ce :SharedCE) {
    //        self.entries[ce.id] = ce
    //    }
    mutating func reset() {
        entries = [:]
        saveToDisk()
    }
    mutating func remove(id:String) -> SharedCE? {
        let t = entries[id]
        entries[id] = nil
        return t
    }
    func  findAppCE(id:String) -> SharedCE? {
        return entries[id]
    }
    func findMatchingEntry(ce:SharedCE) -> Bool {
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
    //// core
    
    static  func make( pack:String,title:String,imagepath:String,//stickerpath:String,
                       caption:String,
                       options:StickerMakingOptions,
                       id:String  )->SharedCE {
        let newself = SharedCE( pack: pack, title: title,
                                            imagepath: imagepath,
                                            //stickerpath:stickerpath,
                                        
                                            caption: caption,
                                            options: options,id:id)
        
        // users newce.id to CLONE)
        memSpace.entries[newself.id] = newself
        memSpace.saveToDisk()
        return newself
    }
    
    //put in special NSUserDefaults which can be shared
    func restoreFromDisk () throws  {
        if  let defaults = UserDefaults(suiteName: suite),
            let allcaptions = defaults.object(forKey: "allcaptions") as? JSONArray,
            let version = defaults.object(forKey: "version") {
            print ("**** \(suite) restoreFromDisk version \(version) count \(allcaptions.count)")
            
            for acaption in allcaptions {
                if let  optionsvalue = acaption ["options"] as? Int,
                    let captiontext = acaption ["caption"] as? String,
                    let i = acaption["local"] as? String,
                    //let s = acaption["sticker"] as? String,
                    let p = acaption["pack"] as? String,
                    let d = acaption["id"] as? String
                {
                    var ti = ""
                    if
                        let capt  = acaption["title"] as? String {
                        ti = capt
                    }
                    var options = StickerMakingOptions()
                    options.rawValue = optionsvalue
                    
                    let _ =      SharedCaptionSpace.make(pack:p,
                                                           title:ti,
                                                           imagepath:i ,
                                                           //stickerpath: s, 
                        caption:captiontext,
                                                           options:options,id:d)
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


