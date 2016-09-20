//
//  common.swift
//  ub ori
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import UIKit


let versionBig = "0.0.8"

let RemoteAssetsDataSpace = "sharedRemspace"

// captionated entries - are stashed in either of two places - in the app, or in the shared memory with iMessage

let AppPrivateDataSpace = "AppPrivateDataSpace"

/// "SHARED-INTERAPP-DATA" depending on the actual app instance theres a differen shared data area
//    it looks something like group.xxx.yyy.zzz
var SharedMemDataSpace: String  { get {
    if let iDict = Bundle.main.infoDictionary,
        let w =  iDict["SHARED-INTERAPP-DATA"] as? String { return w }
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
    static let basic: StickerMakingOptions = [.generatesmall]
}


/// AppCaptionSpace is a singleton global struct that is persisted
//  every instance of a user captioning a particular element is here
//   note to self: DO NOT POLLUTE THIS STRUCT with class refs

var capSpace  = AppCaptionSpace(AppPrivateDataSpace)


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
