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
            if  let _ = segue.destination as?HelpDropdownViewController {
               // hdvc.pvc = self
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        IO.databaseStuff()
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
