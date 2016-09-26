//
//  InfoDictIOS.swift
//  shtickerz
//
//  Created by bill donner on 7/5/16.
//  Copyright © 2016 martoons. All rights reserved.
//

import UIKit


/// AppCaptionSpace is a singleton global struct that is persisted
//  every instance of a user captioning a particular element is here
//   note to self: DO NOT POLLUTE THIS STRUCT with class refs

var capSpace  = AppCaptionSpace(AppPrivateDataSpace)


// global funcs called fr4om multiple kind of view controllers
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
    webViewOverlay.contentMode = .scaleAspectFill
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

struct IO {
    private static func xdataTask(with url: URL, completionHandler: @escaping DTSKR) -> URLSessionDataTask {
        let session = URLSession.shared
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 5)
        //  print ("queing \(request)")
        let x = session.dataTask(with: request, completionHandler: completionHandler)
    
        return x
    }

    static func httpGET(url: URL,
                        completion:  @escaping PGRC)  {
        let task = xdataTask(with:url) {
            ( data,   response,  error) in
            //print("datatask responded \(error?.code)")
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                print("**** httpGET completing with error \(error)")
                completion(571,nil)
                return
            }
            // print("httpGET completing with data \(data)")
            completion(200,data)
            return
        }
        task.resume()
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


 
typealias LAS = ((String,[AppCE])->())?

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


func prepareStickers( pack:String,title:String,imagepath:String, 
            caption:String,
            options:StickerMakingOptions) throws -> SharedCE {
    do {
        let theData = try Data(contentsOf: URL(string: imagepath)!)
        
        
        // adjust options based on size of image
        
        // first build the files
        
        let stickerPaths =   StickerFileFactory.createStickerFilesFrom (imageData: theData ,path: imagepath, caption:caption, options:options)
        
        print("made sticker file urls \(stickerPaths)")
        
        let t = SharedCE( pack: pack, title: title,
                                imagepath: imagepath,
                                stickerpaths:stickerPaths,
                                caption: caption,
                                options: options )
        
        let _ = memSpace.add(ce: t)
        return t
    }
    catch {
        throw error
    }
}

func checkForFileVariant(_ ce:SharedCE,
                         _ variant:String) -> Bool {
    let caption = ce.caption
let path = ce.localimagepath   
    let hashval = "\(caption.hash)"
    let assep = (path as NSString).lastPathComponent
    let type = (assep as NSString).pathExtension
    let test = ( path as NSString).deletingPathExtension + "-\(variant)-\(hashval)." + type
 
    
let ent  = memSpace.findMatchingEntry(atPath:test)
   let  t = ent != nil
   //let t = FileManager.default.fileExists(atPath: test)
    if t  {
        print("\(test) exists")
    } else {
        print("\(test) does not exist")
    }
     return t
    //return false
}
