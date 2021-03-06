//
//  InfoDictIOS.swift
//  shtickerz
//
//  Created by bill donner on 7/5/16.
//  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
//

import UIKit
//import stikz

// global funcs called fr4om multiple kind of view controllers
public struct BorderSettings {
    public static let width: CGFloat = 2.0 / UIScreen.main.scale
    public static let colour = UIColor(white: 0.5, alpha: 1.0)
}
public struct IO {
    
   private typealias PGRC = ((_ status:Int, _ data:Data?) -> (Swift.Void))
   public static  func setupAnimationPreview(wv:UIWebView,imgurl:URL) {
        
        let scale : CGFloat = 5 / 1
        
        let w = wv.frame.width
        let h = wv.frame.height
        let html = "<html5> <meta name='viewport' content='width=device-width, maximum-scale=1.0' /><center  style='padding:0px;margin:0px'><img  style='max-width: 100%; height: auto;' src='\(imgurl)' alt='\(imgurl) height='\(h * scale)' width='\(w * scale)' ></center></html5>"
        wv.scalesPageToFit = true
        wv.contentMode = .scaleAspectFit
        
        //wv.center = menuImageView.center
        wv.loadHTMLString(html, baseURL: nil)
    }

  public static func prepareStickers( pack:String,title:String,imageurl:URL, caption:String, options:StickerOptions) throws -> SharedCE {
        do {
            let theData = try Data(contentsOf:imageurl)
            
            if let stickerURL =   StickerFileFactory.createStickerFileFrom (imageData: theData ,imageurl: imageurl, caption:caption, options:options) {
            
            print("made sticker file urls \(stickerURL)")
            
            let t = SharedCE( pack: pack, title: title,
                              imageurl: imageurl,
                              stickerurl:stickerURL,
                              caption: caption,
                              options: options )
            
            let _ = SharedCaptionSpace.add(ce: t)
            return t
            }
            else {
                throw KaptionatorErrors.cant
            }
        }
        catch {
            throw error
        }
    }
    
  public static func checkForFileVariant(_ ce:SharedCE,_ variant:String) -> Bool {
        guard let imgurl = ce.appimageurl else { return  false }
        let caption = ce.caption
        let path = imgurl.absoluteString
        let hashval = "\(caption.hash)"
        let assep = (path as NSString).lastPathComponent
        let type = (assep as NSString).pathExtension
        let test = ( path as NSString).deletingPathExtension
            + "-\(variant)-\(hashval)." + type
        
        let ent  = SharedCaptionSpace.findMatchingEntry(atPath:test)
        let  t = ent != nil
        if t  {
            print("\(test) exists")
        } else {
            print("\(test) does not exist")
        }
        return t
        //return false
    }
    
}
/// these are all the colors permitted in the incoming json manifests
struct Css   {
    
    static let colors = [
        "aliceblue": "#f0f8ff",
        "antiquewhite": "#faebd7",
        "aqua": "#00ffff",
        "aquamarine": "#7fffd4",
        "azure": "#f0ffff",
        "beige": "#f5f5dc",
        "bisque": "#ffe4c4",
        "black": "#000000",
        "blanchedalmond": "#ffebcd",
        "blue": "#0000ff",
        "blueviolet": "#8a2be2",
        "brown": "#a52a2a",
        "burlywood": "#deb887",
        "cadetblue": "#5f9ea0",
        "chartreuse": "#7fff00",
        "chocolate": "#d2691e",
        "coral": "#ff7f50",
        "cornflowerblue": "#6495ed",
        "cornsilk": "#fff8dc",
        "crimson": "#dc143c",
        "cyan": "#00ffff",
        "darkblue": "#00008b",
        "darkcyan": "#008b8b",
        "darkgoldenrod": "#b8860b",
        "darkgray": "#a9a9a9",
        "darkgreen": "#006400",
        "darkgrey": "#a9a9a9",
        "darkkhaki": "#bdb76b",
        "darkmagenta": "#8b008b",
        "darkolivegreen": "#556b2f",
        "darkorange": "#ff8c00",
        "darkorchid": "#9932cc",
        "darkred": "#8b0000",
        "darksalmon": "#e9967a",
        "darkseagreen": "#8fbc8f",
        "darkslateblue": "#483d8b",
        "darkslategray": "#2f4f4f",
        "darkslategrey": "#2f4f4f",
        "darkturquoise": "#00ced1",
        "darkviolet": "#9400d3",
        "deeppink": "#ff1493",
        "deepskyblue": "#00bfff",
        "dimgray": "#696969",
        "dimgrey": "#696969",
        "dodgerblue": "#1e90ff",
        "firebrick": "#b22222",
        "floralwhite": "#fffaf0",
        "forestgreen": "#228b22",
        "fuchsia": "#ff00ff",
        "gainsboro": "#dcdcdc",
        "ghostwhite": "#f8f8ff",
        "gold": "#ffd700",
        "goldenrod": "#daa520",
        "gray": "#808080",
        "green": "#008000",
        "greenyellow": "#adff2f",
        "grey": "#808080",
        "honeydew": "#f0fff0",
        "hotpink": "#ff69b4",
        "indianred": "#cd5c5c",
        "indigo": "#4b0082",
        "ivory": "#fffff0",
        "khaki": "#f0e68c",
        "lavender": "#e6e6fa",
        "lavenderblush": "#fff0f5",
        "lawngreen": "#7cfc00",
        "lemonchiffon": "#fffacd",
        "lightblue": "#add8e6",
        "lightcoral": "#f08080",
        "lightcyan": "#e0ffff",
        "lightgoldenrodyellow": "#fafad2",
        "lightgray": "#d3d3d3",
        "lightgreen": "#90ee90",
        "lightgrey": "#d3d3d3",
        "lightpink": "#ffb6c1",
        "lightsalmon": "#ffa07a",
        "lightseagreen": "#20b2aa",
        "lightskyblue": "#87cefa",
        "lightslategray": "#778899",
        "lightslategrey": "#778899",
        "lightsteelblue": "#b0c4de",
        "lightyellow": "#ffffe0",
        "lime": "#00ff00",
        "limegreen": "#32cd32",
        "linen": "#faf0e6",
        "magenta": "#ff00ff",
        "maroon": "#800000",
        "mediumaquamarine": "#66cdaa",
        "mediumblue": "#0000cd",
        "mediumorchid": "#ba55d3",
        "mediumpurple": "#9370db",
        "mediumseagreen": "#3cb371",
        "mediumslateblue": "#7b68ee",
        "mediumspringgreen": "#00fa9a",
        "mediumturquoise": "#48d1cc",
        "mediumvioletred": "#c71585",
        "midnightblue": "#191970",
        "mintcream": "#f5fffa",
        "mistyrose": "#ffe4e1",
        "moccasin": "#ffe4b5",
        "navajowhite": "#ffdead",
        "navy": "#000080",
        "oldlace": "#fdf5e6",
        "olive": "#808000",
        "olivedrab": "#6b8e23",
        "orange": "#ffa500",
        "orangered": "#ff4500",
        "orchid": "#da70d6",
        "palegoldenrod": "#eee8aa",
        "palegreen": "#98fb98",
        "paleturquoise": "#afeeee",
        "palevioletred": "#db7093",
        "papayawhip": "#ffefd5",
        "peachpuff": "#ffdab9",
        "peru": "#cd853f",
        "pink": "#ffc0cb",
        "plum": "#dda0dd",
        "powderblue": "#b0e0e6",
        "purple": "#800080",
        "rebeccapurple": "#663399",
        "red": "#ff0000",
        "rosybrown": "#bc8f8f",
        "royalblue": "#4169e1",
        "saddlebrown": "#8b4513",
        "salmon": "#fa8072",
        "sandybrown": "#f4a460",
        "seagreen": "#2e8b57",
        "seashell": "#fff5ee",
        "sienna": "#a0522d",
        "silver": "#c0c0c0",
        "skyblue": "#87ceeb",
        "slateblue": "#6a5acd",
        "slategray": "#708090",
        "slategrey": "#708090",
        "snow": "#fffafa",
        "springgreen": "#00ff7f",
        "steelblue": "#4682b4",
        "tan": "#d2b48c",
        "teal": "#008080",
        "thistle": "#d8bfd8",
        "tomato": "#ff6347",
        "turquoise": "#40e0d0",
        "violet": "#ee82ee",
        "wheat": "#f5deb3",
        "white": "#ffffff",
        "whitesmoke": "#f5f5f5",
        "yellow": "#ffff00",
        "yellowgreen": "#9acd32"]
    
    
    
    static func lookup(_ prop:String, _ props:JSONDict ) throws ->  UIColor {
        if  let color = props[prop] as? String {
            let hexcolor = Css.colors[color]
            if let hexcolor = hexcolor  {
                let hexcolorwalpha = hexcolor + "FF"
                let uic = UIColor(hexString:hexcolorwalpha)
                return uic
            }
            throw KaptionatorErrors.colornotfound
        }
        throw KaptionatorErrors.propertynotfound
    }
}

//typealias LAS = ((String,[AppCE])->())?

extension UIColor {
    public convenience init(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let parts = hexString.components(separatedBy: "#")
            let hexColor = parts[1]
            if hexColor.characters.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        self.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        return
    }
}

public struct IOSSpecialOps { // only compiles in main app - ios bug?
    
    
    public static func blurt (_ vc:UIViewController, title:String, mess:String, f:@escaping ()->()) {
        
        let action : UIAlertController = UIAlertController(title:title, message: mess, preferredStyle: .alert)
        
        action.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {alertAction in
            f()
        }))
        
        action.modalPresentationStyle = .popover
        let popPresenter = action.popoverPresentationController
        popPresenter?.sourceView = vc.view
        vc.present(action, animated: true , completion:nil)
    }
    public static func blurt (_ vc:UIViewController, title:String, mess:String) {
        blurt(vc,title:title,mess:mess,f:{})
    }
    public static func ask (_ vc:UIViewController, title:String, mess:String, f:@escaping ()->()) {
        
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
    public  static func ask (_ vc:UIViewController, title:String, mess:String) {
        ask(vc,title:title,mess:mess,f:{})
    }
}

extension UIViewController {
    
  public func animatedViewOf(frame:CGRect, size:CGSize, imageurl:String) -> UIWebView {
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
  public func addDismissButtonToViewController(_ v:UIViewController,named:String, _ sel:Selector){
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

//


// if nil we'll just pull from documents directory inside the catalog controller
public var  stickerManifestURL: URL? {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["REMOTE-MANIFEST-URL"] as? String { return URL(string:w) }
    return nil
}
}

/// "SHOW-CATALOG-ID" is the storyboard id of controller to use for the Catalog


public var showCatalogID: String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["SHOW-CATALOG-ID"] as? String { return w
    }
    else {
        return "ShowCatalogID"
    }
}
}



/// "REMOTE-WEBSITE-URL" is the website page for this sticker pack
public var websitePath: String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["REMOTE-WEBSITE-URL"] as? String { return w
    }
    fatalError("remote website url undefined")
    //return nil
}
}


public var nameForLeftBBI: String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["LEFT-BBI-NAME"] as? String { return w
    }
    return "no LEFT-BBI-NAME"
}
}
public var bigBlurb : String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["TOP-BLURB"] as? String { return w }
    fatalError("TOP-BLURB undefined")
    //return nil
}
}
public var innerBlurb : String {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["INNER-BLURB"] as? String { return w }
    else {return "a Catalog of All Stickers in the App"}
}
}

// if this is set we avoid the network completely
public var localResourcesBasedir : String? {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["LOCAL-RESOURCES-BASEDIR"] as? String { return w }
    return nil
}
}

