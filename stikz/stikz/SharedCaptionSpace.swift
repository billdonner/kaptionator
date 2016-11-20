//
//  SharedCE.swift
//  Kaptionator
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//

import Foundation

// this will be seen in both the main program and the extension, but a restorefromdisk needs doing

fileprivate var sharedCaptionSpace  = SharedCaptionSpace(sharedMedDataSpace)

//MARK: - SharedCE represents a sticker with caption ready for the Messages Extension to use directly

public struct SharedCE {
    
    // write once
    public let id: String //stringified float millisecs since 1970
    public let caption: String
    public let stickerOptions: StickerOptions
    public let stickerurl:URL?
    public let catalogpack:String
    public let catalogtitle:String
    public let appimageurl:URL?
    
    /// these are the action functions that are called to move things between tabs
    
    fileprivate func serializeToJSONDict() -> JSONDict {
        let appurl = (appimageurl != nil) ?(appimageurl?.absoluteString)! : "" as String
        let stkurl = (stickerurl != nil) ?(stickerurl?.absoluteString)! : "" as String
        let x : JSONDict = [//"params":params.query,
            kCaption:caption as String,
            kID:id as String,
            kLocal:appurl as String,
            kStickers:stkurl as String,
            kPack:catalogpack as String,
            kTitle:catalogtitle as String,
            kOptions:stickerOptions.rawValue as Int ]
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
    public init(pack:String,title:String,
                imageurl:URL,
                stickerurl:URL,
                caption:String,
                options:StickerOptions ) {
        
        self.catalogpack = pack
        self.catalogtitle = title
        self.appimageurl = imageurl
        self.stickerurl = stickerurl
        self.caption = caption
        self.stickerOptions = options
        self.id =  "\(SharedCE.nicetime())"
    }
}

//MARK: SharedCaptionSpace collects and persists SharedCEs
/// nothing mutable but the entries themselves
public struct SharedCaptionSpace {
    fileprivate var entries : [SharedCE] = []
    fileprivate let  suite: String // partions nsuserdefaults
    fileprivate init(_ suite:String) {
        self.suite = suite
        
        print("SharedCaptionSpace - \(suite) >>>>> \(tagLine)")
    }
    
    public static func itemCount () -> Int {
        return sharedCaptionSpace.entries.count
    }
    public static func items () -> [SharedCE] {
        return   sharedCaptionSpace.entries //.map { key, value in return value }
    }
    public static func itemAt (_ x:Int) -> SharedCE {
        return   sharedCaptionSpace.entries[x] //.map { key, value in return value }
    }
    public func dump() {
        print("SharedCaptionSpace - \(suite) >>>>> \(entries)")
        
    }
    public static func reset() {
        sharedCaptionSpace.entries = []
        //saveToDisk()
    }
    public static func add(ce:SharedCE) {
        sharedCaptionSpace.entries.append(ce)
        // saveToDisk()
    }
    // reorder these entries - normally caller will save afterwards
    public static func swap(_ a: Int,_ b:Int) {
        let t = sharedCaptionSpace.entries[a]
        sharedCaptionSpace.entries[a] = sharedCaptionSpace.entries[b]
        sharedCaptionSpace.entries[b] = t
    }
    private static func findIdx(id:String) -> Int {
        var idx = 0
        var found :SharedCE?
        for ent in sharedCaptionSpace.entries {
            if ent.id == id { found = ent; break }
            else { idx += 1 }
        }
        if found == nil {return -1}
        return idx
    }
    public static func remove(id:String) -> SharedCE? {
        let idx = findIdx(id:id)
        if idx == -1 {
            return nil
        }
        let found = sharedCaptionSpace.entries[idx]
        sharedCaptionSpace.entries.remove(at:idx)
        return found
    }
    public static  func findMatchingEntry(atPath:String) -> SharedCE? {
        let lpc = (atPath as NSString).lastPathComponent
        for entry in sharedCaptionSpace.entries {
            if let surl =  entry.stickerurl {
                if (surl.absoluteString as NSString).lastPathComponent == lpc            {
                    return entry
                }
            }
        }
        return nil
    }
    public static func findMatchingEntry(ce:SharedCE) -> Bool {
        for entry in sharedCaptionSpace.entries {
            if entry.catalogtitle == ce.catalogtitle &&
                entry.caption == ce.caption {
                return true
            }
        }
        return false
    }
    public static func findMatchingAssetInSharedSpace(url:URL,caption:String) -> Bool {
        for entry in sharedCaptionSpace.entries {
            if let surl =  entry.appimageurl {
                if surl == url &&
                    entry.caption ==  caption 
                {
                    return true
                }
            }
        }
        return false
    }
    
    //// core
    //put in special NSUserDefaults which can be shared
    
    public static func saveData() {
        var flattened:JSONArray = []
        for val in sharedCaptionSpace.entries {
            flattened.append(val.serializeToJSONDict())
        }
        if let defaults  = UserDefaults(suiteName:sharedCaptionSpace.suite) {
            defaults.set( versionBig, forKey: kVersion)
            defaults.set(   flattened, forKey: kAllCaptions)
            print("**** \(sharedCaptionSpace.suite) saveToDisk version \(versionBig) count \(flattened.count)")
        }
    }
    
    public static func restoreSharespaceFromDisk () throws  {
        let suite = sharedMedDataSpace
        SharedCaptionSpace.reset()
        if  let defaults = UserDefaults(suiteName: suite),
            let allcaptions = defaults.object(forKey: kAllCaptions) as? JSONArray,
            let version = defaults.object(forKey: kVersion) {
            print ("**** \(suite) restoreFromDisk version \(version) count \(allcaptions.count)")
            
            for acaption in allcaptions {
                if let  optionsvalue = acaption [kOptions] as? Int,
                    let captiontext = acaption [kCaption] as? String,
                    let i = acaption[kLocal] as? String,
                    let s = acaption[kStickers] as? String,
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
                    /// figure the shared paths
                    let iurl = URL(string:i)!
                    let surl = URL(string:s)!
                    let t = SharedCE( pack: p, title: ti,
                                      imageurl: iurl,
                                      stickerurl:surl,
                                      caption:  captiontext,
                                      options: options )
                    let _ = SharedCaptionSpace.add(ce: t)
                }
            }
            SharedCaptionSpace.saveData()  //add calls it over and; over
        }
        else {
            print("**** \(suite) restoreFromDisk UserDefaults failure")
            throw KaptionatorErrors.restoreFailure}
    }// restore
}
