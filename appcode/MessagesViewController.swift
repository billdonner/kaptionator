//
//  MessagesViewController
//  kaptionator
//
//  Created by bill donner on 8/6/16.
//  Copyright © 2016 martoons. All rights reserved.
//
import UIKit
//
// MARK: Show All Captionated Entries in One Tab as Child ViewContoller
//
final class MessagesViewController: UIViewController,ControlledByMasterViewController   {
    fileprivate var stickerz:[SharedCE] = []
    fileprivate var theSelectedIndexPath:IndexPath?
    
    var mvc:MasterViewController!
    
    
    let refreshControl = UIRefreshControl()
    
    @IBOutlet internal  var tableView: UITableView!
 
    @IBAction func unwindToMessagesViewController(_ segue: UIStoryboardSegue)  {
        
        self.refreshControl.endRefreshing()
        refreshFromMemSpace()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print ("**********removed all cached images because MessagesViewController short on memory")
    }
 
    //MARK:- Dispatching to External ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "MessagesAppCellTapMenuID"{
            if let indexPath = theSelectedIndexPath {
                if let avc =  segue.destination as? MessagesAppMenuViewController   {
                    avc.delegate = self
                    avc.captionedEntry = stickerz [indexPath.row]
                }
            }}}
    internal func refreshPulled(_ x:AnyObject) {
        
        if stickerz.count > 1 {
        self.performSegue(withIdentifier: "PresentReorder", sender: nil)
            // when controller returns the unwindTo func will call endrefreshing....
        } else {
            refreshControl.endRefreshing()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = appTheme.backgroundColor
        refreshControl.tintColor = .blue
        refreshControl.attributedTitle = NSAttributedString(string:"your Stickers in Messages - swipe to delete or pull to reorder")
        refreshControl.addTarget(self, action: #selector(self.refreshPulled), for: .valueChanged)
        tableView.addSubview(refreshControl)
        tableView.alwaysBounceVertical = true  // needed so always can pull to refresh
    }
    fileprivate  func refreshFromMemSpace(){
        var items = SharedCaptionSpace.items()
        // group similar images together in reverse ti

        items.sort (by: { a,b in  let aa = a as SharedCE
            let bb = b as SharedCE
            return aa.id > bb.id
            }
        )
        
         stickerz = items
         tableView?.reloadData()
        // if two or more items, given user opportunity to sort
        
        //mvc.orgbbi.isEnabled =  items.count > 1
    
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        refreshFromMemSpace()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshFromMemSpace()
        
    }
   fileprivate func displayTapMenu () {
        // todo: analyze safety of passing indexpath thru, sees to work for now
        performSegue(withIdentifier: "MessagesAppCellTapMenuID", sender: self)
    }
}
// MARK: Delegates for actions from our associated menu
extension  MessagesViewController:MessagesAppMenuViewDelegate {
    func openinIMessage(captionedEntry:SharedCE) {
        print("MessagesAppEntriesViewController openinIMessage")
        captionedEntry.openinImessage()
    }
    func removeFromIMessage(on captionedEntry:inout SharedCE ){
        print("MessagesAppEntriesViewController removeFromIMessage")
        captionedEntry.removeCEFromIMessage()
        refreshFromMemSpace()
    }
}
extension MessagesViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        let srcrow = sourceIndexPath.row
//        let dstrow = destinationIndexPath.row
//        // swap thises guys around
//        let stuff = stickerz [srcrow]
//        stickerz [srcrow] = stickerz [dstrow]
//        stickerz [dstrow] = stuff
//        // too much here
//        SharedCaptionSpace.saveData()
//    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ce =  stickerz.remove(at: indexPath.row)
            let _ =  SharedCaptionSpace.remove(id:ce.id)
            tableView.deleteRows(at: [indexPath], with: .fade)
            SharedCaptionSpace.saveData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stickerz.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "MessagesTableCell", for: indexPath  ) as! MessagesTableCell // Create the cell from the storyboard cell
        let ce = stickerz [indexPath.row]
        //show the primitive title
        let line2 = ce.stickerOptions.description()
        cell.paint2(name:ce.caption,line2:line2)
        /// go get the image from our cache and then the net
        let path =  ce.localimagepath
            //ce.stickerPaths[0] // ?????
        if path != "" {
            cell.paintImage(path:path)
        }
        cell.colorFor(options: ce.stickerOptions)
        return cell // Return the cell
    }
}// MARK: Observer for model adjustments
//extension MessagesViewController : MEObserver {
//    func newdocument(_ propsDict: JSONDict, _ title:String) {
//    }
// 
//  
//}
extension MessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        displayTapMenu()
    }
}
extension SharedCE {
    fileprivate func openinImessage() {
    }
    fileprivate mutating func removeCEFromIMessage() {
        let _ =  SharedCaptionSpace.remove(id:self.id)
        SharedCaptionSpace.saveData()
    }
}
