//
//  RemoteAsset.swift
//  ub ori
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import UIKit

// MARK: abstract structs and types

typealias ERAC = ((RemoteAsset)->(Swift.Void))

/// RemSpace is a singleton global struct that is currently persisted in NSUserDefaults
//  each separate catalog entry across all manifests is represented here
//  it is always refreshed on a software updated, however the images are reloaded fresh on each startup

var remSpace = RemSpace()
//MARK: - RemSpace collects all RemoteAssets
class RemSpace {
    var catalogTitle:String = "replace"
    private var raz:[ RemoteAsset ]
    
    //  private var allImageData : [String:String] = [:]    // remote url of source image : local filepath url
    
    
    init() {
        raz = []
    }
    
    var  filenum : Int  { return raz.count + 1001 }

    fileprivate func loadFile(from remotepath:String) -> String {
        
        do {
            let ext = (remotepath as NSString).pathExtension
            let name = "\(filenum).\(ext)"
            
            let newfilename = sharedAppContainerDirectory().appendingPathComponent(name, isDirectory: false)
            
            if FileManager.default.fileExists(atPath: newfilename.absoluteString)
            {
                return newfilename.absoluteString
            }
            
            // now copy, could be in done in back but why?
            
            let data = try Data(contentsOf: URL(string:remotepath)!)
            try data.write(to: newfilename, options: .atomicWrite)
            
            return newfilename.absoluteString
        }
        catch {
            print("Could not load \(remotepath)")
            // might as well die at this point
            fatalError("could not load \(error)")
        }
    }
    
    func reset () {
        raz = []
    }
    func itemAt(_ idx:Int) -> RemoteAsset {
        return raz [idx]
    }
    func itemCount() -> Int { return raz.count }
    
    func addasset(ra:RemoteAsset){
        raz.append(ra)
    }
    func saveToDisk() {
        var flattened:JSONArray = []
        for val in raz {
            flattened.append(val.serializeToJSONDict())
        }
        
        if let defaults  = UserDefaults(suiteName:nil) {
            defaults.set( versionBig, forKey: "version")
            defaults.set( catalogTitle, forKey: "catalogTitle")
            //  defaults.set(hdrz,forKey:"headerz")
            defaults.set(   flattened, forKey: "remspace")
            print("**** \(RemoteAssetsDataSpace) saveToDisk version \(versionBig) count \(flattened.count)=\(raz.count)")
        }
    }
    
    func restoreFromDisk () throws  {
        if  let defaults = UserDefaults(suiteName: nil),
            let flattened = defaults.object(forKey: "remspace") as? JSONArray,
            let version = defaults.object(forKey: "version") as? String,
            let catTitle = defaults.object(forKey: "catalogTitle") as? String {
            remSpace.raz = []
            for ra in flattened {
                if let  optionsvalue = ra ["options"] as? Int,
                    let captiontext = ra ["caption"] as? String,
                    let pack = ra["pack"] as? String,
                    let remoteurl = ra["remoteurl"] as? String,
                    let localpath = ra["localpath"] as? String {
                    var options = StickerMakingOptions()
                    options.rawValue = optionsvalue
                    //calling with an explicit local path will use existing file and wont re-read from remote site
                    let ra = RemoteAsset(pack:  pack , title: captiontext, remoteurl:remoteurl, localpath:localpath , options: options)
                    remSpace.raz.append(ra)
                }
            } // for loop
            remSpace.catalogTitle = catTitle
            print ("**** \(RemoteAssetsDataSpace) restoreFromDisk version \(version) count \(flattened.count) = \(remSpace.raz.count)")
        }
            
        else {
            print("**** \(RemoteAssetsDataSpace) restoreFromDisk UserDefaults failure")
            throw KaptionatorErrors.restoreFailure}
    }
}

//MARK: - RemoteAsset is readonly once loaded from manifest

// RemoteAsset represents one image on a remote server in a "pack"
/// NO LONGER TRUE:It is always reloaded from the net on a restart, or a pull to refresh
struct RemoteAsset {
    let pack:String
    var caption:String
    let remoteurl :String
    let localimagepath:String
    let options:StickerMakingOptions
    
    init(pack:String,title:String,remoteurl:String,localpath:String?,
         options:StickerMakingOptions) {
        self.pack = pack
        let none = title == ""
        self.caption = none ? "<no title>" : title
        self.options = options
        self.remoteurl = remoteurl
        if let lp = localpath { // if localpath supplied use that else
            self.localimagepath = lp
        }
        else {
            // load file from remote location
            let local  = remSpace.loadFile(from:remoteurl)
            self.localimagepath = local
            print("**** RA.INIT(..IMAGEPATH) \(self.localimagepath)")
        }
    }// init
     
    func serializeToJSONDict() -> JSONDict {
        let x : JSONDict = [
            "caption":caption as String,
            "remoteurl":remoteurl as String  ,
            "localpath":localimagepath as String  ,
            "pack": pack as String,
            "options":  options.rawValue as Int ]
        return x
    }
    func  convertToCaptionedEntry( )  -> CaptionedEntry {
        let ce = CaptionedEntry(space:capSpace, pack:  pack, title:  caption, imagepath:  localimagepath,   caption: "",  options: options)
        return ce
    }
}
