 //
 //  CapationatedViewController
 //  kaptionator
 //
 //  Created by bill donner on 8/6/16.
 //  Copyright © 2016 martoons. All rights reserved.
 //
 
 import UIKit
 //
 // MARK: Show All Captionated Entries in One Tab as Child ViewContoller
 //
 
 final class CapationatedViewController: UIViewController   {
    
    var stickerz:[AppCE] = []
    var theSelectedIndexPath:IndexPath?
    
    @IBOutlet internal  var tableView: UITableView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // self.showAll = true
    }
    
    @IBAction func unwindToCapationatedViewController(_ segue: UIStoryboardSegue)  {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print ("**********removed all cached images because CapationatedEntriesViewController short on memory")
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        refreshFromCapSpace()
    }
    @IBAction func cellwzswiped(_ swipe: UISwipeGestureRecognizer) {
        
        let location = swipe.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: location)
        if let indexPath = indexPath {
            theSelectedIndexPath = indexPath
            var  captionedEntry = stickerz[indexPath.row]
            captionedEntry.moveToIMessage()
            let cell = tableView.cellForRow(at: indexPath) as! TableDataCell
            cell.twinkle()
            print ("cellwzswiped \(indexPath)")
        }
        
    }
    //MARK:- Dispatching to External ViewControllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier ==  "CaptionedCellTapMenuID"{
            if let indexPath = theSelectedIndexPath {
                if let avc =  segue.destination as? CaptionedMenuViewController  {
                    avc.delegate = self
                    avc.captionedEntry = stickerz [indexPath.row]               // pull image from cache and pass
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.backgroundColor = appTheme.backgroundColor
        
        
    }
    func refreshFromCapSpace(){
        var items = capSpace.items()
        
        // group similar images together in reverse ti
        items.sort(by: { a,b in  let aa = a as AppCE
            let bb = b as AppCE
            
//            if aa.id < bb.id && aa.localimagepath != bb.localimagepath {
//                return aa.id < bb.id
//            }
//            if aa.localimagepath == bb.localimagepath {
                return aa.id > bb.id
//            }
//            return aa.localimagepath < bb.localimagepath
            }
       )
        self.stickerz = items
        // 5 filter items down according to this tab's needs
        self.tableView?.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshFromCapSpace()
        
    }
    
    func displayTapMenu () {
        // todo: analyze safety of passing indexpath thru, sees to work for now
        performSegue(withIdentifier: "CaptionedCellTapMenuID", sender: self)
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
            let _ =  capSpace.remove(id:ce.id)
            tableView.deleteRows(at: [indexPath], with: .fade)
            capSpace.saveToDisk()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    //    @objc(tableView:editActionsForRowAtIndexPath:) func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //
    //        let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "More", handler:{action, indexpath in
    //            print("MORE•ACTION");
    //        });
    //        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
    //
    //        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
    //            print("DELETE•ACTION");
    //        });
    //
    //        return [deleteRowAction, moreRowAction];
    //    }
    
    
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
        capSpace.saveToDisk()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stickerz.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "TableDataCell", for: indexPath  ) as! TableDataCell // Create the cell from the storyboard cell
        
        let ce = stickerz [indexPath.row]
        //show the primitive title
        let showname = ce.caption 
        let line2 = ce.stickerOptions.description()
        cell.paint(name:showname,line2:line2)
        
        /// go get the image from our cache and then the net
        let path =  ce.localimagepath // ?????
        if path != "" {  // dont crash but dont paint
            //        let t = allImageData[path]
            //        guard let tp = t else {
            //            fatalError("missing data for url path \(path)")
            //        }
            //
            // have the data onhand
            cell.paintImage(path:path)
        }
        
        cell.colorFor(options: ce.stickerOptions)
        return cell // Return the cell
    }
 }
 // MARK:  UICollectionViewDataSource runs in local space
 
 // MARK: Observer for model adjustments
 extension CapationatedViewController : MEObserver {
    
    func newdocument(_ propsDict: JSONDict, _ title:String) {
        
        self.stickerz.removeAll()
        self.stickerz = [] // reset CAREFUL not [[]]
        
    }
    func newpack(_ pack: String,_ showsectionhead:Bool) {
        print("**** new pack \(pack)")
    }
    func newentry(me:RemoteAsset){
        
        let ce = me.convertToAppCE()
        self.stickerz.append(ce) // append this
        
    }
 }
 extension CapationatedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        displayTapMenu()
    }
 }
 ///

 extension AppCE {
    
    fileprivate   mutating func changeCaption(to caption:String) {
        let alreadyIn = capSpace.findMatchingAsset(path: self.localimagepath, caption: caption)
        if !alreadyIn {
            // keep old and
           AppCaptionSpace.unhinge(id:self.id) //remove old
        // make new with new caption but all else is similar
        let _ = AppCaptionSpace.make( pack: self.catalogpack, title: self.catalogtitle, imagepath: self.localimagepath, caption: caption, options: self.stickerOptions, id: self.id)
        }
     
        //
    }
    
    
    fileprivate func cloneWithNewCaption(_ caption:String){
        
        let alreadyIn = capSpace.findMatchingAsset(path: self.localimagepath, caption: caption)
        if !alreadyIn {
        // keep old and make another
        let _ = AppCaptionSpace.make( pack: self.catalogpack, title: self.catalogtitle, imagepath: self.localimagepath,  caption: caption,  options: self.stickerOptions, id:"")
        }
    }
    
    fileprivate mutating func moveToIMessage() { // only from capspace
        // duplicate and save to other space under same id, as is
        
        // if there is something in there with same file and caption then forget it
        let alreadyIn = memSpace.findMatchingAsset(path: self.localimagepath, caption: self.caption)
        if !alreadyIn {
            do {
                let theData = try Data(contentsOf: URL(string:self.localimagepath)!)
                let stickerurl =   stickerFileFactory.createStickerFileFrom (imageData: theData ,captionedEntry:self)
                
                print("made sticker file urls \(stickerurl)")
                
                // ce.localimagepath = url.absoluteString // dink with this
                let _ = SharedCaptionSpace.make( pack: self.catalogpack, title: self.catalogtitle, imagepath: self.localimagepath, stickerpath: stickerurl.absoluteString ,  caption: self.caption,  options: self.stickerOptions, id:"")// self.id)
                // users newce.id to CLONE, the old item will get unhinged
              
            }
            catch {
                print("could not makemade sticker file urls \(localimagepath)")
            }
        }
    }
 }
