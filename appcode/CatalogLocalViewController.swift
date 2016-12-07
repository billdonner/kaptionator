//
//  CatalogViewController.swift
//  kaptionator
//
//  Created by bill donner on 8/6/16.
//  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
//
import UIKit


//import stikz
// MARK: Show All Remote Catalog Entries in One Tab as Child ViewContoller
//

final class CatalogLocalView: UICollectionView {
    
   override var intrinsicContentSize: CGSize {
        return self.collectionViewLayout.collectionViewContentSize
    }
  
}
final class CatalogViewController:UIViewController,ControlledByMasterView, UICollectionViewDelegate, UICollectionViewDataSource   {
    
    @IBOutlet weak var collectionView: CatalogLocalView!
    
    @IBAction func unwindToCatalogLocalItemsViewController(_ segue: UIStoryboardSegue)  {}

    func refreshLayout() {
        self.collectionView!.reloadData()
    }
    
    let refreshControl = UIRefreshControl()
    fileprivate var theSelectedIndexPath:IndexPath?
    @IBOutlet weak var startupLogo: UIImageView!
    override func didMove(toParentViewController parent: UIViewController?) {
        self.collectionView!.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView!.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        startupLogo.isHidden = true //
        //startupLogo.image = UIImage(named:backgroundImagePath)
        collectionView.dataSource = self
        collectionView.delegate = self
        StickerAssetSpace.reset(title:extensionScheme)
        
        self.automaticallyAdjustsScrollViewInsets = false
        phase1()
    }
    
    //ITunesCellTapMenuID
    //MARK:- Dispatching to External ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier ==  "CatalogCellTapMenuID",
            let indexPath = theSelectedIndexPath ,
            let avc =  segue.destination as? CatalogMenuViewController   else {
                return
        }
        avc.delegate = self
        avc.stickerAsset = StickerAssetSpace.itemAt(indexPath.row)
        avc.pvc = self
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
                        StickerAssetSpace.saveToDisk()
                        // if good, move on to phase 2 which happens in next view controller
                        self.perform(#selector(self.phase2 ), with: nil, afterDelay: 0.7)
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
            print(">>>>>>>>>> phase3 \(x) LOCAL ASSETS LOADED \(vcid) -- READY TO ROLL")
            self.collectionView.reloadData()
            
            refreshControl.tintColor = .blue
            refreshControl.attributedTitle = NSAttributedString(string:"These are the Sticker images in this pack")
            refreshControl.addTarget(self, action: #selector(self.refreshPulled), for: .valueChanged)
            
            collectionView.addSubview(refreshControl)
            collectionView?.alwaysBounceVertical = true  // needed so always can pull to refresh
            
            // performSegue(withIdentifier: "CatalogTabHelpID", sender: nil)
            
            UIView.animate(withDuration: 1.5,
                           animations: {
                self.startupLogo.alpha =  0.0
               // self.collectionView?.alpha = 1.0
            },
                           completion: { b in
                    self.startupLogo.removeFromSuperview()
            } )
        }
        //MARK: UICollectionViewDataSource
        func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return StickerAssetSpace.itemCount()
        }
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogDataCell", for: indexPath  )
                as! CatalogDataCell // Create the cell from the storyboard cell
            let ra = StickerAssetSpace.itemAt(indexPath.row)
            
            //show the primitive title
            //        if showVendorTitles {
            //            //cell.paint(name:ra.caption)
            //        }
            //else
            if ra.options.contains(.generateasis) {
                cell.showAnimationOverlay()
            }
            // if we have a thumbnail, show that
            if let thumburl = ra.thumburl {
                // have the data onhand
                cell.paintImageCatalogDataCell(url:thumburl,text:ra.assetName)
            } else
                if let imgrul = ra.localurl {
                    // have the data onhand
                    cell.paintImageCatalogDataCell(url:imgrul,text:ra.assetName)
            }
            
            return cell // Return the cell
        }
        
 
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
             collectionView.deselectItem(at: indexPath, animated: true)
            theSelectedIndexPath = indexPath
            // todo: analyze safety of passing indexpath thru, sees to work for now
            //let cell = collectionView.cellForItem(at: indexPath)
            //cell?.isSelected  = false
            //cell?.isHighlighted  = false
            performSegue(withIdentifier: "CatalogCellTapMenuID", sender: self)
        }
        
        // highlighting
        func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)   {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition:[])
        }
        func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)  {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
    }
    
    //MARK:- CALLBACKS
    extension CatalogViewController : CatalogMenuViewDelegate {
        func catUseAsIs(stickerAsset:StickerAsset) {
          
            AppCE.makeNewCaptionCat(from: stickerAsset , caption: stickerAsset.assetName)
            MasterViewController.blurt(title: "Added one image to your catalog",mess: "as is")
            
        }
        func xuseAsIs(stickerAsset:StickerAsset) {
            AppCE.makeNewCaptionCat(from: stickerAsset, caption: stickerAsset.assetName )
        }
 
        func catUseWithCaption(stickerAsset:StickerAsset,caption:String) {
             if !stickerAsset.options.contains(.generateasis) {
            // make un captionated entry from remote asset
            AppCE.makeNewCaptionCat( from: stickerAsset, caption: caption )
            MasterViewController.blurt(title: "Added one image to your catalog",mess: caption)
            }
        }
}
