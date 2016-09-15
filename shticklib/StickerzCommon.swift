//
//  StickerzCommon.swift
//  shtickerz
//
//  Created by bill donner on 6/29/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

import UIKit
let versionBig = "0.0.4"
let DefaultsSuiteForData = "group.com.midnightrambler.shtickerzdata"
let DefaultsSuiteForIPC = "group.com.midnightrambler.shtickerzipc"
//
//typealias PGRC = ((Int,Data?)->())
//typealias UFRS = ((String,[URL])->())
//typealias GFRM = (([ManifestEntry])->())

typealias JSONDict  = [String:AnyObject]
typealias JSONArray = [JSONDict]
typealias JSONPayload = [JSONArray]

 

enum IACommunications:ErrorProtocol {
    case generalFailure
    case restoreFailure
}

enum SnapErrors : ErrorProtocol {
    case cant
    case assetnotfound
    case badasset
}


struct AStickerz {
    var asset:String // gets dinked
    let type:String
    var imagePath:String
    
    var thumbPath:String = ""
    let title: String
    let pack: String
    var userCaption: String = ""
    var generateSmallSticker: Bool
    var generateMediumSticker: Bool
    var generateLargeSticker: Bool
    var generateAsIs: Bool
    var animated: Bool
    
    init(pack:String, asset:String,type:String,description:String,remoteImage:String,animated:Bool ) {
        self.pack = pack
        self.asset = asset
        self.type = type
        self.title = description
        self.generateSmallSticker = false
        self.generateMediumSticker = false
        self.generateLargeSticker = false
        self.generateAsIs = animated
        self.animated = animated
        self.imagePath = remoteImage // start with this
    }
    
    func serializeForDisk()->JSONDict {
        return ["asset" :self.asset,
                "type" : self.type ,
                "pack" : self.pack,
                "title" : self.title ,
                "userCaption" : self.userCaption ,
                "S" : self.generateSmallSticker ,
                "M" : self.generateMediumSticker ,
                "L" : self.generateLargeSticker ,
                "asis" : self.generateAsIs ,
                "thumbPath" : self.thumbPath,
                "imagePath" : self.imagePath
            // "imageData" : UIImagePNGRepresentation(self.image!)!
        ]
    }
    func serializeForExtension()->JSONDict {
        // the extension gets actual image data pre-loaded and never sees the path
        var xportdata : Data
        if let url = URL(string: imagePath) {
            
            do {  xportdata = try Data(contentsOf:url)
            }
            catch {
                print("did not get data for writing \(imagePath)")
                xportdata =  Data()
            }
        } else {
            print("could not convert to URL for writing \(imagePath)")
            xportdata =  Data()
        }
        
        return ["asset" :self.asset,
                "type" : self.type ,
                "pack" : self.pack,
                "title" : self.title ,
                "userCaption" : self.userCaption ,
                "S" : self.generateSmallSticker ,
                "M" : self.generateMediumSticker ,
                "L" : self.generateLargeSticker ,
                "asis" : self.generateAsIs,
                "imageData" : xportdata
        ]
    }
}
 
struct DiskSafeStore {
    
    //put in special NSUserDefaults which can be shared
    static func restoreFromDisk () throws -> (String,[String],JSONPayload) {
        if  let defaults = UserDefaults(suiteName: DefaultsSuiteForData),
            let items = defaults.object(forKey: "items") as? JSONPayload,
            let name = defaults.object(forKey: "name") as? String,
            
            let headers = defaults.object(forKey: "headers") as? [String],
            let version = defaults.object(forKey: "version") {
            print ("**** restoreFromDisk version \(version) name \(name) count \(items.count)")
            return (name,headers,items)
        }
        else {
            print("**** restoreFromDisk UserDefaults failure")
            throw IACommunications.restoreFailure}
    }
    
    
    static func saveToDisk(_ name:String,headers:[String], items:JSONPayload) {
        if let defaults  = UserDefaults(suiteName:DefaultsSuiteForData) {
            defaults.set( versionBig, forKey: "version")
            defaults.set(   name, forKey: "name")
            
            defaults.set(   headers, forKey: "headers")
            defaults.set(   items, forKey: "items")
            print("**** saveToDisk name \(name) items count\(items.count)")
        }
    }
}

struct  MessagesExtensionCommunications {
    
    //put in special NSUserDefaults which can be shared
    static func restoreFromMessagesExtensionDataSpace () throws -> (String,[JSONDict]) {
        //  print("**** restoreFromMessagesExtensionDataSpace from UserDefaults")
        if  let defaults = UserDefaults(suiteName: DefaultsSuiteForIPC),
            let items = defaults.object(forKey: "items"),
            let name = defaults.object(forKey: "name"),
            let version = defaults.object(forKey: "version") {
            print ("***** restoreFromMessagesExtensionDataSpace \(version)  \(name)  count \(items.count)")
            
            return (name as! String,items as! [JSONDict])
        }
        else {
            print("**** restoreFromMessagesExtensionDataSpace UserDefaults failure")
            throw IACommunications.restoreFailure}
    }
}
