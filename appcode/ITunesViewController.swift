//
//  ITunesViewController
//  kaptionator
//
//  Created by bill donner on 8/6/16.
//  Copyright © 2016 martoons. All rights reserved.
//

import UIKit


// MARK: Show LocalItunes Document Entries in One Tab as Child ViewContoller
//

final class ITunesViewController :ControlledCollectionViewController {
    
    @IBAction func unwindToITunesViewController(_ segue: UIStoryboardSegue)  {
    }
    
    let refreshControl = UIRefreshControl()
    fileprivate var theSelectedIndexPath:IndexPath?
    
    @IBOutlet weak var startupLogo: UIImageView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print ("**********removed all cached images because CatalogViewController short on memory")
    }
    
    //MARK:- Dispatching to External ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier ==  "ITunesCellTapMenuID"{
            if let indexPath = theSelectedIndexPath {
                let ra = RemSpace.itemAt(indexPath.row)
                let avc =  segue.destination as? ITunesMenuViewController
                if let avc = avc  {
                    avc.delegate = self
                    avc.remoteAsset = ra
                    avc.pvc = self
                }
            }
        }
    }
    
    //MARK:- Lifecyle for ViewControllers
      /// load from shared documents in itune (must be on in info.plist)
        private func loadFromITunesSharing(   completion:GFRM?) {
        //let iTunesBase = manifestFromDocumentsDirector
        // store file locally into catalog
        // var first = true
        let apptitle = "-local-"
        var allofme:ManifestItems = []
        do {
            let dir = FileManager.default.urls (for:  .documentDirectory, in: .userDomainMask)
            let documentsUrl =  dir.first!
            
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            let _ =  try directoryContents.map {
                let lastpatch = $0.lastPathComponent
                if !lastpatch.hasPrefix(".") { // exclude wierd files
                    let imagename = lastpatch
                    
                    if (lastpatch as NSString).pathExtension.lowercased() == "json" {
                        let data = try Data(contentsOf: $0) // read
                        Manifest.parseData(data, baseURL: documentsUrl.absoluteString, completion: completion!)
                    } else {
                 // copy from documents area into a regular local file
                        
                        
                        let localpath = $0
                        let me = RemoteAsset(pack: "apptitle", title: imagename, thumb:"", remoteurl: localpath.absoluteString,  localpath:nil, options:
                            .generatemedium)
                        
                        RemSpace.addasset(ra: me) // be sure to coun
                        allofme.append(me)                     }
                    
                // finally, delete the file
                try FileManager.default.removeItem(at: $0)
                }
            }
            
            RemSpace.saveToDisk()
            if completion != nil  {
                completion! (200, apptitle, allofme)
            }
        }
        catch {
            print("loadFromITunesSharing: file system error \(error)")
            
            self.refreshControl.endRefreshing()
        }
            
    }
    func refreshFromITunes() {
        loadFromITunesSharing( completion: { status, title, allofme in
            print(" refreshed with \(allofme.count) items")
            self.collectionView!.reloadData()
            self.refreshControl.endRefreshing()
            
        })
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if SharedCaptionSpace.itemCount() == 0 && mvc.showFirstHelp {
            mvc.showFirstHelp = false
            mvc.performSegue(withIdentifier: "StartupHelpID", sender: nil)
        }
    }
    override func viewDidLoad() {
        self.collectionView!.backgroundColor = appTheme.backgroundColor
        super.viewDidLoad()
        collectionView!.delegate = self
        collectionView!.dataSource = self
        
        // put logo in there, we will fade it in
        startupLogo.image = UIImage(named:backgroundImagePath)
        startupLogo.frame = self.view.frame
           // CGRect(x:0,y:0,width:self.view.frame.width, height:self.view.frame.height)
          startupLogo.center = self.view.center
        self.view.insertSubview(startupLogo, aboveSubview: self.view)
        self.collectionView?.alpha = 0 // start as invisible
        self.automaticallyAdjustsScrollViewInsets = false
        refreshControl.tintColor = .blue
        refreshControl.attributedTitle = NSAttributedString(string:"pulling fresh content from Itunes file sharing")
        refreshControl.addTarget(self, action: #selector(self.refreshFromITunes), for: .valueChanged)
        collectionView!.addSubview(refreshControl)
        collectionView!.alwaysBounceVertical = true  // needed so always can pull to refresh
        
        //  only read the catalog if we have to
        
        assert( stickerManifestURL == nil)
        do {
            try RemSpace.restoreRemspaceFromDisk()
            print("remSpace restored, \(RemSpace.itemCount()) items")
        }  catch {
             print("could not restore remspace")
        }
      // refreshFromITunes()
        UIView.animate(withDuration: 1.5, animations: {
            self.startupLogo.alpha =  0.0
            self.collectionView?.alpha = 1.0
            }
            , completion: { b in
                self.startupLogo.removeFromSuperview()
            }
        )
    }
// UICollectionViewDataSource {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // if self.refreshControl.isRefreshing { return 0 }
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return RemSpace.itemCount()
    }
    override func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ITunesDataCell", for: indexPath  ) as! ITunesDataCell // Create the cell from the storyboard cell
        
        let ra = RemSpace.itemAt(indexPath.row)
        if ra.localimagepath != "" {
            // have the data onhand
            cell.paintImage(path:ra.localimagepath)
        }
        //cell.colorFor(ra:ra)
        return cell // Return the cell
    }
    
 
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        // todo: analyze safety of passing indexpath thru, sees to work for now
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.isSelected  = false
        cell?.isHighlighted  = false
        performSegue(withIdentifier: "ITunesCellTapMenuID", sender: self)
    }
    

}

extension ITunesViewController : ITunesMenuViewDelegate {
    func useAsIs(remoteAsset:RemoteAsset) {
        AppCE.makeNewCaptionAsIs(from: remoteAsset )       }
    func useWithNoCaption(remoteAsset:RemoteAsset) {
        // make un captionated entry from remote asset
        AppCE.makeNewCaptionCat( from: remoteAsset, caption: "" )
    }
    func useWithCaption(remoteAsset:RemoteAsset,caption:String) {
        // make un captionated entry from remote asset
        AppCE.makeNewCaptionCat( from: remoteAsset, caption: caption )
    }
}
