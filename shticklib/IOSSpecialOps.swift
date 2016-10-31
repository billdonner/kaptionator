//
//  IOSSpecialOps.swift
//  xig
//
//  Created by bill donner on 3/7/16.
//  Copyright © 2016 billdonner. All rights reserved.
//

import UIKit


struct IOSSpecialOps { // only compiles in main app - ios bug?
    
    static func openwebsite(_ presentor:UIViewController) {
        
        let url = URL(string:websitePath)!
        let vc = SFViewController(url: url)
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate =  vc
        presentor.present(nav, animated: true, completion: nil)
    }
    static func openInAnotherApp(url:URL)->Bool {
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
    static func ask (_ vc:UIViewController, title:String, mess:String, f:@escaping ()->()) {
        
        let action : UIAlertController = UIAlertController(title:title, message: mess, preferredStyle: .alert)
        
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {alertAction in
            
        }))
        action.addAction(UIAlertAction(title: "Delete", style: .default, handler: {alertAction in
                f()
            }))
        
        action.modalPresentationStyle = .popover
        let popPresenter = action.popoverPresentationController
        popPresenter?.sourceView = vc.view
        vc.present(action, animated: true , completion:nil)
    }
    static func ask (_ vc:UIViewController, title:String, mess:String) {
        ask(vc,title:title,mess:mess,f:{})
    }
}

extension UIViewController {
    
    func animatedViewOf(frame:CGRect, size:CGSize, imageurl:String) -> UIWebView {
        let inset:CGFloat = 10
        let actualsize = min(size.width,size.height)
        let screensize = min( frame.width,frame.height)
        let imagesize = min(actualsize , screensize)
        let offs = (screensize - imagesize) / 2
        let frem = CGRect(x:offs+inset,
                          y:offs+inset,
                          width:imagesize-2*inset,
                          height:imagesize-2*inset)
        
        let html = "<html5> <meta name='viewport' content='width=device-width, maximum-scale=1.0' /><body  style='padding:0px;margin:0px'><img  src='\(imageurl)' height='\(frem.height)' width='\(frem.width)'  alt='\(imageurl)' /</body></html5>"
        let webViewOverlay = UIWebView(frame:frem)
        webViewOverlay.scalesPageToFit = true
        webViewOverlay.contentMode = .scaleToFill
        webViewOverlay.loadHTMLString(html, baseURL: nil)
        return webViewOverlay
    }
    
    //dismissButtonAltImageName
    func addDismissButtonToViewController(_ v:UIViewController,named:String, _ sel:Selector){
        let img = UIImage(named:named)
        let iv = UIImageView(image:img)
        iv.frame = CGRect(x:0,y:0,width:60,height:60)//// test
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFit
        let tgr = UITapGestureRecognizer(target: v, action: sel)
        iv.addGestureRecognizer(tgr)
        v.view.addSubview(iv)
    }
}


struct UnusedCache {
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


//extension URL {
    
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
//        
//        let task = URLSession.shared.dataTask(with: self) {
//            data, response, error in
//            if error == nil {
//                
//                
//                if let  data = data,
//                  let  image = UIImage(data: data ) {  // can scale into small sells
//                    
////                    print ("added image \(image) \(self.absoluteString!) to cache)")
////                        TheImageCache.shared.setObject (
////                            image,
////                            forKey:CacheKey(self.absoluteString!) )
//                        DispatchQueue.main.async  {
//                            completion(image)
//                        }
//                }
//            }
//        }
//        
//        
       // task.resume()
    }
//}
}
