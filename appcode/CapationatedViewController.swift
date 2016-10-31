 //
 //  CapationatedViewController
 //  kaptionator
 //
 //  Created by bill donner on 8/6/16.
 //  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
 //
 import UIKit
 //
 // MARK: Show All Captionated Entries in One Tab as Child ViewContoller
 //
 final class CapationatedViewController: UIViewController,ControlledByMasterView {
   
    fileprivate  var stickerz:[AppCE] = []
    fileprivate var theSelectedIndexPath:IndexPath?
    @IBOutlet internal  var tableView: UITableView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // self.showAll = true
    }
    @IBAction func unwindToCapationatedViewController(_ segue: UIStoryboardSegue)  {
        refreshFromCapSpace()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print ("**********removed all cached images because CapationatedEntriesViewController short on memory")
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        refreshFromCapSpace()
    }
    //MARK:- Dispatching to External ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ==  "CaptionedCellTapMenuID"{
            if let indexPath = theSelectedIndexPath {
                if let avc =  segue.destination as? CaptionedMenuViewController  {
                    avc.delegate = self
                    avc.captionedEntry = stickerz [indexPath.row]               // pull image from cache and pass
                    avc.pvc = self
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = appTheme.backgroundColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshFromCapSpace()
    }

 }
private  extension CapationatedViewController {
      func displayTapMenu () {
        // todo: analyze safety of passing indexpath thru, sees to work for now
        performSegue(withIdentifier: "CaptionedCellTapMenuID", sender: self)
    }
    func refreshFromCapSpace(){
        var items = AppCaptionSpace.items()
        // group similar images together in reverse time, newest first
        items.sort(by: { a,b in  let aa = a as AppCE
            let bb = b as AppCE
            return aa.id > bb.id
        }
        )
        stickerz = items
        tableView?.reloadData()
    }
 }
 // MARK: Delegates for actions from our associated menu
 extension CapationatedViewController : CaptionedMenuViewDelegate {
    func cloneWithCaption(captionedEntry:  AppCE, caption: String) {
        print("CapationatedEntriesViewController cloneWithCaption")
        captionedEntry.cloneWithNewCaption(  caption)
        tableView.reloadData()
    }
    func movetoIMessage(captionedEntry:inout AppCE){
        print("CapationatedEntriesViewController movetoimessage")
        captionedEntry.moveToIMessage()
    }
    func changeCaption( on captionedEntry:inout AppCE, caption:String){
        print("CapationatedEntriesViewController changeCaption")
        captionedEntry.changeCaption(to: caption)
        tableView.reloadData()
    }
 }
 extension CapationatedViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ce =  stickerz.remove(at: indexPath.row)
            let _ =  AppCaptionSpace.remove(id:ce.id)
            tableView.deleteRows(at: [indexPath], with: .fade)
            AppCaptionSpace.saveToDisk()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let srcrow = sourceIndexPath.row
        let dstrow = destinationIndexPath.row
        // swap thises guys around
        let stuff = stickerz [srcrow]
        stickerz [srcrow] = stickerz [dstrow]
        stickerz [dstrow] = stuff
        // too much here
        AppCaptionSpace.saveToDisk()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stickerz.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "CaptionedTableCell", for: indexPath  ) as! CaptionedTableCell // Create the cell from the storyboard cell
        let ce = stickerz [indexPath.row]
        //show the primitive title
        let showname = ce.caption 
        cell.paint(name:showname)
        /// go get the image from our cache and then the net
        let path =  ce.localimagepath // ?????
        if path != "" {
            // dont crash but dont paint
            // have the data onhand
            cell.paintImage(path:path)
        }
        cell.colorFor(options: ce.stickerOptions)
        return cell // Return the cell
    }
 }
 // MARK:  UICollectionViewDataSource runs in local space
 // MARK: Observer for model adjustments
// extension CapationatedViewController : MEObserver {
//    func newdocument(_ propsDict: JSONDict, _ title:String) {
//        stickerz.removeAll()
//        stickerz = [] // reset CAREFUL not [[]]
//    }
// 
//    func newentry(me:RemoteAsset){
//        let ce = me.convertToAppCE()
//        stickerz.append(ce) // append this
//    }
// }
 extension CapationatedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        displayTapMenu()
    }
 }
