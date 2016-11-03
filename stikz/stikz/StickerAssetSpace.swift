//
//  StickerAssetSpace.swift
//  kaptionator
//
//  Created by bill donner on 10/31/16.
//  Copyright © 2016 Bill Donner/ midnightrambler. All rights reserved.
//

/// StickerAssetSpace is a singleton global struct that is currently persisted in NSUserDefaults
//  each separate catalog entry across all manifests is represented here
//  it is always refreshed on a software updated, however the images are reloaded fresh on each startup
import UIKit
import stikz

//fileprivate var remSpace = StickerAssetSpace()

// StickerAsset represents one image in a "pack" in either the local or remote filesystem

public struct StickerAsset {
    public let packID:String    // arbitrary string
    public let assetName:String  // used as a default caption, but often blank
    public let remoteurl:URL?    
    public let thumburl:URL?
    public let localurl:URL?
    public let options:StickerMakingOptions
    
    // clone this while changing the stickermaking options
    //
    //
    public func copyWithNewOptions(stickerOptions: StickerMakingOptions) -> StickerAsset {
        let appce = StickerAsset(pack: packID, title: assetName, thumburl: thumburl, remoteurl: remoteurl , localpath: localurl, options: stickerOptions)
        return appce
        
    }
    
    public init(localurl:URL,options:StickerMakingOptions,title:String="",thumb:URL? = nil) {
        self.init(pack:"",title:title,thumburl:thumb, remoteurl:nil,
                  localpath:localurl ,options:options)
    }
    public init(remoteurl:URL,options:StickerMakingOptions, title:String="") {
        self.init(pack:"",title:title,thumburl:nil, remoteurl:remoteurl ,localpath:nil,options:options)
    }
    public init(byreference:URL,options:StickerMakingOptions, title:String="") {
        self.packID = ""
        self.thumburl = nil
        let none = title == ""
        self.assetName = none ? "<no title>" : title
        self.options = options
        self.remoteurl = nil
        self.localurl = byreference
    }
    // this main init only for use during recovery
    //
    // if localpath is non nil then set localurl
    public init(pack:String,title:String,thumburl:URL?, remoteurl:URL?,localpath:URL?, options:StickerMakingOptions) {
        self.packID = pack
        self.thumburl = thumburl
        let none = title == ""
        self.assetName = none ? "<no title>" : title
        self.options = options
        self.remoteurl = remoteurl
        do {
        // make a copy in shared filesystem
        if let lp = localpath { // if localpath supplied use that else
            let local  = try StickerAssetSpace.copyURLtoURL(lp)
            self.localurl  = local
            print("**** RA.INIT(..LOCALPATH) \(local )")
        }
        else {
            // load file from remote location
            let local  = try StickerAssetSpace.copyURLtoURL(  self.remoteurl!)
            self.localurl  = local
            print("**** RA.INIT(..IMAGEPATH) \(local )")
        }
        }
        catch {
           self.localurl = nil
        }
    }// init
    
    func serializeToJSONDict() -> JSONDict {
        let rurl = (remoteurl != nil) ?(remoteurl?.absoluteString)! : "" as String
        let lurl = (localurl != nil) ?(localurl?.absoluteString)! : "" as String
        let thurl = (thumburl != nil) ?(thumburl?.absoluteString)! : "" as String
        let x : JSONDict = [
            kCaption:assetName as String,
            kRemoteURL: rurl,
            kThumbNail: thurl,
            kLocal:lurl ,
            kPack: packID as String,
            kOptions:  options.rawValue as Int ]
        
        return x
    }
    
    /// loads from documents without presenting a UI
    public static func quietlyAddNewURL(_ url:URL,options:StickerMakingOptions)  {
        let ra = StickerAsset(localurl:url,
                              options: options,
                              title:url.lastPathComponent)
        StickerAssetSpace.addasset(ra: ra)
        StickerAssetSpace.saveToDisk()
    }
 
}
//MARK: - StickerAssetSpace collects all StickerAssets
public struct  StickerAssetSpace {
    static private var catalogTitle:String = "replace"
    static private var raz:[ StickerAsset ] = []
    static fileprivate var  filenum : Int  { return raz.count + 1001 }
    
    fileprivate init() {
        print("****sharedAppContainerDir init in ",sharedAppContainerDirectory())
    }
public static func  writeImageToURL(_ image:UIImage) -> URL {
      do {
            let ext = "png"
            let name = "\(filenum).\(ext)"
            let newfileurl = sharedAppContainerDirectory().appendingPathComponent(name, isDirectory: false)
            
            if FileManager.default.fileExists(atPath: newfileurl.absoluteString)
            {
                return newfileurl
            }
            
            // now copy, could be in done in back but why?
            
            let data = UIImagePNGRepresentation(image)
            if let data = data {
                try data.write(to: newfileurl, options: .atomicWrite)
            }
            
            return newfileurl
        }
        catch {
            print("Could not load image \(image) \(error)")
            // might as well die at this point
            fatalError("could not load \(error)")
        }
    }

public static func reset (title:String) {
        raz = []
        catalogTitle = title
    }
public static func itemAt(_ idx:Int) -> StickerAsset {
        return raz [idx]
    }
 public static func itemCount() -> Int { return raz.count }
    
 public static func addasset(ra:StickerAsset){
        raz.append(ra)
    }
    // scan till ltight match and remove
 public static func remove(ra:StickerAsset){
        var idx = 0
        for val in raz {
            if ra.remoteurl == val.remoteurl {
                if ra.localurl == val.localurl {
                    raz.remove(at:idx)
                    return
                }
            }
            idx += 1
        }
        fatalError("Did not find ra in raz")
    }
public static func saveToDisk() {
        var flattened:JSONArray = []
        for val in raz {
            flattened.append(val.serializeToJSONDict())
        }
        
        if let defaults  = UserDefaults(suiteName:nil) {
            defaults.set( versionBig, forKey: "version")
            defaults.set( catalogTitle, forKey: "catalogTitle")
            //  defaults.set(hdrz,forKey:"headerz")
            defaults.set(   flattened, forKey: "remspace")
            print("**** \(kStickerAssetsDataSpace) saveToDisk version \(versionBig) count \(flattened.count)=\(raz.count)")
        }
    }
    
 public static  func restoreRemspaceFromDisk () throws  {
        if  let defaults = UserDefaults(suiteName: nil),
            let flattened = defaults.object(forKey: "remspace") as? JSONArray,
            let version = defaults.object(forKey: "version") as? String,
            let catTitle = defaults.object(forKey: "catalogTitle") as? String {
            raz = []
            for ra in flattened {
                if let  optionsvalue = ra [kOptions] as? Int,
                    let captiontext = ra [kCaption] as? String,
                    let pack = ra[kPack] as? String,
                    let remoteurl = ra[kRemoteURL] as? String,
                    let thumburl = ra[kThumbNail] as? String,
                    let localpath = ra[kLocal] as? String {
                    var options = StickerMakingOptions()
                    options.rawValue = optionsvalue
                    //calling with an explicit local path will use existing file and wont re-read from remote site
                    let lurl = URL(string:localpath)
                    let rurl = URL(string:remoteurl)
                    let thurl = URL(string:thumburl)
                    
                    let ra = StickerAsset(pack:  pack , title: captiontext, thumburl:thurl, remoteurl:rurl, localpath:lurl , options: options)
                    raz.append(ra)
                }
            } // for loop
            
            catalogTitle = catTitle
            
            print ("**** \(kStickerAssetsDataSpace) restoreFromDisk version \(version) count \(flattened.count) = \(raz.count)")
        }  else {
            print("**** \(kStickerAssetsDataSpace) restoreFromDisk UserDefaults failure")
            throw KaptionatorErrors.restoreFailure}
    } 
 public static func  copyURLtoURL(_ url:URL) throws -> URL {
        
        do {
            let ext = (url.absoluteString as NSString).pathExtension
            let name = "\(filenum).\(ext)"
            
            let newfileurl = sharedAppContainerDirectory().appendingPathComponent(name, isDirectory: false)
            
            if FileManager.default.fileExists(atPath: newfileurl.absoluteString)
            {
                return newfileurl
            }
            
            // now copy, could be in done in back but why?
            
            let data = try Data(contentsOf: url)
            try data.write(to: newfileurl, options: .atomicWrite)
            
            return newfileurl
        }
        catch {
            print("Could not load file url \(url)")
            // might as well die at this point
           // fatalError("could not load \(error)")
        }
   
    throw KaptionatorErrors.cant
     }
}
