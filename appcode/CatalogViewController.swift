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
final class CatalogViewController: UICollectionViewController {
    @IBAction func unwindToCatalogItemsViewControlle(_ segue: UIStoryboardSegue)  {
    }
    var theSelectedIndexPath:IndexPath?
    @IBOutlet weak var startupLogo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // put logo in there, we will fade it in
        startupLogo.frame = self.view.frame
        startupLogo.center = self.view.center
        self.view.insertSubview(startupLogo, aboveSubview: self.view)
        self.collectionView?.alpha = 0 // start as invisible
        self.automaticallyAdjustsScrollViewInsets = false
        disp()
    }
    private func disp() {
        print ("Collection view size \(collectionView!.contentSize)")
        assert( stickerPackListFileURL != nil)
        //  only read the catalog if we have to
        do {
            try RemSpace.restoreRemspaceFromDisk()
            print("RemSpace restored, \(RemSpace.itemCount()) items")
            phase2 ()
        }  catch {
            phase1()
        }
    }
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
/// secret message to gary

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
        let vcid =  "ShowCatalogID"
        // self.activityIndicatorView.stopAnimating()
        let x = RemSpace.itemCount()
        print(">>>>>>>>>> phase3 \(x) REMOTE ASSETS LOADED \(vcid) -- READY TO ROLL")
        self.collectionView?.reloadData()
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
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogDataCell", for: indexPath  ) as! CatalogDataCell // Create the cell from the storyboard cell
        let ra = RemSpace.itemAt(indexPath.row)
        //print("cell at \(indexPath.row) is sized \(cell.frame.size)")
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

//MARK: UICollectionViewDelegateFlowLayout incorporates didSelect....
//: UICollectionViewDelegateFlowLayout {
    //UICollectionViewDelegateFlowLayout
    //    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
    //        return false
    //    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        // todo: analyze safety of passing indexpath thru, sees to work for now
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected  = false
        cell?.isHighlighted  = false
        performSegue(withIdentifier: "CatalogCellTapMenuID", sender: self)
    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //
    //        let traitCollection = collectionView.traitCollection
    //
    //        if traitCollection.verticalSizeClass == .regular &&
    //            traitCollection.horizontalSizeClass == .regular {
    //            return CGSize(width: 250, height: 250) //ipad
    //        }
    //        if traitCollection.verticalSizeClass == .compact &&
    //            traitCollection.horizontalSizeClass == .regular {
    //            return CGSize(width: 200, height: 200) //7plus in landscape
    //        }
    //        return CGSize(width: 150, height: 150) //iphone vert
    //    }
    //    // CGSize(width:4, height:4)
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //        return CGFloat(4)
    //    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    //        return CGSize.zero
    //    }
    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    //        return CGSize.zero
    //    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //
    //        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    //    }
    //    //
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    //        return 8
    //    }
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
extension CatalogViewController : MEObserver {
    func newdocument(_ propsDict: JSONDict, _ title:String) {
        RemSpace.reset(title:title)
    }
    func newpack(_ pack: String,_ showsectionhead:Bool) {
        //print("**** new pack \(pack)")
        //remSpace.addhdr(s: pack) // adds new section
    }
    func newentry(me:RemoteAsset){
        //remSpace.addasset(ra: me)
    }
}
