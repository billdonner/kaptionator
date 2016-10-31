//
//  SharedCE.swift
//  Kaptionator
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//

import UIKit

// this will be seen in both the main program and the extension, but a restorefromdisk needs doing


fileprivate var memSpace  = SharedCaptionSpace(SharedMemDataSpace)

//MARK: - AppCE represents a catalog entry modified the user

public struct SharedCE {
    
    // write once
    let id: String //stringified float millisecs since 1970
    let caption: String
    let stickerOptions: StickerMakingOptions
    let stickerPath:String
    let catalogpack:String
    let catalogtitle:String
    let localimagepath:String
    
    /// these are the action functions that are called to move things between tabs
    
    fileprivate func serializeToJSONDict() -> JSONDict {
        let x : JSONDict = [//"params":params.query,
            kCaption:caption as AnyObject,
            kID:id as AnyObject,
            kLocal:localimagepath as AnyObject,
            kStickers:stickerPath as AnyObject,
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
         stickerPath:String,
         caption:String,
         options:StickerMakingOptions ) {
        
        self.catalogpack = pack
        self.catalogtitle = title
        self.localimagepath = imagepath
        self.stickerPath = stickerPath
        self.caption = caption
        self.stickerOptions = options
        self.id =  "\(SharedCE.nicetime())"
    }
}

//MARK: SharedCaptionSpace collects and persists SharedCEs

struct SharedCaptionSpace {
    fileprivate var entries : [SharedCE] = []
    private  var suite: String // partions nsuserdefaults
    
   fileprivate init(_ suite:String) {
        self.suite = suite
    }
  
    static func itemCount () -> Int {
        return memSpace.entries.count
    }
 
    static func items () -> [SharedCE] {
        return   memSpace.entries //.map { key, value in return value }
    }
    static func itemAt (_ x:Int) -> SharedCE {
        return   memSpace.entries[x] //.map { key, value in return value }
    }
    func dump() {
        print("SharedCaptionSpace - \(suite) >>>>> \(entries)")
        
    }
    
    static func reset() {
        memSpace.entries = []
        //saveToDisk()
    }
    
    static func add(ce:SharedCE) {
        
        memSpace.entries.append(ce)
       // saveToDisk()
    }
    // reorder these entries - normally caller will save afterwards
    static func swap(_ a: Int,_ b:Int) {
        let t = memSpace.entries[a]
        memSpace.entries[a] = memSpace.entries[b]
        memSpace.entries[b] = t
    }
    private static func findIdx(id:String) -> Int {
        var idx = 0
        var found :SharedCE?
        for ent in memSpace.entries {
            if ent.id == id { found = ent; break }
            else { idx += 1 }
        }
        if found == nil {return -1}
        return idx
    }
    static func remove(id:String) -> SharedCE? {
        
        let idx = findIdx(id:id)
        if idx == -1 {
            return nil
        }
        let found = memSpace.entries[idx]
        memSpace.entries.remove(at:idx)
        return found
    }

   static  func findMatchingEntry(atPath:String) -> SharedCE? {
        let lpc = (atPath as NSString).lastPathComponent
        for entry in memSpace.entries {
            let path =  entry.stickerPath
            if (path as NSString).lastPathComponent == lpc            {
                return entry
            }
        }
        return nil
    }
    static func findMatchingEntry(ce:SharedCE) -> Bool {
        for entry in memSpace.entries {
            if entry.catalogtitle == ce.catalogtitle &&
                entry.caption == ce.caption
                // entry.localimagepath == ce.localimagepath
                
            {
                return true
            }
        }
        return false
    }
    
   static func findMatchingAsset(path:String,caption:String) -> Bool {
        for entry in memSpace.entries {
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
    
    
    static func saveData() {
        var flattened:JSONArray = []
        for val in memSpace.entries {
            flattened.append(val.serializeToJSONDict())
        }
        if let defaults  = UserDefaults(suiteName:memSpace.suite) {
            defaults.set( versionBig, forKey: kVersion)
            defaults.set(   flattened, forKey: kAllCaptions)
            print("**** \(memSpace.suite) saveToDisk version \(versionBig) count \(flattened.count)")
        }
    }
}
