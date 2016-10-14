//
//  CatalogViewController.swift
//  kaptionator
//
//  Created by bill donner on 8/6/16.
//  Copyright © 2016 martoons. All rights reserved.
//
import UIKit
// MARK: Show All Remote Catalog Entries in One Tab as Child ViewContoller
//


final class CatalogViewController: ControlledCollectionViewController {
    @IBAction func unwindToCatalogLocalItemsViewController(_ segue: UIStoryboardSegue)  {}
    
    
    let refreshControl = UIRefreshControl()
    fileprivate var theSelectedIndexPath:IndexPath?
    @IBOutlet weak var startupLogo: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SharedCaptionSpace.itemCount() == 0 && mvc.showFirstHelp {
                mvc.showFirstHelp = false
                performSegue(withIdentifier: "CatalogTabHelpID", sender: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RemSpace.reset(title:extensionScheme)
        
        // put logo in there, we will fade it in
        startupLogo.image = UIImage(named:backgroundImagePath)
        startupLogo.frame = self.view.frame
        startupLogo.center = self.view.center
        self.view.insertSubview(startupLogo, aboveSubview: self.view)
        self.collectionView?.alpha = 0 // start as invisible
        self.automaticallyAdjustsScrollViewInsets = false
        disp()
    }
    private func disp() {
       // print ("Collection view size \(collectionView!.contentSize)")
       // assert( stickerManifestURL != nil)
        //  only read the catalog if we have to
//        do {
//            try RemSpace.restoreRemspaceFromDisk()
//            print("RemSpace restored, \(RemSpace.itemCount()) items")
//            phase2 ()
//        }  catch {
            phase1()
       // }
    }
    //ITunesCellTapMenuID
    //MARK:- Dispatching to External ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "CatalogCellTapMenuID"{
            if let indexPath = theSelectedIndexPath {
                let ra = RemSpace.itemAt(indexPath.row)
                let avc =  segue.destination as? CatalogMenuViewController
                if let avc = avc  {
                    avc.delegate = self
                    avc.remoteAsset = ra
                }
            }
        }
    }
}
extension CatalogViewController {  //loading on first up - moved from masterview controller
    
    func refreshPulled(_ x:AnyObject) {
            refreshControl.endRefreshing()
        }
    
    
    func phase1() {
        // only read remote if we have a list
        if let localResourcesBasedir = localResourcesBasedir {
            
            let mani = //"/" +
            localResourcesBasedir
            //""
 
           // let url =  Bundle.main.url(forResource :"_manifest", withExtension : "json", subdirectory : mani)
            let t = "\(mani)/_manifest.json"
            let url = Bundle.main.bundleURL.appendingPathComponent(t, isDirectory: false)
            
            print(">>>>>>>>>> phase1 Manifest.loadJSONFromLocal \(url)")
            Manifest.loadJSONFromLocal (url:url ) { status, title, allofme in
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
                    RemSpace.saveToDisk()
                    // if good, move on to phase 2 which happens in next view controller
                    self.perform(#selector(self.phase2 ), with: nil, afterDelay: 2.0)
                }
            }
        }
    }
    /// phase2 isnt even started until after
    func phase2() {
        self.phase3()
    }
    func phase3() {
        let vcid =  showCatalogID
        // self.activityIndicatorView.stopAnimating()
        let x = RemSpace.itemCount()
        print(">>>>>>>>>> phase3 \(x) LOCAL ASSETS LOADED \(vcid) -- READY TO ROLL")
        self.collectionView?.reloadData()
        
        refreshControl.tintColor = .blue
        refreshControl.attributedTitle = NSAttributedString(string:"These are the Sticker images in this pack")
        refreshControl.addTarget(self, action: #selector(self.refreshPulled), for: .valueChanged)
        
        collectionView?.addSubview(refreshControl)
        collectionView?.alwaysBounceVertical = true  // needed so always can pull to refresh
       
       // performSegue(withIdentifier: "CatalogTabHelpID", sender: nil)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.startupLogo.alpha =  0.0
            self.collectionView?.alpha = 1.0
            }
            , completion: { b in
                self.startupLogo.removeFromSuperview()
            }
        )
        
       
    }

//MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // if self.refreshControl.isRefreshing { return 0 }
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RemSpace.itemCount()
    }
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogDataCell", for: indexPath  )
            as! CatalogDataCell // Create the cell from the storyboard cell
        let ra = RemSpace.itemAt(indexPath.row)
     
        //show the primitive title
        if showVendorTitles {
            //cell.paint(name:ra.caption)
        }
        else if ra.options.contains(.generateasis) {
             cell.showAnimationOverlay()
        }
        // if we have a thumbnail, show that 
        if ra.thumbnail != "" {
            // have the data onhand
            cell.paintImage(path:ra.thumbnail)
        } else
        if ra.localimagepath != "" {
            // have the data onhand
            cell.paintImage(path:ra.localimagepath)
        }
      
        return cell // Return the cell
    }
 
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        // todo: analyze safety of passing indexpath thru, sees to work for now
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected  = false
        cell?.isHighlighted  = false
        performSegue(withIdentifier: "CatalogCellTapMenuID", sender: self)
    }
    //
 
}
// MARK: Delegates for actions from our associated menu
extension AppCE {
    // not sure we want generate asis so changed back
    fileprivate static func makeNewCaptionCat(   from ra:RemoteAsset, caption:String ) {
        // make captionated entry from remote asset
        do {
            let alreadyIn = SharedCaptionSpace.findMatchingAsset(path: ra.localimagepath, caption: caption)
            if !alreadyIn {
                let options = ra.options
                if caption != "" {
                    let _ = AppCaptionSpace.make (pack: ra.pack, title: ra.caption, imagepath: ra.localimagepath,   caption: caption,  options: options)
                }
                // here make the largest sticker possible and add to shared space
                let _ = try prepareStickers (pack: ra.pack, title: ra.caption, imagepath: ra.localimagepath,   caption: caption,  options: options )  // cakks savetodisk N times - ugh
                SharedCaptionSpace.saveData()
            }else {
                // already in, lets just mark new sizrs and caption
            }
        }
        catch {
            print ("cant make sticker in makenewCaptioncat")
        }
    }
}
extension CatalogViewController : CatalogMenuViewDelegate {
    func useAsIs(remoteAsset:RemoteAsset) {
        AppCE.makeNewCaptionCat(from: remoteAsset, caption: remoteAsset.caption )    }
    func useWithNoCaption(remoteAsset:RemoteAsset) {
        // make un captionated entry from remote asset
        AppCE.makeNewCaptionCat( from: remoteAsset, caption: "" )
    }
    func useWithCaption(remoteAsset:RemoteAsset,caption:String) {
        // make un captionated entry from remote asset
        AppCE.makeNewCaptionCat( from: remoteAsset, caption: caption )
    }
}