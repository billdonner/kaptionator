//
//  mlib.swift
//  shtickerz
//
//  Created by bill donner on 7/20/16.
//  Copyright © 2016 martoons. All rights reserved.
//

import UIKit





//MARK: - Global Data Structs


// this will be seen in both the main program and the extension, but a restorefromdisk needs doing


var memSpace  = SharedCaptionSpace(SharedMemDataSpace)

/// "SHOW-HIDDEN-FUNCTIONS" adds extra admin entries to the urhc menu
//    if not sent then only the website page is shown

//var showHiddenUI: Bool {
//  get {
//    if let iDict = Bundle.main.infoDictionary ,
//        let w =  iDict["SHOW-HIDDEN-FUNCTIONS"] as? Bool { return w }
//    return false
//  }
//}


/// "STICKER-LIST-PATH" adds extra admin entries to the urhc menu
//    if not sent then only the website page is shown



enum KaptionatorErrors : Error  {
    case generalFailure
    case restoreFailure
    case cant
    case assetnotfound
    case colornotfound
    case propertynotfound
    case badasset
}

/// json
typealias JSONDict  = [String:Any ]
typealias JSONArray = [JSONDict]
typealias JSONPayload = [JSONArray]

typealias PGRC = ((_ status:Int,
    _ data:Data?) -> (Swift.Void))

typealias UFRS = ((_ status:Int,
    _ colors:JSONDict,
    _ apptitle:String,
    _ multi:Bool,
    _ packs:[(pack:String,url:URL)]) -> (Swift.Void))

typealias DTSKR = ((_ data:Data?, _ response:URLResponse?, _ nserror:Error?) -> (Swift.Void))


