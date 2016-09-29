//
//  MasterViewController
//  Re-Kaptionator
//
//  Created by Bill Donner on 15/12/2015.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//
import UIKit
// if nil we'll just pull from documents directory inside the catalog controller
var stickerPackListFileURL: URL? {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["REMOTE-STICKERPACKLIST-URL"] as? String { return URL(string:w) }
    return nil
}
}
class MasterViewController: UIViewController {
    let  offColor:UIColor  = UIColor.lightGray
    @IBAction func unwindToMaster(_ segue: UIStoryboardSegue)  {
    }
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    // @IBOutlet weak var orgbbi: UIBarButtonItem!
    @IBOutlet weak var morebbi: UIBarButtonItem!
    @IBOutlet weak var helpbbi: UIBarButtonItem!
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var coloredSpacer: UIView!
    var currentViewController: UIViewController?
    private var showCatalogViewController: UIViewController?
    private var showCaptionedViewController: UIViewController?
    private var showMessagesAppViewController: UIViewController?
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
        
        let catb = UIBarButtonItem(title: nameForLeftBBI, style: .plain, target: self, action: #selector(catalogAction))
        let imessage = 
        UIBarButtonItem(image: UIImage(named: "Msgs"), style: .plain, target: self,action: #selector(imsgAction))
    
        let stickerz = UIBarButtonItem(image: UIImage(named: "History"), style: .plain,
                    target: self, action: #selector(stickerzAction))
        
        
        // start in the catalog
        catb.tintColor = appTheme.catalogColor
        stickerz.tintColor = offColor
        imessage.tintColor = offColor
        helpbbi.tintColor = appTheme.textColor
        morebbi.tintColor = appTheme.textColor
        catb.isEnabled = false
        stickerz.isEnabled = false
        imessage.isEnabled = false
        allBarButtonItems = [catb,imessage,stickerz]
        
        
        self.view.backgroundColor = appTheme.backgroundColor
        self.navigationItem.leftBarButtonItems = [catb]
        self.navigationItem.rightBarButtonItems = [imessage,stickerz]
        let dir = FileManager.default.urls (for: .documentDirectory, in : .userDomainMask)
        let documentsUrl =  dir.first!
        print("-------Running from ",documentsUrl," ---------")
    
        databaseStuff()
        finishStartup()
        
    }// fall straight into it
    private func finishStartup() {
        let vcid = (stickerPackListFileURL != nil) ? "ShowCatalogID" : "ShowITunesID"
        currentViewController = self.storyboard?.instantiateViewController(withIdentifier: vcid )
        currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController( currentViewController!)
        self.addSubview(subView: currentViewController!.view, toView: self.containerView)
        showCatalogViewController =  currentViewController
        currentViewController!.didMove(toParentViewController: self)
        activityIndicatorView.stopAnimating()
        coloredSpacer.backgroundColor = appTheme.catalogColor
        for bbi in allBarButtonItems {
            bbi.isEnabled = true
        }
        if logoNotRemoved {
            logoView.removeFromSuperview()
            logoNotRemoved = false
            coloredSpacer.backgroundColor = appTheme.catalogColor
        }
    }
    //MARK:- Button Tap Handlers
    @IBAction func helpButtonPushed(_ sender: AnyObject) {
        if currentViewController == showCatalogViewController {    performSegue(withIdentifier: "HelpForCatalogSegue", sender: nil) }
        else   if currentViewController == showCaptionedViewController {    performSegue(withIdentifier: "HelpForStickersSegue", sender: nil) }
        else
            if currentViewController == showMessagesAppViewController {    performSegue(withIdentifier: "HelpForMessagesSegue", sender: nil) }
    }
    @IBAction func moreButtonPushed(_ sender: AnyObject) {
        performSegue(withIdentifier: "PerformMoreSegue", sender: nil)
    }
    @IBAction func orgButtonPushed(_ sender: AnyObject) {
        performSegue(withIdentifier: "PerformMoreSegue", sender: nil)
    }
    private func testButtonPushed(_:AnyObject) {
        guard  currentViewController != testButtonViewController ||
            testButtonViewController == nil else  { return }
   
        coloredSpacer.backgroundColor = appTheme.catalogColor
    
        let newViewController = testButtonViewController ?? self.storyboard?.instantiateViewController(withIdentifier: "ShowTestID")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        cycleFromViewController(oldViewController:  currentViewController!, toViewController: newViewController!)
        currentViewController = newViewController
        testButtonViewController = currentViewController
    }
   internal func catalogAction(tis:UIBarButtonItem ) {
        guard  currentViewController != showCatalogViewController ||
            showCatalogViewController == nil else  {  return }
        coloredSpacer.backgroundColor = appTheme.catalogColor
        for bbi in allBarButtonItems {
            bbi.tintColor = bbi == tis ? coloredSpacer.backgroundColor : offColor
        }
        if showCatalogViewController == nil {
            let vcid = (stickerPackListFileURL != nil) ? "ShowCatalogID" : "ShowITunesID"
            let newViewController =  self.storyboard?.instantiateViewController(withIdentifier: vcid )
            newViewController?.view.translatesAutoresizingMaskIntoConstraints = false
            showCatalogViewController = newViewController
        }
        cycleFromViewController(oldViewController:  currentViewController!, toViewController: showCatalogViewController!)
    currentViewController = showCatalogViewController
    self.navigationItem.title = "Candidatez"
    }
    internal  func stickerzAction(tis:UIBarButtonItem) {
        guard  currentViewController != showCaptionedViewController ||
            showCaptionedViewController == nil else  { return }
        coloredSpacer.backgroundColor = appTheme.stickerzColor
        for bbi in allBarButtonItems {
            bbi.tintColor = bbi == tis ? coloredSpacer.backgroundColor : offColor
        }
        let newViewController = showCaptionedViewController ?? self.storyboard?.instantiateViewController(withIdentifier: "CaptionedViewControllerID")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        cycleFromViewController(oldViewController:  currentViewController!, toViewController: newViewController!)
        currentViewController = newViewController
        showCaptionedViewController = currentViewController
        
        self.navigationItem.title = "Caption History"
    }
    internal  func imsgAction(tis:UIBarButtonItem) {
        guard  currentViewController != showMessagesAppViewController || showMessagesAppViewController == nil else  { return }
        coloredSpacer.backgroundColor = appTheme.iMessageColor
        for bbi in allBarButtonItems {
            bbi.tintColor = bbi == tis ? coloredSpacer.backgroundColor : offColor
        }
        let newViewController = showMessagesAppViewController ?? self.storyboard?.instantiateViewController(withIdentifier: "MessageViewControllerID")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        cycleFromViewController(oldViewController: currentViewController!, toViewController: newViewController!)
        currentViewController = newViewController
        showMessagesAppViewController = currentViewController
        
        self.navigationItem.title = "Messages App..."
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
    func addSubview(subView:UIView,toView parentView:UIView) {
        parentView.addSubview(subView)
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",  options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|", options: [], metrics: nil, views: viewBindingsDict))
    }
}
