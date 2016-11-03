//
//  MasterViewController
//  Re-Kaptionator
//
//  Created by Bill Donner on 15/12/2015.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//
import UIKit
import stikz

protocol ControlledByMasterView : class {
    func refreshLayout()
}
protocol ModalOverCurrentContext : class {
}

fileprivate var masterViewController : MasterViewController?
final class MasterViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBAction func unwindToMaster(_ segue: UIStoryboardSegue)  {}
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var catb: UIBarButtonItem!
    @IBOutlet weak var stickerz: UIBarButtonItem!
    @IBOutlet weak var helpbbi: UIBarButtonItem!
    @IBOutlet weak var imessage: UIBarButtonItem!
    @IBOutlet weak var coloredSpacer: UIView!
    
    fileprivate var showFirstHelp = true
    fileprivate var currentViewController: UIViewController?
    fileprivate var showFirstViewController: UIViewController?
    fileprivate var showCaptionedViewController: CapationatedViewController?
    fileprivate var showMessagesViewController: MessagesViewController?
    fileprivate var logoNotRemoved = true
    fileprivate var allBarButtonItems : [UIBarButtonItem] = []
    
    //MARK:-  globally available static funcs
    
    
    let  offColor:UIColor  = UIColor.lightGray
    
    static func blurt(title:String,mess:String,compl:(()->())? = nil ) {
        IOSSpecialOps.blurt(masterViewController!,title: title,mess:mess) {
            compl?()
        }
    }
    
    static func ask(title:String,mess:String,compl:(()->())? = nil ) {
        IOSSpecialOps.ask(masterViewController!,title: title,mess:mess) {
            compl?()
        }
    }
    //MARK:- Lifecyle for ViewControllers
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let _  = segue.destination as? WebHelpViewController {
            //detailsViewController.presentingViewController?
            self.modalPresentationStyle = .overCurrentContext
        }
        else if "HelpDropdownViewControllerID" ==  segue.identifier {
            if  let hdvc = segue.destination as? HelpDropdownViewController {
                 hdvc.delegate = self
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MasterViewController  >>>>> \(tagLine)")
        
        masterViewController = self 
        self.view.backgroundColor = appTheme.backgroundColor
        let img = UIImage(named:backgroundImagePath)
         self.backgroundImageView.image = img
        replaceTitle(appTitle)
        
        // start in the catalog
        catb.tintColor = appTheme.catalogColor
        stickerz.tintColor = offColor
        imessage.tintColor = offColor
        helpbbi.tintColor = appTheme.textColor
        catb.isEnabled = false
        stickerz.isEnabled = false
        imessage.isEnabled = false
        allBarButtonItems = [catb,helpbbi,imessage,stickerz]
        
       databaseStuff()
        finishStartup()
        
    }// fall straight into it
    
    // MARK:- UIBarButtonItem actions for top buttons
    
    @IBAction func helpAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "HelpDropdownViewControllerID", sender: nil)
    }
    
    @IBAction func catalogueAction(_ sender: UIBarButtonItem) {
        if SharedCaptionSpace.itemCount() == 0 && showFirstHelp {
            showFirstHelp = false
            performSegue(withIdentifier: "StartupHelpID", sender: nil)
        }
        cycleaction(sender: sender, id:showCatalogID,
                    vc:&showFirstViewController,color:appTheme.catalogColor)
        replaceTitle(extensionScheme + " Home")
    }
    @IBAction func stickerAction(_ sender: UIBarButtonItem) {
        showFirstHelp = true
        cycleaction(sender: sender, id:"CaptionedViewControllerID",vc:&showCaptionedViewController,color:appTheme.stickerzColor)
        replaceTitle(extensionScheme + " History")
    }
    @IBAction func imsgAction(_ sender: UIBarButtonItem) {
        showFirstHelp = true
        cycleaction(sender: sender, id:"MessageViewControllerID",vc:&showMessagesViewController, color:appTheme.iMessageColor)
        replaceTitle(extensionScheme + " Stickers")
    }
}

//MARK:- private helper methods

private extension MasterViewController {
    
func databaseStuff() {
        //
        // restore or create captions db
        if let _ = try? AppCaptionSpace.restoreAppspaceFromDisk() {
            print ("kAppPrivateDataSpace restored,\(AppCaptionSpace.itemCount()) items ")
        } else { // nothing there
            AppCaptionSpace.reset()
            print ("kAppPrivateDataSpace reset,\(AppCaptionSpace.itemCount()) items ")
            AppCaptionSpace.saveToDisk()
        }
        //
        // restore or create shared memspace db for SharedCaptionSpace extension
        if let _ = try? SharedCaptionSpace.restoreSharespaceFromDisk() {
            print ("SharedCaptionSpace restored,\(SharedCaptionSpace.itemCount()) items ")
        } else { // nothing there
            SharedCaptionSpace.reset()
            print ("SharedCaptionSpace reset,\(SharedCaptionSpace.itemCount()) items ")
            SharedCaptionSpace.saveData()
        }
    }
    
    func resetvc (_ sender:UIBarButtonItem, _ vc:UIViewController,_ color:UIColor) {
        coloredSpacer.backgroundColor = color
        for bbi in allBarButtonItems {
            bbi.tintColor = bbi == sender ? coloredSpacer.backgroundColor : offColor
        }
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        cycleFromViewController(oldViewController: currentViewController!, toViewController: vc)
        currentViewController = vc
    }
    
    func cycleaction<VC:UIViewController>(sender:UIBarButtonItem, id:String, vc:inout VC?,color:UIColor) {
        
        guard  currentViewController != vc || vc == nil else  { return }
        if vc == nil {
            vc = self.storyboard?.instantiateViewController(withIdentifier: id) as? VC         }
        resetvc(sender, vc!,color)
    }
    
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        self.addSubview(subView: newViewController.view, toView:self.containerView!)
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
            },
                completion: { finished in
                        oldViewController.view.removeFromSuperview()
                        oldViewController.removeFromParentViewController()
                        newViewController.didMove(toParentViewController: self)
        })
    }
    func addSubview(subView:UIView,toView parentView:UIView) {
        parentView.addSubview(subView)
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
    parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",  options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|", options: [], metrics: nil, views: viewBindingsDict))
    }
    
    func replaceTitle(_ s:String) {
        let cg = CGRect(x:0,y:0,width:self.view.frame.width/3.0, height:44.0)
        let fooview = UILabel(frame:cg)
        fooview.text = s // not extensionScheme
        fooview.textAlignment = .center
        fooview.numberOfLines = 0
        fooview.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = fooview
    }
    
    func finishStartup() {
        let dir = FileManager.default.urls (for: .documentDirectory, in : .userDomainMask)
        let documentsUrl =  dir.first!
        print("-------Running from ",documentsUrl," ---------")
        
        showFirstViewController = self.storyboard?.instantiateViewController(withIdentifier: showCatalogID )
        currentViewController = showFirstViewController
        
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController( currentViewController!)
        self.addSubview(subView: currentViewController!.view, toView: self.containerView)
        currentViewController!.didMove(toParentViewController: self)
        
        activityIndicatorView.stopAnimating()
        coloredSpacer.backgroundColor = appTheme.catalogColor
        for bbi in allBarButtonItems {
            bbi.isEnabled = true
        }
        logoNotRemoved = false
    }
}

///HelpDropdownDelegate
extension MasterViewController: HelpDropdownDelegate {
    func refreshLayout() {
    
    }
}

//MARK: - StickerAsset is readonly once loaded from manifest

/// Manifest bundles static operations on groups of manifest entries
public struct Manifest {
    
    //
    public static func parseData(_ data:Data, baseURL: String,completion:  ((Int,String,[StickerAsset]) -> (Swift.Void))) {
        var final : [StickerAsset] = []
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
                            if    let thumbpath  = sit[kThumbNail] as? String {
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
                            
                            let thurl = URL(string:thumbnail)
                            let localurl = URL(string:imagepath)
                            let remoteAsset = StickerAsset(
                                localurl: localurl!,
                                options: options,
                                title: title, thumb:thurl)
                            
                            
                            StickerAssetSpace.addasset(ra: remoteAsset) // be sure to count
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
      private typealias DTSKR = ((_ data:Data?, _ response:URLResponse?, _ nserror:Error?) -> (Swift.Void))
    private static func xdataTask(with url: URL, completionHandler: @escaping DTSKR) -> URLSessionDataTask {
        let session = URLSession.shared
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 5)
        //  print ("queing \(request)")
        let x = session.dataTask(with: request, completionHandler: completionHandler)
        return x
    }
    
   static func httpGET(url: URL,  completion:  @escaping ((Int,Data?) -> (Swift.Void)))  {
        let task = xdataTask(with:url) {
            ( data,   response,  error) in
            //print("datatask responded \(error?.code)")
            guard   error ==  nil else {
                
                print("**** httpGET completing with error \(error)")
                completion((error as! NSError).code,nil)
                return
            }
            // print("httpGET completing with data \(data)")
            completion(200,data)
            return
        }
        task.resume()
    }

    
    private static func processOneURL(_ url:URL,  completion:@escaping ((Int,String,[StickerAsset]) -> (Swift.Void))) {
        
        httpGET(url:url) { status,data in
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
    
    private static func processOneLocal(_ url:URL,  completion:@escaping ((Int,String,[StickerAsset]) -> (Swift.Void))) {
        do {
            let data = try Data(contentsOf: url)
            
            let baseURL = (url.absoluteString as NSString).deletingLastPathComponent.appending("/")
            
            parseData(data, baseURL: baseURL, completion: completion)
            
        }
        catch let error {
            completion((error as NSError).code,"", [] )
        }
        
    }
    public static func loadJSONFromLocal(url:URL?,completion:((Int,String,[StickerAsset]) -> (Swift.Void))?) {
        guard let url = url else {
            fatalError("loadJSONFromLocal")
        }
        processOneLocal (  url ){ status, s, mes in
            
            if completion != nil  {
                completion! (status, "lny", mes)
            }
            
        }
    }
    
    public  static func loadJSONFromURL(url:URL?,completion:((Int,String,[StickerAsset]) -> (Swift.Void))?) {
        guard let url = url else {
            fatalError("loadFromITunesSharing(observer: observer,completion:completion)")
        }
        processOneURL (  url ){ status, s, mes in
            if completion != nil  {
                completion! (status, "sny", mes)
            }
        }
    }
    
    public static func loadFromITunesSharing(   completion:((Int,String,[StickerAsset]) -> (Swift.Void))?) {
        //let iTunesBase = manifestFromDocumentsDirector
        // store file locally into catalog
        // var first = true
        let apptitle = "-local-"
        var allofme:[StickerAsset] = []
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
                        
                        
                        let me = StickerAsset(remoteurl: $0,options: .generatemedium,title: imagename)
                        StickerAssetSpace.addasset(ra: me) // be sure to coun
                        allofme.append(me)                     }
                    
                    // finally, delete the file
                    try FileManager.default.removeItem(at: $0)
                }
            }
            
            StickerAssetSpace.saveToDisk()
            if completion != nil  {
                completion! (200, apptitle, allofme)
            }
        }
        catch {
            print("loadFromITunesSharing: file system error \(error)")
        }
    }
}
