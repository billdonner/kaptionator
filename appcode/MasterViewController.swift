//
//  ViewController.swift
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
    

    @IBOutlet weak var orgbbi: UIBarButtonItem!
    @IBOutlet weak var morebbi: UIBarButtonItem!
    
    @IBOutlet weak var helpbbi: UIBarButtonItem!
    
    @IBOutlet weak var logoView: UIImageView!

    @IBOutlet weak var coloredSpacer: UIView!
    
    var currentViewController: UIViewController?
    var showCatalogViewController: UIViewController?
    var showCaptionedViewController: UIViewController?
    var showMessagesAppViewController: UIViewController?
    var testButtonViewController: UIViewController?
    var logoNotRemoved = true 
    var bbis :[UIBarButtonItem] = []
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let _  = segue.destination as?
            HelpOverlayViewController {
            //detailsViewController.presentingViewController?
            self.modalPresentationStyle = .overCurrentContext
        }
    }
    
    //MARK:- Lifecyle for ViewControllers
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        //  topStackLine.isHidden = newCollection.verticalSizeClass == .compact
        if styleForTraitCollection(newCollection) != styleForTraitCollection(traitCollection) {
            // // Reload cells to adopt the new style
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        //         topStackLine.isHidden = traitCollection.verticalSizeClass == .compact
        //
        //        if styleForTraitCollection(traitCollection) == .table {
        //           // flowLayout.invalidateLayout() // Called to update the cell sizes to fit the new collection view width
        //        }
    }
    //Changing Status Bar
    
    //    override var preferredStatusBarStyle: UIStatusBarStyle {
    //        return appTheme.statusBarStyle
    //    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.prompt = appTitle // global
        let catb = UIBarButtonItem(title: nameForLeftBBI, style: .plain, target: self, action: #selector(catalogAction))
        let stickerz = UIBarButtonItem(title: "Stickerz", style: .plain, target: self, action: #selector(stickerzAction))
        let imessage = UIBarButtonItem(title: "Messages", style: .plain, target: self, action: #selector(imsgAction))
        // start in the catalog
        catb.tintColor = appTheme.catalogColor
        stickerz.tintColor = offColor
        imessage.tintColor = offColor
        helpbbi.tintColor = appTheme.textColor
        morebbi.tintColor = appTheme.textColor
               orgbbi.tintColor = appTheme.textColor
        
        self.view.backgroundColor = appTheme.backgroundColor
        catb.isEnabled = false
        stickerz.isEnabled = false
        imessage.isEnabled = false
        let lhbutts = [catb,stickerz,imessage]
        self.navigationItem.leftBarButtonItems = lhbutts
        self.bbis = lhbutts
        let dir = FileManager.default.urls (for: .documentDirectory, in : .userDomainMask)
        let documentsUrl =  dir.first!
        print("-------Running from ",documentsUrl," ---------")
        super.viewDidLoad()
        // restore or create captions db
        if let _ = try? capSpace.restoreFromDisk() {
            
            print ("capSpace restored,\(capSpace.itemCount()) items ")
        } else { // nothing there
            capSpace.reset()
        }
        capSpace.saveToDisk()
        // restore or create shared memspace db for messages extension
        if let _ = try? memSpace.restoreFromDisk() {
            
            print ("memSpace restored,\(memSpace.itemCount()) items ")
        } else { // nothing there
            memSpace.reset()
        }
        memSpace.saveToDisk()
        
        finishStartup()
 
}// direct access
    func finishStartup() {
        let vcid = (stickerPackListFileURL != nil) ? "ShowCatalogID" : "ShowITunesID"
        self.currentViewController = self.storyboard?.instantiateViewController(withIdentifier: vcid )
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(subView: self.currentViewController!.view, toView: self.containerView)
        self.showCatalogViewController = self.currentViewController
        
        self.activityIndicatorView.stopAnimating()
   
        coloredSpacer.backgroundColor = appTheme.catalogColor
        
        for bbi in self.navigationItem.leftBarButtonItems! {
            bbi.isEnabled = true
        }
        
        if logoNotRemoved {
            self.logoView.removeFromSuperview()
            logoNotRemoved = false
            
            //
            
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
func testButtonPushed(_:AnyObject) {
    
    guard  currentViewController != testButtonViewController ||
        testButtonViewController == nil else  {
            return
    }
    // highLightButton(button: buttonTest)
    
    coloredSpacer.backgroundColor = appTheme.catalogColor
    // buttonTest.setTitleColor(.orange,for: .normal)
    let newViewController = testButtonViewController ?? self.storyboard?.instantiateViewController(withIdentifier: "ShowTestID")
    
    newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
    self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
    self.currentViewController = newViewController
    
    testButtonViewController = currentViewController
}

func catalogAction(tis:UIBarButtonItem ) {
    guard  currentViewController != showCatalogViewController ||
        showCatalogViewController == nil else  {
            return
    }
    
    coloredSpacer.backgroundColor = appTheme.catalogColor
    
    for bbi in self.navigationItem.leftBarButtonItems! {
        bbi.tintColor = bbi == tis ? coloredSpacer.backgroundColor : offColor
    }
    if showCatalogViewController == nil {
        
        let vcid = (stickerPackListFileURL != nil) ? "ShowCatalogID" : "ShowITunesID"
        
        let newViewController =  self.storyboard?.instantiateViewController(withIdentifier: vcid )
        newViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        
        showCatalogViewController = newViewController
    }
    
    self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: showCatalogViewController!)
    self.currentViewController = showCatalogViewController 
}


func stickerzAction(tis:UIBarButtonItem) {
    
    guard  currentViewController != showCaptionedViewController ||
        showCaptionedViewController == nil else  {
            return
    }
    
    coloredSpacer.backgroundColor = appTheme.stickerzColor
    
    for bbi in self.navigationItem.leftBarButtonItems! {
        bbi.tintColor = bbi == tis ? coloredSpacer.backgroundColor : offColor
    }
    let newViewController = showCaptionedViewController ?? self.storyboard?.instantiateViewController(withIdentifier: "CaptionedViewControllerID")
    
    newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
    self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
    self.currentViewController = newViewController
    showCaptionedViewController = currentViewController
}


func imsgAction(tis:UIBarButtonItem) {
    guard  currentViewController != showMessagesAppViewController || showMessagesAppViewController == nil else  {
        return
    }
    
    coloredSpacer.backgroundColor = appTheme.iMessageColor
    
    for bbi in self.navigationItem.leftBarButtonItems! {
        bbi.tintColor = bbi == tis ? coloredSpacer.backgroundColor : offColor
    }
    let newViewController = showMessagesAppViewController ?? self.storyboard?.instantiateViewController(withIdentifier: "MessageViewControllerID")
    
    newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
    self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
    self.currentViewController = newViewController
    
    showMessagesAppViewController = currentViewController
}
// from segmented control


//MARK:- move between view controllers
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

func beginSearch() {
    //searchBar.becomeFirstResponder()
}

}
