//
//  IOSSpecialOps.swift
//  xig
//
//  Created by bill donner on 3/7/16.
//  Copyright © 2016 billdonner. All rights reserved.
//

import UIKit
/// "BACKGROUND-IMAGE" is the fade-in image




/// "REMOTE-WEBSITE-URL" is the website page for this sticker pack
var websitePath: String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["REMOTE-WEBSITE-URL"] as? String { return w
    }
    fatalError("remote website url undefined")
    //return nil
}
}

struct IOSSpecialOps { // only compiles in main app - ios bug?
    
    static func openwebsite(_ presentor:UIViewController) {
        
        let url = URL(string:websitePath)!
        let vc = SFViewController(url: url)
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate =  vc
        presentor.present(nav, animated: true, completion: nil)
    }
    static     func openInAnotherApp(url:URL)->Bool {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url,options:[:]){ b in }
            return true
        }
        return false
    }
    static func blurt (_ vc:UIViewController, title:String, mess:String, f:@escaping ()->()) {
        
        let action : UIAlertController = UIAlertController(title:title, message: mess, preferredStyle: .alert)
        
        action.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {alertAction in
            f()
        }))
        
        action.modalPresentationStyle = .popover
        let popPresenter = action.popoverPresentationController
        popPresenter?.sourceView = vc.view
        vc.present(action, animated: true , completion:nil)
    }
   static func blurt (_ vc:UIViewController, title:String, mess:String) {
        blurt(vc,title:title,mess:mess,f:{})
    }
    
    
}
class CacheKey {
    // must wrap into real object for new generic Cache in swift3
    
    let str: String
    init(_ s:String) {
         str = s
    }
}
/// make an actual cache with a wrapped string as key and uiimage as value
typealias NSSSCache = NSCache <CacheKey,UIImage>

typealias CacheCompletion = ((UIImage) -> Void)

class TheImageCache {
    static let shared: NSSSCache = {
        let cache = NSSSCache()
        cache.name = "TheImageCache"
        cache.countLimit = 200 // Max 20 images in memory.
        cache.totalCostLimit = 10*1024*1024 // Max 100MB used.
  
        return cache
    }()
}
//extension NSSSCache: CacheDelegate {
//

//}


extension URL {
    
    /// Retrieves a pre-cached image, or nil if it isn't cached.
    /// You should call this before calling fetchImage.
    var cachedImage: UIImage? {
//        let c = TheImageCache.shared.object(forKey:
//            CacheKey(absoluteString!))
//        print ("lookup of \(absoluteString!) yields \(c != nil)")
//        return c
        return nil
    }
    
    /// Fetches the image from the network.
    /// Stores it in the cache if successful.
    /// Only calls completion on successful image download.
    /// Completion is called on the main thread.
    func fetchImage(completion: @escaping   CacheCompletion) {
        let task = URLSession.shared.dataTask(with: self) {
            data, response, error in
            if error == nil {
                
                
                if let  data = data,
                  let  image = UIImage(data: data ) {  // can scale into small sells
                    
//                    print ("added image \(image) \(self.absoluteString!) to cache)")
//                        TheImageCache.shared.setObject (
//                            image,
//                            forKey:CacheKey(self.absoluteString!) )
                        DispatchQueue.main.async  {
                            completion(image)
                        }
                }
            }
        }
        task.resume()
    }
}
