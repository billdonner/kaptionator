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
    var stickerPaths:[String]
    let catalogpack:String
    let catalogtitle:String
    let localimagepath:String
    //   let stickerimagepath:String // this is what the extension uses to make stickers
    
    /// these are the action functions that are called to move things between tabs
    
    fileprivate func serializeToJSONDict() -> JSONDict {
        let x : JSONDict = [//"params":params.query,
            kCaption:caption as AnyObject,
            kID:id as AnyObject,
            kLocal:localimagepath as AnyObject,
            kStickers:stickerPaths as AnyObject,
            kPack:catalogpack as AnyObject,
            kTitle:catalogtitle as AnyObject,
            kOptions:stickerOptions.rawValue as AnyObject ]
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
         stickerpaths:[String],
         caption:String,
         options:StickerMakingOptions ) {
        
        self.catalogpack = pack
        self.catalogtitle = title
        self.localimagepath = imagepath
        self.stickerPaths = stickerpaths
        self.caption = caption
        self.stickerOptions = options
        self.id =  "\(SharedCE.nicetime())"
        
        
        
    }
}

//MARK: AppCaptionSpace collects and persists AppCEs

struct SharedCaptionSpace {
    fileprivate var entries : [SharedCE] = []
    private  var suite: String // partions nsuserdefaults
    
    init(_ suite:String) {
        self.suite = suite
    }
    static func unhinge(id:String) {
        // unhinge the entry
        //        let match = memSpace.findAppCE(id: id)
        //
        //
        //        let _ =  memSpace.remove(id:id)
        //        memSpace.entries[id] = nil
    }
    func itemCount () -> Int {
        return entries.count
    }
    func itemAt(_ index:Int) -> SharedCE {
        let t = entries //.map { key, value in return value }
        return t [index] // horrible
    }
    func items () -> [SharedCE] {
        return   entries //.map { key, value in return value }
    }
    func dump() {
        print("SharedCaptionSpace - \(suite) >>>>> \(entries)")
        
    }
    //    mutating func addSharedCE(_ ce :SharedCE) {
    //        self.entries[ce.id] = ce
    //    }
    mutating func reset() {
        entries = []
        saveToDisk()
    }
    
    mutating func add(ce:SharedCE) {
        
        entries.append(ce)
        saveToDisk()
    }
    func findIdx(id:String) -> Int {
        var idx = 0
        var found :SharedCE?
        for ent in entries {
            if ent.id == id { found = ent; break }
            else { idx += 1 }
        }
        if found == nil {return -1}
        return idx
    }
    mutating func remove(id:String) -> SharedCE? {
        
        let idx = findIdx(id:id)
        if idx == -1 {
            return nil
        }
        let found = entries[idx]
        entries.remove(at:idx)
        return found
    }
    func  findAppCE(id:String) -> SharedCE? {
        
        let idx = findIdx(id:id)
        if idx == -1 {
            return nil
        }
        let found = entries[idx]
        return found
    }
    func findMatchingEntry(atPath:String) -> SharedCE? {
        let lpc = (atPath as NSString).lastPathComponent
        for entry in entries {
            for path in entry.stickerPaths {
            if (path as NSString).lastPathComponent == lpc            {
                return entry
            }
        }
        }
        return nil
    }
    func findMatchingEntry(ce:SharedCE) -> Bool {
        for entry in entries {
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
        for entry in entries {
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
    //put in special NSUserDefaults which can be shared
    
    
    func saveToDisk() {
        var flattened:JSONArray = []
        for val in entries {
            flattened.append(val.serializeToJSONDict())
        }
        if let defaults  = UserDefaults(suiteName:suite) {
            defaults.set( versionBig, forKey: kVersion)
            defaults.set(   flattened, forKey: kAllCaptions)
            print("**** \(suite) saveToDisk version \(versionBig) count \(flattened.count)")
        }
    }
}
