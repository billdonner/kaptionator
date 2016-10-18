//
//  MasterViewController
//  Re-Kaptionator
//
//  Created by Bill Donner on 15/12/2015.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//
import UIKit
// if nil we'll just pull from documents directory inside the catalog controller
var stickerManifestURL: URL? {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["REMOTE-MANIFEST-URL"] as? String { return URL(string:w) }
    return nil
}
}
protocol ControlledByMasterView{
     var mvc:MasterViewController!{ get }
}
class ControlledCollectionViewController:UICollectionViewController,ControlledByMasterView {
     var mvc: MasterViewController!
 
}
final class MasterViewController: UIViewController {
    let  offColor:UIColor  = UIColor.lightGray

    @IBAction func unwindToMaster(_ segue: UIStoryboardSegue)  {}
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    
    @IBOutlet weak var catb: UIBarButtonItem!
    
    @IBOutlet weak var stickerz: UIBarButtonItem!
    
    @IBOutlet weak var helpbbi: UIBarButtonItem!
    @IBOutlet weak var imessage: UIBarButtonItem!
    
    @IBOutlet weak var coloredSpacer: UIView! 
    var currentViewController: UIViewController?
    
    var showFirstHelp = true
    private var showCatalogViewController: ControlledCollectionViewController?
    private var showCaptionedViewController: CapationatedViewController?
    private var showMessagesViewController: MessagesViewController?
    private var testButtonViewController: UIViewController?
    private var logoNotRemoved = true
    private var allBarButtonItems : [UIBarButtonItem] = []
    
    //MARK:- Lifecyle for ViewControllers

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let _  = segue.destination as? HelpOverlayViewController {
            //detailsViewController.presentingViewController?
            self.modalPresentationStyle = .overCurrentContext
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        let cg = CGRect(x:0,y:0,width:self.view.frame.width/3.0, height:44.0)
        let fooview = UILabel(frame:cg)
        fooview.text = appTitle// not extensionScheme
        fooview.textAlignment = .center
        fooview.numberOfLines = 0
        fooview.adjustsFontSizeToFitWidth = true
        
        self.navigationItem.titleView = fooview
        // turn off toolbar for the itunes variant
        self.navigationController?.toolbar.isHidden =        
        showCatalogID == "ShowITunesID"
 
        
        // start in the catalog
        catb.tintColor = appTheme.catalogColor
        stickerz.tintColor = offColor
        imessage.tintColor = offColor
        helpbbi.tintColor = appTheme.textColor
        catb.isEnabled = false
        stickerz.isEnabled = false
        imessage.isEnabled = false
        allBarButtonItems = [catb,helpbbi,imessage,stickerz]
        
        
        self.view.backgroundColor = appTheme.backgroundColor

        let dir = FileManager.default.urls (for: .documentDirectory, in : .userDomainMask)
        let documentsUrl =  dir.first!
        print("-------Running from ",documentsUrl," ---------")
    
        databaseStuff()
        finishStartup()
        
    }// fall straight into it
    private func finishStartup() {
        showCatalogViewController = self.storyboard?.instantiateViewController(withIdentifier: showCatalogID ) as? ControlledCollectionViewController
        showCatalogViewController?.mvc = self
        currentViewController = showCatalogViewController
        
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController( currentViewController!)
        self.addSubview(subView: currentViewController!.view, toView: self.containerView)
        currentViewController!.didMove(toParentViewController: self)
        activityIndicatorView.stopAnimating()
        coloredSpacer.backgroundColor = appTheme.catalogColor
        for bbi in allBarButtonItems {
            bbi.isEnabled = true
           // bbi.width = 32
        }
        if logoNotRemoved {
           // logoView.removeFromSuperview()
            logoNotRemoved = false
            coloredSpacer.backgroundColor = appTheme.catalogColor
        }
    }
 
    // this must invoke a popup - just do the performmoreseque
    @IBAction func helpAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "HelpDropdownViewControllerID", sender: nil)
    }
    
    @IBAction func catalogueAction(_ sender: UIBarButtonItem) {
  //  orgbbi.isEnabled = false // always true on this tab
        guard  currentViewController != showCatalogViewController ||
            showCatalogViewController == nil else  {  return }
        coloredSpacer.backgroundColor = appTheme.catalogColor
        for bbi in allBarButtonItems {
            bbi.tintColor = bbi == sender ? coloredSpacer.backgroundColor : offColor
        }
 
        if showCatalogViewController == nil {
            let vcid = showCatalogID
            
            showCatalogViewController = self.storyboard?.instantiateViewController(withIdentifier: vcid ) as? ControlledCollectionViewController
            showCatalogViewController?.mvc = self
            
            showCatalogViewController?.view.translatesAutoresizingMaskIntoConstraints = false
            
        }
        cycleFromViewController(oldViewController:  currentViewController!, toViewController: showCatalogViewController!)
    
    currentViewController = showCatalogViewController
    }
   
    
    @IBAction func stickerAction(_ sender: UIBarButtonItem) {
        guard  currentViewController != showCaptionedViewController ||
            showCaptionedViewController == nil else  { return }
        coloredSpacer.backgroundColor = appTheme.stickerzColor
        for bbi in allBarButtonItems {
            bbi.tintColor = bbi == sender ? coloredSpacer.backgroundColor : offColor
        }
        showCaptionedViewController = self.storyboard?.instantiateViewController(withIdentifier: "CaptionedViewControllerID" ) as? CapationatedViewController
        showCaptionedViewController?.mvc = self
        
        showCaptionedViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        cycleFromViewController(oldViewController:  currentViewController!, toViewController: showCaptionedViewController!)
        currentViewController = showCaptionedViewController
        
        self.navigationItem.title = "History"
    }
    
    @IBAction func imsg(_ sender: UIBarButtonItem) {
    
        guard  currentViewController != showMessagesViewController || showMessagesViewController == nil else  { return }
        coloredSpacer.backgroundColor = appTheme.iMessageColor
        for bbi in allBarButtonItems {
            bbi.tintColor = bbi == sender ? coloredSpacer.backgroundColor : offColor
        }
        
        showMessagesViewController = self.storyboard?.instantiateViewController(withIdentifier: "MessageViewControllerID") as? MessagesViewController
        
        showMessagesViewController?.mvc = self
        showMessagesViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        cycleFromViewController(oldViewController: currentViewController!, toViewController: showMessagesViewController!)
        currentViewController = showMessagesViewController
        self.navigationItem.title = "Stickers"
     }

    //MARK:- move between view controllers
   fileprivate  func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
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
    fileprivate func addSubview(subView:UIView,toView parentView:UIView) {
        parentView.addSubview(subView)
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",  options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|", options: [], metrics: nil, views: viewBindingsDict))
    }
}
