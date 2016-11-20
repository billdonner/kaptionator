//
//  CatalogViewController.swift
//  kaptionator
//
//  Created by bill donner on 8/6/16.
//  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
//
import UIKit

import stikz

// MARK: Show All Remote Catalog Entries in One Tab as Child ViewContoller
//


final class CatalogRemoteViewController:UIViewController,ControlledByMasterView, UserInteractionSignalDelegate,UICollectionViewDelegate, UICollectionViewDataSource  {

    @IBOutlet weak var collectionView: UICollectionView!
    
@IBAction func unwindToCatalogItemsViewControlle(_ segue: UIStoryboardSegue)  {}
    
    func backToCallerAndDismiss () {// can go directly back
        masterViewController?.dismiss(animated: true, completion: nil)
    }
    
    func refreshLayout() {
        self.collectionView!.reloadData()
    }
    
    let refreshControl = UIRefreshControl()
    fileprivate var theSelectedIndexPath:IndexPath?
    @IBOutlet weak var startupLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        StickerAssetSpace.reset(title:extensionScheme)
        
        // put logo in there, we will fade it in
        startupLogo.image = UIImage(named:backgroundImagePath)
        startupLogo.frame = self.view.frame
        startupLogo.center = self.view.center
        self.view.insertSubview(startupLogo, aboveSubview: self.view)
        self.collectionView.alpha = 0 // start as invisible
        self.automaticallyAdjustsScrollViewInsets = false
        disp()
    }
    private func disp() {
        //print ("Collection view size \(collectionView!.contentSize)")
        assert( stickerManifestURL != nil)
        //  only read the catalog if we have to
        do {
            try StickerAssetSpace.restoreStickerAssetsFromDisk()
            print("StickerAssetSpace restored, \(StickerAssetSpace.itemCount()) items")
            phase2 ()
        }  catch {
            phase1()
        }
    }
    //MARK:- Dispatching to External ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "CatalogCellTapMenuID"{
            if let indexPath = theSelectedIndexPath {
                let ra = StickerAssetSpace.itemAt(indexPath.row)
                let avc =  segue.destination as? CatalogMenuViewController
                if let avc = avc  {
                    avc.delegate = self
                    avc.stickerAsset = ra
                    avc.pvc = self
                }
            }
        }
    }
}
/// secret message to gary

extension CatalogRemoteViewController {  //loading on first up - moved from masterview controller
    
    func refreshPulled(_ x:AnyObject) {
            refreshControl.endRefreshing()
        }
    
    
    func phase1() {
        // only read remote if we have a list
        if stickerManifestURL != nil {
            print(">>>>>>>>>> phase1 Manifest.loadJSONFromURL \(stickerManifestURL)")
            Manifest.loadJSONFromURL (url: stickerManifestURL  ) { status, title, allofme in
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
                    StickerAssetSpace.saveToDisk()
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
        let x = StickerAssetSpace.itemCount()
        print(">>>>>>>>>> phase3 \(x) REMOTE ASSETS LOADED \(vcid) -- READY TO ROLL")
        self.collectionView.reloadData()
        
        refreshControl.tintColor = .blue
        refreshControl.attributedTitle = NSAttributedString(string:"These are the Sticker images in this pack")
        refreshControl.addTarget(self, action: #selector(self.refreshPulled), for: .valueChanged)
        
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true  // needed so always can pull to refresh
        
        UIView.animate(withDuration: 1.5, animations: {
            self.startupLogo.alpha =  0.0
            self.collectionView.alpha = 1.0
            }
            , completion: { b in
                self.startupLogo.removeFromSuperview()
            }
        )
    }
//MARK: UICollectionViewDataSource

    @objc(numberOfSectionsInCollectionView:) func numberOfSections(in collectionView: UICollectionView) -> Int {
        // if self.refreshControl.isRefreshing { return 0 }
        return 1
    }
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StickerAssetSpace.itemCount()
    }
     @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogDataCell", for: indexPath  )
            as! CatalogDataCell // Create the cell from the storyboard cell
        let ra = StickerAssetSpace.itemAt(indexPath.row)
 
        if ra.options.contains(.generateasis) {
             cell.showAnimationOverlay()
        }
        // if we have a thumbnail, show that 
        if let thumburl = ra.thumburl {
            // have the data onhand
            cell.paintImageCatalogDataCell(url: thumburl)
        } else
        if let imurl = ra.localurl {
            // have the data onhand
            cell.paintImageCatalogDataCell(url:imurl)
        }
      
        return cell // Return the cell
    }
 
     @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        // todo: analyze safety of passing indexpath thru, sees to work for now
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected  = false
        cell?.isHighlighted  = false
        performSegue(withIdentifier: "CatalogCellTapMenuID", sender: self)
    }
    //
     }

extension CatalogRemoteViewController : CatalogMenuViewDelegate {
    func useAsIs(stickerAsset:StickerAsset) {
        AppCE.makeNewCaptionAsIs(from: stickerAsset )    }
//    func zuseWithNoCaption(stickerAsset:StickerAsset) {
//        // make un captionated entry from remote asset
//        AppCE.makeNewCaptionCat( from: stickerAsset, caption: "" )
//    }
    func useWithCaption(stickerAsset:StickerAsset,caption:String) {
        // make un captionated entry from remote asset
        AppCE.makeNewCaptionCat( from: stickerAsset, caption: caption )
    }
}
