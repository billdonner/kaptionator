//
//  common.swift
//  Kaptionator
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//

import UIKit


public let versionBig = "0.0.9"

public let kVersion = "version"
public let kAllCaptions = "allcaptions"
public let kOptions = "options"
public let kCaption = "caption"
public let kLocal = "local"
public let kPack = "pack"
public let kStickers = "stickers"
public let kTitle = "title"
public let kID = "id"
public let kRemoteURL = "remoteurl"
public let kThumbNail = "thumburl"

public let kStickerLargeSize = CGFloat(618)
public let kStickerMediumSize = CGFloat(408)
public let kStickerSmallSize = CGFloat(300)

public let kStickerLargeFontSize = CGFloat(40)
public let kStickerMediumFontSize = CGFloat(32)
public let kStickerSmallFontSize = CGFloat(24)

public let kStickerLargeImageRatio  = CGFloat(0.8)
public let kStickerMediumImageRatio = CGFloat(0.8)
public let kStickerSmallImageRatio = CGFloat(0.8)


// captionated entries - are stashed in either of two places - in the app, or in the shared memory with iMessage

public let kStickerAssetsDataSpace = "StickerAssetsDataSpace"
public let kAppPrivateDataSpace = "AppPrivateDataSpace"

public enum KaptionatorErrors : Error  {
    case generalFailure
    case restoreFailure
    case cant
    case assetnotfound
    case colornotfound
    case propertynotfound
    case badasset
}

/// json
public typealias JSONDict  = [String:Any ]
public typealias JSONArray = [JSONDict]
public typealias JSONPayload = [JSONArray]

public class Versions {
    
    public class func make() -> Versions { return Versions() }
    
    public class func versionString () -> String {
        if let iDict = Bundle.main.infoDictionary {
            if let w:AnyObject =  iDict["CFBundleIdentifier"] as AnyObject? {
                if let x:AnyObject =  iDict["CFBundleName"] as AnyObject? {
                    if let y:AnyObject = iDict["CFBundleShortVersionString"] as AnyObject? {
                        if let z:AnyObject = iDict["CFBundleVersion"] as AnyObject? {
                            return "\(w) \(x) \(y) \(z)"
                        }
                    }
                }
            }
        }
        return "**no version info**"
    }
    private func versionSave () {
        let userDefaults = UserDefaults.standard
        userDefaults.set(Versions.versionString(), forKey: "version")
        userDefaults.synchronize()
    }
    
    private func versionFetch() -> String? {
        let userDefaults = UserDefaults.standard
        if let s : AnyObject = userDefaults.object(forKey: "version") as AnyObject? {
            return (s as! String)
        }
        return nil
    }
    
    private func versionCheck() -> Bool {
        let s = Versions.versionString()
        if let v = versionFetch() {
            if s != v {
                versionSave()
                print ("versionCheck changed :::: \(s) - will reset and may be slow to delete existing files")
            } else {
                print ("versionCheck is  stable :::: \(s)")
            }
            return s==v
        }
        // if nothing stored then store something, but we check OK
        versionSave()
        print("versionCheck first time up :::: \(s)")
        return true
    }
}

public func sharedAppContainerDirectory() -> URL {
    let sharedContainerURL = FileManager().containerURL(forSecurityApplicationGroupIdentifier: SharedMemDataSpace )!
    return sharedContainerURL
}

//MARK: - StickerMakingOptions determine what the sticker looks like

public struct StickerMakingOptions: OptionSet {
    public var rawValue: Int
    
    public init(rawValue:Int) {
        self.rawValue = rawValue
    }
    public static let generatesmall    = StickerMakingOptions(rawValue: 1 << 0)
    public static let generatemedium  = StickerMakingOptions(rawValue: 1 << 1)
    public static let generatelarge   = StickerMakingOptions(rawValue: 1 << 2)
    public static let generateasis   = StickerMakingOptions(rawValue: 1 << 3)
    
    public func description()->String {
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


/// "SHARED-INTERAPP-DATA" depending on the actual app instance theres a differen shared data area
//    it looks something like group.xxx.yyy.zzz
public var SharedMemDataSpace: String  { get {
    if let iDict = Bundle.main.infoDictionary,
        let w =  iDict["SHARED-INTERAPP-DATA"] as? String {
        return w
    }
    return ""
}
}
public var extensionScheme: String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["EXTENSION-SCHEME"] as? String { return w
    }
    return "no EXTENSION-SCHEME"
}
}
public var backgroundImagePath : String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["BACKGROUND-IMAGE"] as? String { return w }
    fatalError("remote website url undefined")
    //return nil
}
}

public var appTitle: String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["APP-TITLE"] as? String { return w
    }
    return "no APP-TITLE"
}
}

public var tagLine: String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["TAGLINE"] as? String { return w
    }
    return "no TAGLINE"
}
}
