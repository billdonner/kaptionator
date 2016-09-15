//
//  ViewController.swift
//  Re-Kaptionator
//
//  Created by Bill Donner on 15/12/2015.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {
    
var stickerPackListFileURL: URL? {
get {
    if let iDict = Bundle.main.infoDictionary ,
        let w =  iDict["REMOTE-STICKERPACKLIST-URL"] as? String { return URL(string:w) }
    return nil
}
}
    
   let  offColor:UIColor  = UIColor.lightGray
    @IBAction func unwindToMaster(_ segue: UIStoryboardSegue)  {
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var buttonChooser: UISegmentedControl!
    
    @IBOutlet weak var helpbbi: UIBarButtonItem!
    @IBAction func buttonAction(_ sender: AnyObject) {
    }
    @IBOutlet weak var logoView: UIImageView!
    
  //  @IBOutlet weak var buttonCatalog: UIButton!
    
 //   @IBOutlet weak var buttonCaptioned: UIButton!
    
  //  @IBOutlet weak var buttonMessagesApp: UIButton!
    
    @IBOutlet weak var coloredSpacer: UIView!
 
    var currentViewController: UIViewController?
    var showCatalogViewController: UIViewController?
    var showCaptionedViewController: UIViewController?
    var showMessagesAppViewController: UIViewController?
    var testButtonViewController: UIViewController?

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
        let catb = UIBarButtonItem(title: "Candidatez", style: .plain, target: self, action: #selector(catalogAction))
        let stickerz = UIBarButtonItem(title: "Stickerz", style: .plain, target: self, action: #selector(stickerzAction))
        let imessage = UIBarButtonItem(title: "Messages", style: .plain, target: self, action: #selector(imsgAction))
        // start in the catalog
                catb.tintColor = appTheme.catalogColor
                stickerz.tintColor = offColor
                imessage.tintColor = offColor
        helpbbi.tintColor = appTheme.textColor
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
        //  only read the catalog if we have to
        do {
            try remSpace.restoreFromDisk()
            print("remSpace restored, \(remSpace.itemCount()) items")
            phase2 ()
        }  catch {
            phase1()
        }
        
    }// direct access
    
    //MARK:- Button Tap Handlers
    @IBAction func helpButtonPushed(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "PresentHelpSegue", sender: nil)
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

        let newViewController = showCatalogViewController ?? self.storyboard?.instantiateViewController(withIdentifier: "ShowCatalogID")
        
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController
        showCatalogViewController = currentViewController
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

extension MasterViewController : MEObserver {
    func newdocument(_ propsDict: JSONDict, _ title:String) {
         remSpace.reset()
        remSpace.catalogTitle = title
    }
    func newpack(_ pack: String,_ showsectionhead:Bool) {
        //print("**** new pack \(pack)")
        //remSpace.addhdr(s: pack) // adds new section
    }
    func newentry(me:RemoteAsset){
        //remSpace.addasset(ra: me)
    }
}
extension MasterViewController {
    
    func phase1() {
        print(">>>>>>>>>> phase1 Manifest.loadFromRemoteJSON")
        Manifest.loadFromRemoteJSON (url: stickerPackListFileURL! , observer: self) { status, title, allofme in
            
            // at this point the observer callbacks have been called so the data is ready for redisplay on the main q
            DispatchQueue.main.async  {
                guard status == 200 else {
                    print("Put up alertview for status \(status)")
                    
                    IOSSpecialOps.blurt(self,title: "Network error code = \(status)",mess: "Please ensure you have an Internet Connection"){
                        // on restart, run phase1 again
                        self.phase1()
                    }
                    return
                }
                remSpace.saveToDisk()
                // if good, move on to phase 2 which happens in next view controller
                self.perform(#selector(self.phase2 ), with: nil, afterDelay: 2.0)
            }
        }
    }
    
    /// phase2 isnt even started until after
    func phase2() {
        self.phase3()
    }
    func phase3() {
        self.currentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ShowCatalogID")
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.currentViewController!)
        self.addSubview(subView: self.currentViewController!.view, toView: self.containerView)
        self.showCatalogViewController = self.currentViewController
 
        self.activityIndicatorView.stopAnimating()
        let x = remSpace.itemCount()
        print(">>>>>>>>>> phase3 \(x) REMOTE ASSETS LOADED -- READY TO ROLL")

        coloredSpacer.backgroundColor = .yellow
 
        for bbi in self.navigationItem.leftBarButtonItems! {
            bbi.isEnabled = true
        }
        
        
        self.logoView.removeFromSuperview()
        
        //
        
        coloredSpacer.backgroundColor = appTheme.catalogColor
    }
}
