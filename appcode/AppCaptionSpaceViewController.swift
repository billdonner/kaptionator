 //
 //  AppCaptionSpaceViewController
 //  kaptionator
 //
 //  Created by bill donner on 8/6/16.
 //  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
 //
 import UIKit
 
 //import stikz
 
 //
 // MARK: Show All Captionated Entries in One Tab as Child ViewContoller
 //
 final class AppCaptionSpaceViewController: UIViewController,   ControlledByMasterView {
    
    fileprivate  var stickerz:[AppCE] = []
    fileprivate var theSelectedIndexPath:IndexPath?
    @IBOutlet internal  var tableView: UITableView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // self.showAll = true
    }
    @IBAction func unwindToAppCaptionSpaceViewController(_ segue: UIStoryboardSegue)  {
        refreshFromCapSpace()
    }
    
    
    func refreshLayout() {
        self.tableView!.reloadData()
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
        guard segue.identifier ==  "CaptionedCellTapMenuID" ,
            let indexPath = theSelectedIndexPath ,
            let avc =  segue.destination as? AppSpaceMenuViewController  else {
                return
        }
        avc.delegate = self
        avc.captionedEntry = stickerz [indexPath.row]               // pull image from cache and pass
        avc.pvc = self
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
        if AppCaptionSpace.itemCount() == 0 {
            masterViewController?.performSegue(withIdentifier: "NoHistoryContentID", sender: self)
        }
    }
 }
 
 private  extension AppCaptionSpaceViewController {
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
 extension AppCaptionSpaceViewController : AppSpaceMenuDelegate {
    func cloneWithCaption(captionedEntry:  AppCE, caption: String) {
        print("CapationatedEntriesViewController cloneWithCaption")
        captionedEntry.cloneWithNewCaption(  caption)
        tableView.reloadData()
    }
    func movingtoIMessage(captionedEntry:inout AppCE){
        print("CapationatedEntriesViewController movingtoIMessage")
        captionedEntry.cemoveToIMessage()
    }
    //    func changingCaption( on captionedEntry:inout AppCE, caption:String){
    //        print("CapationatedEntriesViewController changingCaption")
    //        captionedEntry.changeCaptionForAppCE(to: caption)
    //        tableView.reloadData()
    //    }
 }
 extension AppCaptionSpaceViewController : UITableViewDataSource {
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
        cell.paint(name:ce.caption)
        /// go get the image from our cache and then the net
        
        cell.paintImageForCaptionedTableCell(url: ce.imageurl  )
        
        cell.colorFor(options: ce.stickerOptions)
        return cell // Return the cell
    }
 }
 // MARK:  UICollectionViewDataSource runs in local space
 // MARK: Observer for model adjustments
 
 extension AppCaptionSpaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        displayTapMenu()
    }
 }
