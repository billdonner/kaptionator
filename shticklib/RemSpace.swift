//
//  RemSpace.swift
//  kaptionator
//
//  Created by bill donner on 10/31/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

/// RemSpace is a singleton global struct that is currently persisted in NSUserDefaults
//  each separate catalog entry across all manifests is represented here
//  it is always refreshed on a software updated, however the images are reloaded fresh on each startup
import UIKit

fileprivate var remSpace = RemSpace()
//MARK: - RemSpace collects all RemoteAssets
public struct  RemSpace {
    static private var catalogTitle:String = "replace"
    static private var raz:[ RemoteAsset ] = []
    static fileprivate var  filenum : Int  { return raz.count + 1001 }
    
    fileprivate init() {
        print("****sharedAppContainerDir init in ",sharedAppContainerDirectory())
    }
    static func  writeImageToURL(_ image:UIImage) -> URL {
        
        do {
            let ext = "png"
            let name = "\(filenum).\(ext)"
            
            let newfilename = sharedAppContainerDirectory().appendingPathComponent(name, isDirectory: false)
            
            if FileManager.default.fileExists(atPath: newfilename.absoluteString)
            {
                return newfilename
            }
            
            // now copy, could be in done in back but why?
            
            let data = UIImagePNGRepresentation(image)
            if let data = data {
                try data.write(to: newfilename, options: .atomicWrite)
            }
            
            return newfilename
        }
        catch {
            print("Could not load image \(image) \(error)")
            // might as well die at this point
            fatalError("could not load \(error)")
        }
    }
    
    
    
    static func reset (title:String) {
        raz = []
        catalogTitle = title
    }
    static func itemAt(_ idx:Int) -> RemoteAsset {
        return raz [idx]
    }
    static func itemCount() -> Int { return raz.count }
    
    static func addasset(ra:RemoteAsset){
        raz.append(ra)
    }
    // scan till ltight match and remove
    static func remove(ra:RemoteAsset){
        var idx = 0
        for val in raz {
            if ra.remoteurl == val.remoteurl {
                if ra.localimagepath == val.localimagepath {
                    raz.remove(at:idx)
                    return
                }
            }
            idx += 1
        }
        fatalError("Did not find ra in raz")
    }
    static func saveToDisk() {
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
    
    static  func restoreRemspaceFromDisk () throws  {
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
                    let ra = RemoteAsset(pack:  pack , title: captiontext, thumb:thumburl, remoteurl:remoteurl, localpath:localpath , options: options)
                    raz.append(ra)
                }
            } // for loop
            
            catalogTitle = catTitle
            
            print ("**** \(RemoteAssetsDataSpace) restoreFromDisk version \(version) count \(flattened.count) = \(raz.count)")
        }  else {
            print("**** \(RemoteAssetsDataSpace) restoreFromDisk UserDefaults failure")
            throw KaptionatorErrors.restoreFailure}
    } 
    static func  copyURLtoURL(_ url:URL) -> URL {
        
        do {
            let ext = (url.absoluteString as NSString).pathExtension
            let name = "\(filenum).\(ext)"
            
            let newfilename = sharedAppContainerDirectory().appendingPathComponent(name, isDirectory: false)
            
            if FileManager.default.fileExists(atPath: newfilename.absoluteString)
            {
                return newfilename
            }
            
            // now copy, could be in done in back but why?
            
            let data = try Data(contentsOf: url)
            try data.write(to: newfilename, options: .atomicWrite)
            
            return newfilename
        }
        catch {
            print("Could not load file url \(url)")
            // might as well die at this point
            fatalError("could not load \(error)")
        }
    }
}

//MARK: - RemoteAsset is readonly once loaded from manifest
