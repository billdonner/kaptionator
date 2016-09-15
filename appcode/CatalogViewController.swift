//
//  CatalogViewController.swift
//  kaptionator
//
//  Created by bill donner on 8/6/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

import UIKit


// MARK: Show All Catalog Entries in One Tab as Child ViewContoller
//

final class CatalogViewController: UIViewController  {
    
    @IBAction func unwindToCatalogViewController(_ segue: UIStoryboardSegue)  {
    }
    /// a local cache that holds all remote images whilst we are live
    
    var theSelectedIndexPath:IndexPath?
    
    @IBOutlet internal var collectionView: UICollectionView!
    @IBOutlet fileprivate var flowLayout: UICollectionViewFlowLayout!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // self.showAll = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //allImageData.removeAll()
        //allImageData = [:]
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
        //        if traitCollection.forceTouchCapability == .available {
        //            registerForPreviewing(with: self, sourceView: view)
        //        }
        // continues in viewwillappear
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
        
        cell.paint(name:ra.caption)
        /// go get the image from our cache and then the net
        let path =  ra.localimagepath // ?????
        if path != "" {  // dont crash but dont paint
//            let t = allImageData[path]
//            guard let tp = t else {
//                fatalError("missing data for url path \(path)")
//            }
//            
            // have the data onhand
            cell.paintImage(path:path)
        }
        
        
        cell.colorFor(ra:ra)
        return cell // Return the cell
    }
    
}

//MARK: CacheDelegate for debugging


//MARK: UICollectionViewDelegateFlowLayout incorporates didSelect....
extension CatalogViewController : UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        // todo: analyze safety of passing indexpath thru, sees to work for now
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

//MARK: UIViewControllerPreviewingDelegate for touch
//extension CatalogViewController : UIViewControllerPreviewingDelegate {
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
//        guard let indexPath = collectionView.indexPathForItem(at: collectionView.convert(location, from: view)),
//            let cell = collectionView.cellForItem(at: indexPath) else {
//                return nil
//        }
//
////        let t = remSpace.hdrz.count
////        assert(remSpace.raz.count == t)
////        assert(indexPath.section < t)
//
//        let ra = remSpace.raz [indexPath.row]
//
//        let dvc = storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
//        dvc.item = DataItem(name: ra.caption, population: 0, latitude: 0.0, longitude: 0.0, url: URL(string:ra.imagepath)!)
//        dvc.delegate = self
//        dvc.preferredContentSize = CGSize(width: 0, height: 360)
//        previewingContext.sourceRect = collectionView.convert(cell.frame, to: collectionView.superview!)
//        return dvc
//    }
//
//    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
//        let navigationController = UINavigationController(rootViewController: viewControllerToCommit)
//        show(navigationController, sender: self)
//        // history?.viewed(selectedCounty!)
//    }
//}
//
//MARK: DetailsViewControllerDelegate announces finish
//extension CatalogViewController:DetailsViewControllerDelegate {
//    func detailsViewControllerDidFinish(_ detailsViewController: DetailsViewController){
//
//    }
//}
// MARK: Delegates for actions from our associated menu

extension CaptionedEntry {
    // not sure we want generate asis so changed back
    fileprivate static func makeNewCaption(   from ra:RemoteAsset, caption:String,id:String) {
        // make captionated entry from remote asset
        
        let alreadyIn = capSpace.findMatchingAsset(path: ra.localimagepath, caption: ra.caption)
        if !alreadyIn {
            
        let _ = CaptionedEntry.makeinCapSpace (pack: ra.pack, title: ra.caption, imagepath: ra.localimagepath,   caption: caption,  options: ra.options, id: id)
        capSpace.saveToDisk()
        }
    }
}
extension CatalogViewController : CatalogMenuViewDelegate {
    
    
    func useAsIs(remoteAsset:RemoteAsset,keepCaption:Bool) {
        // make un captionated entry from remote asset
        let caption = keepCaption ? remoteAsset.caption : ""
        CaptionedEntry.makeNewCaption(from: remoteAsset, caption: caption, id: "")
    }
    func useWithCaption(remoteAsset:RemoteAsset,caption:String) {
        
        // make un captionated entry from remote asset
        CaptionedEntry.makeNewCaption( from: remoteAsset, caption: caption, id: "")
        
        
    }
    
}
