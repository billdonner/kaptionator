//
//  ITunesViewController
//  kaptionator
//
//  Created by bill donner on 8/6/16.
//  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
//

import UIKit

//import stikz
// MARK: Show LocalItunes Document Entries in One Tab as Child ViewContoller
//

final class ITunesViewController :UIViewController,ControlledByMasterView, UICollectionViewDelegate, UICollectionViewDataSource   {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func unwindToITunesViewController(_ segue: UIStoryboardSegue)  {}
    
    
    
    func refreshLayout() {
        self.collectionView!.reloadData()
    }
    
    let refreshControl = UIRefreshControl()
    fileprivate var theSelectedIndexPath:IndexPath?
    
    @IBOutlet weak var startupLogo: UIImageView!
    
    //MARK:- Dispatching to External ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier ==  "ITunesCellTapMenuID" ,
            let indexPath = theSelectedIndexPath ,
            let avc =  segue.destination as? ITunesMenuViewController else {
                return }
        avc.delegate = self
        avc.stickerAsset =  StickerAssetSpace.itemAt(indexPath.row)
        avc.pvc = self
    }

//MARK:- Lifecyle for ViewControllers
/// load from shared documents in itune (must be on in info.plist)

internal func refreshFromITunes() {
    Manifest.loadFromITunesSharing( completion: { status, title, allofme in
        print(" refreshed with \(allofme.count) items")
        self.collectionView!.reloadData()
        self.refreshControl.endRefreshing()
    })
}
internal func refresher() {
    self.refreshControl.endRefreshing()
}
override func didMove(toParentViewController parent: UIViewController?) {
    self.collectionView!.reloadData()
}
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.collectionView!.reloadData()
    if StickerAssetSpace.itemCount() == 0 {
        masterViewController?.performSegue(withIdentifier: "NoITunesContentID", sender: self)
    }
    
}
override func viewDidLoad() {
    self.collectionView.backgroundColor = appTheme.backgroundColor
    super.viewDidLoad()
    collectionView.delegate = self
    collectionView.dataSource = self
    
    let img = UIImage(named:backgroundImagePath)
    startupLogo.image = img
    self.automaticallyAdjustsScrollViewInsets = false
    refreshControl.tintColor = .blue
    refreshControl.attributedTitle =
        NSAttributedString(string:"your Catalog of Images - select to add captions and move into Messages app")
    refreshControl.addTarget(self, action: #selector(self.refresher ), for: .valueChanged)
    collectionView.addSubview(refreshControl)
    collectionView.alwaysBounceVertical = true  // needed so always can pull to refresh
    
    //  only read the catalog if we have to
    
    assert( stickerManifestURL == nil)
    do {
        try StickerAssetSpace.restoreStickerAssetsFromDisk()
        print("remSpace restored, \(StickerAssetSpace.itemCount()) items")
    }  catch {
        print("could not restore remspace")
    }
    
    
    // refreshFromITunes()
    UIView.animate(withDuration: 1.5, animations: {
        // self.startupLogo.alpha =  0.0
        self.collectionView.alpha = 1.0
    }
        , completion: { b in
            //   self.startupLogo.removeFromSuperview()
            
            
            
    }
    )
}
// UICollectionViewDataSource {
func numberOfSections(in collectionView: UICollectionView) -> Int {
    // if self.refreshControl.isRefreshing { return 0 }
    return 1
}
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return StickerAssetSpace.itemCount()
}
func collectionView(_ collectionView: UICollectionView,
                    cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ITunesDataCell", for: indexPath  ) as! ITunesDataCell // Create the cell from the storyboard cell
    
    let ra = StickerAssetSpace.itemAt(indexPath.row)
    if let imgurl = ra.localurl {
        // have the data onhand
        cell.paintImageForITunesDataCell(url:imgurl,text:ra.assetName)
    }
    if ra.options.contains(.generateasis) {
        cell.showAnimationOverlay()
    }
    cell.isSelected = false
    return cell // Return the cell
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    theSelectedIndexPath = indexPath
    // todo: analyze safety of passing indexpath thru, sees to work for now
    let cell = collectionView.cellForItem(at: indexPath)
    cell?.isSelected  = false
    cell?.isHighlighted  = false
    performSegue(withIdentifier: "ITunesCellTapMenuID", sender: self)
}
}

extension ITunesViewController : ITunesMenuViewDelegate {
    
    func changedAnimationState(stickerAsset:StickerAsset){
        // all the work has been done, just refresh
        self.collectionView.reloadData()
    }
    func asIsUse (stickerAsset:StickerAsset) {
        AppCE.makeNewCaptionAsIs(from: stickerAsset )
        MasterViewController.blurt(title: "Added one image to your catalog",mess: "as is")
    }
    func deleteAsset(stickerAsset:StickerAsset) {
        MasterViewController.ask(title: "Are you sure?",mess: "You will have to reload the image to restore") {
            StickerAssetSpace.remove(ra: stickerAsset)
            self.collectionView.reloadData()
            StickerAssetSpace.saveToDisk()
            MasterViewController.blurt(title: "Removed from catalog",mess: "")
        }
    }
    //    func xuseWithNoCaption(stickerAsset:StickerAsset) {
    //        // make un captionated entry from remote asset
    //        AppCE.makeNewCaptionCat( from: stickerAsset, caption: "" )
    //        MasterViewController.blurt(title: "Added one image to your catalog",mess: "no caption")
    //    }
    func capUse(stickerAsset:StickerAsset,caption:String) {
        // make un captionated entry from remote asset
        AppCE.makeNewCaptionCat( from: stickerAsset, caption: caption )
        MasterViewController.blurt(title: "Added one image to your catalog",mess: caption)
    }
}
