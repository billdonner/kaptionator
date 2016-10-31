//
//  RemoteAsset.swift
//  ub ori
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Darjeeling Apps. All rights reserved.
//

import UIKit
 


// RemoteAsset represents one image on a remote server in a "pack"
public struct RemoteAsset {
    let pack:String
       let caption:String
       let remoteurl :String
       let thumbnail:String
       let localimagepath:String
       let options:StickerMakingOptions
    
    // clone this while changing the stickermaking options
    //
    //
    func copyWithNewOptions(stickerOptions: StickerMakingOptions) -> RemoteAsset {
        
        let appce = RemoteAsset(pack: pack, title: caption, thumb: thumbnail, remoteurl: remoteurl, localpath: localimagepath, options: stickerOptions)
        return appce
        
    }
    
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
     init(pack:String,title:String,thumb:String, remoteurl:String?,localpath:String?, options:StickerMakingOptions) {
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
    
    /// loads from documents without presenting a UI
    static func QuietlyAddNewURL(_ url:URL,options:StickerMakingOptions)  {
        let ra = RemoteAsset(localurl:url,
                             options: options,
                             title:url.lastPathComponent)
        RemSpace.addasset(ra: ra)
        RemSpace.saveToDisk()
    }

static func loadFromITunesSharing(   completion:((Int,String,[RemoteAsset]) -> (Swift.Void))?) {
    //let iTunesBase = manifestFromDocumentsDirector
    // store file locally into catalog
    // var first = true
    let apptitle = "-local-"
    var allofme:[RemoteAsset] = []
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
