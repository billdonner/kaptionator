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

fileprivate var remSpace = RemSpace()
//MARK: - RemSpace collects all RemoteAssets
struct  RemSpace {
    static private var catalogTitle:String = "replace"
    static private var raz:[ RemoteAsset ] = []
    static private var  filenum : Int  { return raz.count + 1001 }
    
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
    fileprivate static func  copyURLtoURL(_ url:URL) -> URL {
        
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
}

//MARK: - RemoteAsset is readonly once loaded from manifest

// RemoteAsset represents one image on a remote server in a "pack"
struct RemoteAsset {
    let pack:String
    let caption:String
    let remoteurl :String
    let thumbnail:String
    let localimagepath:String
    let options:StickerMakingOptions
    
    init(localurl:URL,options:StickerMakingOptions,title:String="",thumb:String="") {
        self.init(pack:"",title:title,thumb:thumb, remoteurl:nil,
                  localpath:localurl.absoluteString,options:options)
    }
    init(remoteurl:URL,options:StickerMakingOptions, title:String="") {
        self.init(pack:"",title:title,thumb:"", remoteurl:remoteurl.absoluteString,localpath:nil,options:options)
    }
    init(byreference:URL,options:StickerMakingOptions, title:String="") {
        self.pack = ""
        self.thumbnail = ""
        let none = title == ""
        self.caption = none ? "<no title>" : title
        self.options = options
        self.remoteurl = ""
        self.localimagepath = byreference.absoluteString
    }
    // this main init only for use during recovery
    //
    // if localpath is non nil then set localimagepath
    fileprivate init(pack:String,title:String,thumb:String, remoteurl:String?,localpath:String?, options:StickerMakingOptions) {
        self.pack = pack
        self.thumbnail = thumb
        let none = title == ""
        self.caption = none ? "<no title>" : title
        self.options = options
        self.remoteurl = remoteurl ?? ""
        
        // make a copy in shared filesystem
        if let lp = localpath { // if localpath supplied use that else
            let local  = RemSpace.copyURLtoURL(URL(string:lp)!)
            self.localimagepath  = local.absoluteString
            print("**** RA.INIT(..LOCALPATH) \(local )")
        }
        else {
            // load file from remote location
            let local  = RemSpace.copyURLtoURL(URL(string:self.remoteurl)!)
                self.localimagepath  = local.absoluteString
                print("**** RA.INIT(..IMAGEPATH) \(local )")
        }
    }// init
    
    func serializeToJSONDict() -> JSONDict {
        let x : JSONDict = [
            kCaption:caption as String,
            kRemoteURL:remoteurl as String  ,
            kThumbNail: thumbnail as String,
            kLocal:localimagepath as String  ,
            kPack: pack as String,
            kOptions:  options.rawValue as Int ]
        return x
    }
}
func QuietlyAddNewURL(_ url:URL,options:StickerMakingOptions)  {
    let ra = RemoteAsset(localurl:url,
                         options: options,
                         title:url.lastPathComponent)
    RemSpace.addasset(ra: ra)
    RemSpace.saveToDisk()
}

/// loads from documents without presenting a UI

func loadFromITunesSharing(   completion:GFRM?) {
    //let iTunesBase = manifestFromDocumentsDirector
    // store file locally into catalog
    // var first = true
    let apptitle = "-local-"
    var allofme:ManifestItems = []
    do {
        let dir = FileManager.default.urls (for:  .documentDirectory, in: .userDomainMask)
        let documentsUrl =  dir.first!
        
        // Get the directory contents urls (including subfolders urls)
        let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
        let _ =  try directoryContents.map {
            let lastpatch = $0.lastPathComponent
            if !lastpatch.hasPrefix(".") { // exclude wierd files
                let imagename = lastpatch
                
                if (lastpatch as NSString).pathExtension.lowercased() == "json" {
                    let data = try Data(contentsOf: $0) // read
                    Manifest.parseData(data, baseURL: documentsUrl.absoluteString, completion: completion!)
                } else {
                    // copy from documents area into a regular local file
                    
                    //                        let me = RemoteAsset(pack: "apptitle", title: imagename, thumb:"", remoteurl: localpath.absoluteString,  localpath:nil, options:
                    //                            .generatemedium)
                    
                    let me = RemoteAsset(remoteurl: $0,options: .generatemedium,title: imagename)
                    RemSpace.addasset(ra: me) // be sure to coun
                    allofme.append(me)                     }
                
                // finally, delete the file
                try FileManager.default.removeItem(at: $0)
            }
        }
        
        RemSpace.saveToDisk()
        if completion != nil  {
            completion! (200, apptitle, allofme)
        }
    }
    catch {
        print("loadFromITunesSharing: file system error \(error)")
    }
    
}
//
//fileprivate static func  xloadFromLocal(from localpath:String) -> URL {
//    
//    do {
//        let ext = (localpath as NSString).pathExtension
//        let name = "\(filenum).\(ext)"
//        
//        let newfilename = sharedAppContainerDirectory().appendingPathComponent(name, isDirectory: false)
//        
//        if FileManager.default.fileExists(atPath: newfilename.absoluteString)
//        {
//            return newfilename
//        }
//        
//        // now copy, could be in done in back but why?
//        
//        let data = try Data(contentsOf: URL(string:localpath)!)
//        try data.write(to: newfilename, options: .atomicWrite)
//        
//        return newfilename
//    }
//    catch {
//        print("Could not load local \(localpath)")
//        // might as well die at this point
//        fatalError("could not load \(error)")
//    }
//}
//
//
//fileprivate static func xloadFromRemote(from remotepath:String) -> URL? {
//    do {
//        let ext = (remotepath as NSString).pathExtension
//        let name = "\(filenum).\(ext)"
//        let newfilename = sharedAppContainerDirectory().appendingPathComponent(name, isDirectory: false)
//        
//        if FileManager.default.fileExists(atPath: newfilename.absoluteString)
//        {
//            return newfilename
//        }
//        
//        // now copy, could be in done in back but why?
//        let data = try Data(contentsOf: URL(string:remotepath)!)
//        try data.write(to: newfilename, options: .atomicWrite)
//        
//        return newfilename
//    }
//    catch {
//        print("Could not load from \(remotepath) \(error)")
//    }
//    return nil
//}
