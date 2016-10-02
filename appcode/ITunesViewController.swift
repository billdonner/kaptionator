//
//  ITunesViewController
//  kaptionator
//
//  Created by bill donner on 8/6/16.
//  Copyright © 2016 martoons. All rights reserved.
//

import UIKit


// MARK: Show All Remote Catalog Entries in One Tab as Child ViewContoller
//

final class ITunesViewController : UIViewController  {
    
//},ControlledByMasterViewController  {
//    
//    let refreshControl = UIRefreshControl()
//    @IBAction func unwindToITunesViewController(_ segue: UIStoryboardSegue)  {
//    }
//    
//    var theSelectedIndexPath:IndexPath?
//    
//    @IBOutlet internal var collectionView: UICollectionView!
//    
//    @IBOutlet fileprivate var flowLayout: UICollectionViewFlowLayout!
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        
//        print ("**********removed all cached images because CatalogViewController short on memory")
//    }
//    
//    //MARK:- Dispatching to External ViewControllers
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier ==  "ITunesCellTapMenuID"{
//            if let indexPath = theSelectedIndexPath {
//                let ra = remSpace.itemAt(indexPath.row)
//                let avc =  segue.destination as? ITunesMenuViewController
//                if let avc = avc  {
//                    avc.delegate = self
//                    avc.remoteAsset = ra
//                }
//            }
//        }
//    }
//    
//    //MARK:- Lifecyle for ViewControllers
//    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.willTransition(to: newCollection, with: coordinator)
//        if styleForTraitCollection(newCollection) != styleForTraitCollection(traitCollection) {
//            collectionView.reloadData() // Reload cells to adopt the new style
//        }
//    }
//    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        if styleForTraitCollection(traitCollection) == .table {
//            flowLayout.invalidateLayout() // Called to update the cell sizes to fit the new collection view width
//        }
//    }
//    /// load from shared documents in itune (must be on in info.plist)
//        private func loadFromITunesSharing( observer:MEObserver?, completion:GFRM?) {
//        //let iTunesBase = manifestFromDocumentsDirector
//        // store file locally into catalog
//        // var first = true
//        let apptitle = "-local-"
//        
//        var allofme:ManifestItems = []
//        
//        observer?.newdocument([:], "-local-")
//        
//        observer?.newpack(apptitle,false)
//        do {
//            let dir = FileManager.default.urls (for:  .documentDirectory, in: .userDomainMask)
//            let documentsUrl =  dir.first!
//            
//            // Get the directory contents urls (including subfolders urls)
//            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
//            let _ =  try directoryContents.map {
//                let lastpatch = $0.lastPathComponent
//                if !lastpatch.hasPrefix(".") { // exclude wierd files
//                    let imagename = lastpatch
//                    // let part1 = image.components(separatedBy: ".")
//                    // let part2 = part1[0].components(separatedBy: "-")
//                    // let part3 = part2[0].components(separatedBy: "/")
//                    
//                    if (lastpatch as NSString).pathExtension.lowercased() == "json" {
//                        let data = try Data(contentsOf: $0) // read
//                        Manifest.parseData(data, baseURL: documentsUrl.absoluteString, completion: completion!)
//                    } else {
//                 // copy from documents area into a regular local file
//                        
//                        
//                        let localpath = $0
//                        let me = RemoteAsset(pack: "apptitle", title: imagename, remoteurl: "", localpath: localpath.absoluteString, options:
//                            // generateasis is a bit of a problem
//                            
//                            .generatemedium)
//                        
//                        
//                        remSpace.addasset(ra: me) // be sure to coun
//                        allofme.append(me)
//                        //observer?.newentry(me: me)
//                    }
//                }
//            }
//            if completion != nil  {
//                completion! (200, apptitle, allofme)
//            }
//        }
//        catch {
//            print("loadFromITunesSharing: cant get directory \(error)")
//        }
//    }
//    func refreshFromITunes() {
//        
//        print("    func refreshFromITunes() pulled ")
//        
//        loadFromITunesSharing(observer:self,completion: { status, title, allofme in
//            print(" refreshed with \(allofme.count) items")
//            self.collectionView.reloadData()
//            self.refreshControl.endRefreshing()
//        })
//    }
//    override func viewDidLoad() {
//        self.collectionView.backgroundColor = appTheme.backgroundColor
//        super.viewDidLoad()
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        
//        refreshControl.tintColor = .blue
//        refreshControl.attributedTitle = NSAttributedString(string:"pulling fresh content from Itunes file sharing")
//        refreshControl.addTarget(self, action: #selector(self.refreshFromITunes), for: .valueChanged)
//        collectionView.addSubview(refreshControl)
//        collectionView.alwaysBounceVertical = true  // needed so always can pull to refresh
//        
//        //  only read the catalog if we have to
//        
//        assert( stickerManifestURL == nil)
//        do {
//            try remSpace.restoreRemspaceFromDisk()
//            print("remSpace restored, \(remSpace.itemCount()) items")
//        }  catch {
//             print("could not restore remspace")
//        }
//       refreshFromITunes()
//    }
}
//MARK: UICollectionViewDataSource
//extension ITunesViewController : UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        // if self.refreshControl.isRefreshing { return 0 }
//        return 1
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return remSpace.itemCount()
//    }
//    func collectionView(_ collectionView: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogDataCell", for: indexPath  ) as! CatalogDataCell // Create the cell from the storyboard cell
//        
//        let ra = remSpace.itemAt(indexPath.row)
//        
//        //show the primitive title
//      
//            cell.paint(name:ra.caption)
//     
//        if ra.localimagepath != "" {
//            // have the data onhand
//            cell.paintImage(path:ra.localimagepath)
//        }
//        cell.colorFor(ra:ra)
//        return cell // Return the cell
//    }
//    
//}
////MARK: UICollectionViewDelegateFlowLayout incorporates didSelect....
//extension ITunesViewController : UICollectionViewDelegateFlowLayout {
//    
//    //    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
//    //        return false
//    //    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        theSelectedIndexPath = indexPath
//        // todo: analyze safety of passing indexpath thru, sees to work for now
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.isSelected  = false
//        cell?.isHighlighted  = false
//        performSegue(withIdentifier: "ITunesCellTapMenuID", sender: self)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return styleForTraitCollection(traitCollection).itemSizeInCollectionView(collectionView)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return styleForTraitCollection(traitCollection).collectionViewEdgeInsets
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return styleForTraitCollection(traitCollection).collectionViewLineSpacing
//    }
//    
//}
//// MARK: Delegates for actions from our associated menu
//extension AppCE  {
//    // not sure we want generate asis so changed back
//    fileprivate static func makeNewCaptionITunes(   from ra:RemoteAsset, caption:String,id:String) {
//        // make captionated entry from remote asset
//        
//        let alreadyIn = AppCaptionSpace.findMatchingAsset(path: ra.localimagepath, caption: caption)
//        if !alreadyIn {
//            let _ = AppCaptionSpace.make (pack: ra.pack, title: ra.caption, imagepath: ra.localimagepath,   caption: caption,  options: ra.options)
//        }
//    }
//}
//
//extension ITunesViewController : ITunesMenuViewDelegate {
//    
//    
//    func useAsIs(remoteAsset:RemoteAsset) {
//        AppCE.makeNewCaptionITunes(from: remoteAsset, caption: remoteAsset.caption , id: "")
//    }
//    func useWithNoCaption(remoteAsset:RemoteAsset) {
//        // make un captionated entry from remote asset
//        AppCE.makeNewCaptionITunes( from: remoteAsset, caption: "", id: "")
//    }
//    func useWithCaption(remoteAsset:RemoteAsset,caption:String) {
//        // make un captionated entry from remote asset
//        AppCE.makeNewCaptionITunes( from: remoteAsset, caption: caption, id: "")
//    }
//}
//
//
//extension ITunesViewController : MEObserver {
//    func newdocument(_ propsDict: JSONDict, _ title:String) {
//        remSpace.reset()
//        remSpace.catalogTitle = title
//    }
//    func newpack(_ pack: String,_ showsectionhead:Bool) {
//        //print("**** new pack \(pack)")
//        //remSpace.addhdr(s: pack) // adds new section
//    }
//    func newentry(me:RemoteAsset){
//        remSpace.addasset(ra: me)
//    }
//}
