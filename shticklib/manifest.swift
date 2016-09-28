//
//  manifest.swift
//  shtickerz
//
//  Created by bill donner on 7/22/16.
//  Copyright © 2016 martoons. All rights reserved.
//

import UIKit

//MARK: - Manifest is only static funcs

/// protocol to allow viewcontrollers to Observe data model changes
protocol MEObserver {
    func newdocument(_ colors: JSONDict, _ title:String)
    func newpack(_ pack: String,_ showsectionhead:Bool)
    func newentry(me:RemoteAsset)
    
    
}

typealias ManifestItems = [RemoteAsset]

///  completion handler typealias
typealias GFRM = ((_ status:Int,
    _ name:String,
    _ items:ManifestItems) -> (Swift.Void))

/// Manifest bundles static operations on groups of manifest entries
struct Manifest {
    
    private static func processAllPacks(url:URL,completion:@escaping UFRS) {
        IO.httpGET(url:url) { status,data in
            //print("status \(status)")
            guard status == 200 else {
                completion (status, [:],"", false,[])
                return
            } // not 200
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data , options: [])
                    var final : [(pack:String,url:URL)] = []
                    if let jobj = json as? JSONDict,
                        let apptitle = jobj ["app-title"] as? String,
                        let showsections = jobj ["show-sectionheads"] as? Bool,
                        let packsites = jobj ["pack-sites"] {
                        for packsite in packsites as! [[String:String]] {
                            if let ps = packsite["name"], let url = packsite["url"]{
                                
                                final.append((pack:ps,url:URL(string:url)!))
                            } else {
                                print ("blank or bad line spec \(url)")
                            }
                        }//for
                        var colors: JSONDict
                        if let colordict = jobj ["motif"] as? JSONDict {
                            colors = colordict
                        } else {
                            colors = ["bar-tint-color":"lightblue" as AnyObject,
                                      "bar-text-color":"beige" as AnyObject,
                                      "section-tint-color":"skyblue" as AnyObject,
                                      "section-text-color":"beige" as AnyObject,
                                      "background-color": "deepskyblue" as AnyObject]
                        }
                        completion (200, colors,apptitle,showsections, final)
                        return
                    }
                    return  // made it
                }// inner do
                catch  {
                    print ("processAllPacks not found or bad parse \(url)")
                    // caught inner throw from bad JSON parse
                    completion ( 502, [:],"", false,[])
                    return
                }
            } else {
                
                // good status but no data
                completion ( 501, [:],"", false,[])
                return
            }
        }// end of closure
    }
    
    
    static func parseData(_ data:Data, baseURL: String,completion:@escaping GFRM) {
        var final : ManifestItems = []
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let jobj = json as? JSONDict,
                let sites = jobj["images"] as? [AnyObject],
                let pack = jobj["pack"] as? String {
                for site in sites {
                    if  let sit  = site as? JSONDict {
                        if let imgpath = sit["image"] as? String {
                            // animation must be present And true
                            var animated: Bool = false
                            if    let anima  = sit["animated"] as? Bool {
                                if anima == true {
                                    animated = true
                                }
                            }
                            var title: String = ""
                            if    let titl  = sit["title"] as? String {
                                title = titl
                            }
                            
                            let imagepath = baseURL + imgpath
                            
                            var sizes = "S"
                            if let szes = sit["size"] as? String {
                                sizes = szes
                            }
                            // actually need
                            var options = StickerMakingOptions()
                            if sizes.contains("S") {
                                options.insert( .generatesmall)
                            }
                            if sizes.contains("M") {
                                options.insert( .generatemedium)
                            }
                            if sizes.contains("L") {
                                options.insert( .generatelarge)
                            }
                            if animated  //|| title == ""
                            {
                                options.insert( .generateasis)
                            }
                            
                            // setting up remote asset of nil will cause us to load the picture
                            let remoteAsset = RemoteAsset(pack: pack,
                                                          title: title,
                                                          remoteurl: imagepath,
                                                          
                                                          localpath: nil,
                                                          options: options)
                            
                            RemSpace.addasset(ra: remoteAsset) // be sure to count
                            final.append (remoteAsset)
                        }
                    }
                }//for
                completion(200,pack, final ) //}// made it
                return
            }
        }// inner do
        catch  {
            print ("************ bad JSON parseData ********** ")
            completion(503, "-err0r-", final ) //}// made it
        }
    }
    private static func processOnePack(pack: String, url:URL,  completion:@escaping GFRM) {
        
        IO.httpGET(url:url) { status,data in
            guard status == 200 else {
                completion(status,"", [] )
                return
            }
            let baseURL = (url.absoluteString as NSString).deletingLastPathComponent.appending("/")
            
            if let data = data {
                parseData(data, baseURL: baseURL, completion: completion)
            }
        }
    }

    /// load a bunch of manifests as listed in a super-manifest
    
    static func loadFromRemoteJSON(url:URL?,  observer:MEObserver?, completion:GFRM?) {
        guard let url = url else {
             fatalError("loadFromITunesSharing(observer: observer,completion:completion)")
        }
        var allofme:ManifestItems = []
        processAllPacks(url:url) {status, colorsdict, apptitle, showsectionhead, shmurls in
            guard status == 200 else {
                if let completion = completion  {
                    completion (status, apptitle, [])
                }
                return
            }
            // now run thru and fill in the allImages local structure
            //remSpace.rebuildImageData() // refills allImages Structure
            var downcount = shmurls.count
            observer?.newdocument(colorsdict, apptitle)
            for shmurl in shmurls {
                let url = shmurl.1
                let pack = shmurl.0
                processOnePack (pack:pack, url: url //try! url.appendingPathComponent("manifest.json")
                    
                ){ status, s, mes in
                    observer?.newpack(pack,showsectionhead)
                    for me in mes {
                        allofme.append(me)
                        
                        observer?.newentry(me: me)
                    }
                    // is this the very last
                    downcount -= 1
                    if downcount == 0 {
                        // at this point we are full assembled and good to go
                        if completion != nil  { completion! (status, apptitle, allofme) }
                    }
                }
            }
        }
    }
    
    /// build a manifest from files user drags into itunes
    static func manifestFromDocumentsDirectory(pack:String) -> String {
        var manifestBuffer = "{\"pack\":\"\(pack)\",\n\"description\":\"Stikerz Pack Manifest for \(pack)\",\n\"generated\":\"\(Date())\",\n\"images\":[\n"
        let dirprefix = "images/"
        var first = true
        do {
            let dir = FileManager.default.urls (for:  .documentDirectory, in: .userDomainMask)
            let documentsUrl =  dir.first!
            
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            let _ = directoryContents.map {
                let lastpatch = $0.lastPathComponent
                if !lastpatch.hasPrefix(".") { // exclude wierd files
                    let image = dirprefix + lastpatch
                    let part1 = image.components(separatedBy: ".")
                    let part2 = part1[0].components(separatedBy: "-")
                    let part3 = part2[0].components(separatedBy: "/")
                    if first { first = false } else { manifestBuffer += ", " }
                    manifestBuffer += "{\"image\":\"\(image)\",\"title\":\"\(part3[1])\"}\n"
                }
            }
        }
        catch {
            print("manifestBuffer: cant get directory \(error)")
        }
        manifestBuffer += "]}" // close the json epression
        print("manifestBuffer: " + manifestBuffer)
        return manifestBuffer
    }
}

 
