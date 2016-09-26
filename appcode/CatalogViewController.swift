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

 
final class CatalogViewController: UIViewController  {
    
    //let refreshControl = UIRefreshControl()
    @IBAction func unwindToCatalogViewController(_ segue: UIStoryboardSegue)  {
    }
    
    var theSelectedIndexPath:IndexPath?
    
    @IBOutlet weak var startupLogo: UIImageView!
    @IBOutlet internal var collectionView: UICollectionView!
    @IBOutlet fileprivate var flowLayout: UICollectionViewFlowLayout!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print ("**********removed all cached images because CatalogViewController short on memory")
    }
    
    //MARK:- Dispatching to External ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier ==  "CatalogCellTapMenuID"{
            if let indexPath = theSelectedIndexPath {
                let ra = remSpace.itemAt(indexPath.row)
                let avc =  segue.destination as? CatalogMenuViewController
                if let avc = avc  {
                    avc.delegate = self
                    avc.remoteAsset = ra
                }
            }
        }
    }
    
    
    //MARK:- Lifecyle for ViewControllers
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        if styleForTraitCollection(newCollection) != styleForTraitCollection(traitCollection) {
            collectionView.reloadData() // Reload cells to adopt the new style
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if styleForTraitCollection(traitCollection) == .table {
            flowLayout.invalidateLayout() // Called to update the cell sizes to fit the new collection view width
        }
    }
    
    override func viewDidLoad() {
            self.collectionView.backgroundColor = appTheme.backgroundColor
            super.viewDidLoad()
            collectionView.delegate = self
            collectionView.dataSource = self
        collectionView.alpha = 0 // start as invisible
        
        assert( stickerPackListFileURL != nil)
            //  only read the catalog if we have to
            do {
                try remSpace.restoreRemspaceFromDisk()
                print("remSpace restored, \(remSpace.itemCount()) items")
                phase2 ()
            }  catch {
                phase1()
            }
        }
 
}
//MARK: UICollectionViewDataSource
extension CatalogViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // if self.refreshControl.isRefreshing { return 0 }
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return remSpace.itemCount()
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ModelDataCell", for: indexPath  ) as! ModelDataCell // Create the cell from the storyboard cell
        
        let ra = remSpace.itemAt(indexPath.row)
        
        //show the primitive title
        if showVendorTitles {
        cell.paint(name:ra.caption)
        } else if ra.options.contains(.generateasis) {
            cell.paint(name:"ANIMATED")
        }
        
        
        if ra.localimagepath != "" {
            // have the data onhand
            cell.paintImage(path:ra.localimagepath)
        }
        cell.colorFor(ra:ra)
        return cell // Return the cell
    }
}
//MARK: UICollectionViewDelegateFlowLayout incorporates didSelect....
extension CatalogViewController : UICollectionViewDelegateFlowLayout {
    
    //    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
    //        return false
    //    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        // todo: analyze safety of passing indexpath thru, sees to work for now
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected  = false
        cell?.isHighlighted  = false
        performSegue(withIdentifier: "CatalogCellTapMenuID", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return styleForTraitCollection(traitCollection).itemSizeInCollectionView(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return styleForTraitCollection(traitCollection).collectionViewEdgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return styleForTraitCollection(traitCollection).collectionViewLineSpacing
    }
    
}
// MARK: Delegates for actions from our associated menu
extension AppCE {
    // not sure we want generate asis so changed back
    fileprivate static func makeNewCaptionCat(   from ra:RemoteAsset, caption:String ) {
        // make captionated entry from remote asset
do {
        let alreadyIn = memSpace.findMatchingAsset(path: ra.localimagepath, caption: caption)
        if !alreadyIn {
            let options = ra.options
          
            if caption != "" {
            let _ = AppCaptionSpace.make (pack: ra.pack, title: ra.caption, imagepath: ra.localimagepath,   caption: caption,  options: options)
            }
            // here make the largest sticker possible and add to shared space
            let _ = try prepareStickers (pack: ra.pack, title: ra.caption, imagepath: ra.localimagepath,   caption: caption,  options: options )
            
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



extension CatalogViewController : MEObserver {
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
extension CatalogViewController {  //loading on first up - moved from masterview controller
    
    func phase1() {
        
        // only read remote if we have a list
        
        if stickerPackListFileURL != nil {
            print(">>>>>>>>>> phase1 Manifest.loadFromRemoteJSON \(stickerPackListFileURL)")
            Manifest.loadFromRemoteJSON (url: stickerPackListFileURL  , observer: self) { status, title, allofme in
                
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
    }
    
    /// phase2 isnt even started until after
    func phase2() {
        self.phase3()
    }
    func phase3() {
        let vcid =  "ShowCatalogID"
        
       // self.activityIndicatorView.stopAnimating()
        let x = remSpace.itemCount()
        print(">>>>>>>>>> phase3 \(x) REMOTE ASSETS LOADED \(vcid) -- READY TO ROLL")
        self.collectionView.reloadData()
//        
//        coloredSpacer.backgroundColor = appTheme.catalogColor
//        
//        for bbi in self.navigationItem.leftBarButtonItems! {
//            bbi.isEnabled = true
//        }
//        
//        if logoNotRemoved {
//            self.logoView.removeFromSuperview()
//            logoNotRemoved = false
//            
//            //
//            
//            coloredSpacer.backgroundColor = appTheme.catalogColor
//        }
    
    UIView.animate(withDuration: 1.5, animations: {
    self.startupLogo.alpha =  0.0
        self.collectionView.alpha = 1.0
    }
    , completion: { b in
    self.startupLogo.removeFromSuperview()
    }
        )
    }
}



