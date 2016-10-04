//
//  common.swift
//  ub ori
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import UIKit


let versionBig = "0.0.8"

let kVersion = "version"
let kAllCaptions = "allcaptions"
let kOptions = "options"
let kCaption = "caption"
let kLocal = "local"
let kPack = "pack"
let kStickers = "stickers"
let kTitle = "title"
let kID = "id"
let kRemoteURL = "remoteurl"
let kThumbNail = "thumb"

let RemoteAssetsDataSpace = "SharedRemspace"

// captionated entries - are stashed in either of two places - in the app, or in the shared memory with iMessage

let AppPrivateDataSpace = "AppPrivateDataSpace"

/// "SHARED-INTERAPP-DATA" depending on the actual app instance theres a differen shared data area
//    it looks something like group.xxx.yyy.zzz
var SharedMemDataSpace: String  { get {
    if let iDict = Bundle.main.infoDictionary,
        let w =  iDict["SHARED-INTERAPP-DATA"] as? String {
        return w
    }
    return ""
}
}

func sharedAppContainerDirectory() -> URL {
    //let t = NSTemporaryDirectory()
    
    let sharedContainerURL = FileManager().containerURL(forSecurityApplicationGroupIdentifier: SharedMemDataSpace )!
    return sharedContainerURL
}



//MARK: - StickerMakingOptions determine what the sticker looks like

struct StickerMakingOptions: OptionSet {
    var rawValue: Int
    static let generatesmall    = StickerMakingOptions(rawValue: 1 << 0)
    static let generatemedium  = StickerMakingOptions(rawValue: 1 << 1)
    static let generatelarge   = StickerMakingOptions(rawValue: 1 << 2)
    static let generateasis   = StickerMakingOptions(rawValue: 1 << 3) 
    
    func description()->String {
        var buf = ""
        if self.contains(.generatesmall) {
            buf += "Small"
        }
        if self.contains(.generatemedium) {
            buf += "Med"
        }
        if self.contains(.generatelarge) {
            buf += "Large"
        }
        if self.contains(.generateasis) {
            buf += " AsIs"
        }
     
        return buf
    }
    
}



var appTitle: String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["APP-TITLE"] as? String { return w
    }
    return "no APP-TITLE"
}
}
var extensionScheme: String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["EXTENSION-SCHEME"] as? String { return w
    }
    return "no EXTENSION-SCHEME"
}
}
var nameForLeftBBI: String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["LEFT-BBI-NAME"] as? String { return w
    }
    return "no LEFT-BBI-NAME"
}
}

func restoreSharespaceFromDisk () throws  {
    let suite = SharedMemDataSpace
    SharedCaptionSpace.reset()
    if  let defaults = UserDefaults(suiteName: suite),
        let allcaptions = defaults.object(forKey: kAllCaptions) as? JSONArray,
        let version = defaults.object(forKey: kVersion) {
        print ("**** \(suite) restoreFromDisk version \(version) count \(allcaptions.count)")
        
        for acaption in allcaptions {
            if let  optionsvalue = acaption [kOptions] as? Int,
                let captiontext = acaption [kCaption] as? String,
                let i = acaption[kLocal] as? String,
                let s = acaption[kStickers] as? [String],
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
                /// figure the shared paths
            
                    
                    let t = SharedCE( pack: p, title: ti,
                                            imagepath: i,
                                            stickerpaths:s,
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

