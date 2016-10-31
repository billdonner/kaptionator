//
//  manifest.swift
//  shtickerz
//
//  Created by bill donner on 7/22/16.
//  Copyright © 2016 martoons. All rights reserved.
//

import UIKit

//MARK: - Manifest is only static funcs

///  completion handler typealias 

/// Manifest bundles static operations on groups of manifest entries
public struct Manifest {
    //
    static func parseData(_ data:Data, baseURL: String,completion:  ((Int,String,[RemoteAsset]) -> (Swift.Void))) {
        var final : [RemoteAsset] = []
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
                            var thumbnail: String = ""
                            if    let thumbpath  = sit["thumb"] as? String {
                                thumbnail = baseURL +  thumbpath
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
                            let remoteAsset = RemoteAsset(
                                localurl: URL(string:imagepath)!,
                                options: options,
                                title: title, thumb:thumbnail)
                            
                            RemSpace.addasset(ra: remoteAsset) // be sure to count
                            final.append (remoteAsset)
                        }
                    }
                }//for
                completion(200,pack, final ) //}// made it
                return
            }
        }// inner do
        catch let error as NSError {
            print ("************* bad JSON parseData \(error) ********** ")
            completion(error.code, "-err0r-", final ) //}// made it
        }
    }
    private static func processOneURL(_ url:URL,  completion:@escaping ((Int,String,[RemoteAsset]) -> (Swift.Void))) {
        
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
    
    private static func processOneLocal(_ url:URL,  completion:@escaping ((Int,String,[RemoteAsset]) -> (Swift.Void))) {
        do {
        let data = try Data(contentsOf: url)
        
        let baseURL = (url.absoluteString as NSString).deletingLastPathComponent.appending("/")
         
            parseData(data, baseURL: baseURL, completion: completion)
     
        }
            catch let error {
                  completion((error as NSError).code,"", [] )
            }

    }
    static func loadJSONFromLocal(url:URL?,completion:((Int,String,[RemoteAsset]) -> (Swift.Void))?) {
        guard let url = url else {
            fatalError("loadJSONFromLocal")
        }
        processOneLocal (  url ){ status, s, mes in
            
            if completion != nil  {
                completion! (status, "lny", mes)
            }
         
        }
    }
    
    static func loadJSONFromURL(url:URL?,completion:((Int,String,[RemoteAsset]) -> (Swift.Void))?) {
        guard let url = url else {
            fatalError("loadFromITunesSharing(observer: observer,completion:completion)")
        }
        processOneURL (  url ){ status, s, mes in 
            if completion != nil  {
                completion! (status, "sny", mes)
            }
        }
    }
}
    
    /// build a manifest from files user drags into itunes
//    
//    static func manifestFromDocumentsDirectory(pack:String) -> String {
//        var manifestBuffer = "{\"pack\":\"\(pack)\",\n\"description\":\"Stikerz Pack Manifest for \(pack)\",\n\"generated\":\"\(Date())\",\n\"images\":[\n"
//        let dirprefix = "images/"
//        var first = true
//        do {
//            let dir = FileManager.default.urls (for:  .documentDirectory, in: .userDomainMask)
//            let documentsUrl =  dir.first!
//            
//            // Get the directory contents urls (including subfolders urls)
//            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
//            let _ = directoryContents.map {
//                let lastpatch = $0.lastPathComponent
//                if !lastpatch.hasPrefix(".") { // exclude wierd files
//                    let image = dirprefix + lastpatch
//                    let part1 = image.components(separatedBy: ".")
//                    let part2 = part1[0].components(separatedBy: "-")
//                    let part3 = part2[0].components(separatedBy: "/")
//                    if first { first = false } else { manifestBuffer += ", " }
//                    manifestBuffer += "{\"image\":\"\(image)\",\"title\":\"\(part3[1])\"}\n"
//                }
//            }
//        }
//        catch {
//            print("manifestBuffer: cant get directory \(error)")
//        }
//        manifestBuffer += "]}" // close the json epression
//        print("manifestBuffer: " + manifestBuffer)
//        return manifestBuffer
//    }
//    


//
//private static func processAllPacks(url:URL,completion:@escaping UFRS) {
//    IO.httpGET(url:url) { status,data in
//        //print("status \(status)")
//        guard status == 200 else {
//            completion (status, [:],"", false,[])
//            return
//        } // not 200
//
//        if let data = data {
//            do {
//
//                let json = try JSONSerialization.jsonObject(with: data , options: [])
//                var final : [(pack:String,url:URL)] = []
//                if let jobj = json as? JSONDict,
//                    let apptitle = jobj ["app-title"] as? String,
//                    let showsections = jobj ["show-sectionheads"] as? Bool,
//                    let packsites = jobj ["pack-sites"] {
//                    for packsite in packsites as! [[String:String]] {
//                        if let ps = packsite["name"], let url = packsite["url"]{
//
//                            final.append((pack:ps,url:URL(string:url)!))
//                        } else {
//                            print ("blank or bad line spec \(url)")
//                        }
//                    }
//                    completion (200, [:],apptitle,showsections, final)
//                    return
//                }
//                return  // made it
//            }// inner do
//            catch  {
//                print ("processAllPacks not found or bad parse \(url)")
//                // caught inner throw from bad JSON parse
//                completion ( 502, [:],"", false,[])
//                return
//            }
//        } else {
//            // good status but no data
//            completion ( 501, [:],"", false,[])
//            return
//        }
//    }// end of closure
//}
//

