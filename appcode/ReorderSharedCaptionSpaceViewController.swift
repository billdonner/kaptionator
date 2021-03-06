//
//  ReorderSharedCaptionSpaceViewController
//  kaptionator
//
//  Created by bill donner on 8/6/16.
//  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
//
import UIKit

//import stikz


///
///
// MARK: Reorder Messages in CollectionView Layout
/// this is a modal view controller with no args
/// before returing, it Saves and the caller will Restore from SharedCaptionSpace

class ReorderMessagesReusableView: UICollectionReusableView {
    
   @IBOutlet weak var headerLabel: UILabel!
    
}
protocol ReorderSharedCaptionSpaceDelegate:class {
    func refreshLayout()
}
final class ReorderSharedCaptionSpaceViewController: UICollectionViewController,ModalOverCurrentContext{
   private var theSelectedIndexPath:IndexPath?
    var delegate: ReorderSharedCaptionSpaceDelegate!
    internal func dismisstapped(_ s: AnyObject) {             delegate?.refreshLayout()
            dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshFromMemSpace()
        addDismissButtonToViewController(self , named:appTheme.dismissButtonImageName,#selector(dismisstapped))
    }
    
    //MARK:- Dispatching to External ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
    // only read remote if we have a list
    fileprivate  func refreshFromMemSpace(){
        collectionView?.reloadData()
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        refreshFromMemSpace()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshFromMemSpace()
    }
    
    //MARK: UICollectionViewDataSource
    
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
withReuseIdentifier: "headerforreordercollection",
for: indexPath) as! ReorderMessagesReusableView
            
            headerView.headerLabel.text =
                "These are your stickers currently in Messages. Reorder the stickers here, or delete from the Messages List."
            headerView.headerLabel.textColor = .gray
            headerView.headerLabel.backgroundColor = .clear
            return headerView
        default:
            //4
            fatalError("Unexpected element kind")
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // move your data order
        print("***** moveItem from \(sourceIndexPath) to \(destinationIndexPath) ******")
        SharedCaptionSpace.swap(sourceIndexPath.row,destinationIndexPath.row)
        SharedCaptionSpace.saveData()
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SharedCaptionSpace.itemCount()
    }
    override func collectionView(_ collectionView: UICollectionView,   cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ReorderCollectionViewCell", for: indexPath  ) as! ReorderCollectionViewCell // Create the cell from the storyboard cell
        let ra = SharedCaptionSpace.itemAt(indexPath.row)
       // if showVendorTitles {
            cell.paint(name:ra.caption)
      //  }
        //else
            
            if ra.stickerOptions   .contains(.generateasis) {
            cell.paint(name:"ANIMATED")
        }
            if let url = ra.stickerurl
          {
                // have the data onhand
                cell.paintImageForReorderCollectionViewCell(url:url)
            }
        
        cell.colorFor(ra:ra)
        return cell // Return the cell
    }
    
}
