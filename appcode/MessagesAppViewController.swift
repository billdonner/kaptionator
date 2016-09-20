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

final class MessagesAppViewController: UIViewController   {
    
    var stickerz:[SharedCaptionedEntry] = []
    var theSelectedIndexPath:IndexPath?
    
    @IBOutlet internal  var tableView: UITableView!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // self.showAll = true
    }
    
    @IBAction func unwindToMessagesAppViewController(_ segue: UIStoryboardSegue)  {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        print ("**********removed all cached images because MessagesAppViewController short on memory")
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
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.backgroundColor = appTheme.backgroundColor
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.stickerz = memSpace.items() //entries.map { key, value in return value }
        self.tableView?.reloadData()
    }
    
    func displayTapMenu () {
        // todo: analyze safety of passing indexpath thru, sees to work for now
        performSegue(withIdentifier: "MessagesAppCellTapMenuID", sender: self)
    }
    
}
// MARK: Delegates for actions from our associated menu
extension  MessagesAppViewController:MessagesAppMenuViewDelegate {
    func openinIMessage(captionedEntry:SharedCaptionedEntry) {
        print("MessagesAppEntriesViewController openinIMessage")
        captionedEntry.openinImessage()
    }
    func removeFromIMessage(on captionedEntry:inout SharedCaptionedEntry ){
        print("MessagesAppEntriesViewController removeFromIMessage")
        
        //  let ce =  stickerz.remove(at: indexPath.row)
        let _ =  memSpace.remove(id:captionedEntry.id)
        //  tableView.deleteRows(at: [indexPath], with: .fade)
        memSpace.saveToDisk()
        
        captionedEntry.removeCEFromIMessage()
        self.tableView.reloadData()
    }
}

extension MessagesAppViewController : UITableViewDataSource {
    
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
        memSpace.saveToDisk()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ce =  stickerz.remove(at: indexPath.row)
            let _ =  memSpace.remove(id:ce.id)
            tableView.deleteRows(at: [indexPath], with: .fade)
            memSpace.saveToDisk()
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
        let cell  = tableView.dequeueReusableCell(withIdentifier: "TableDataCell", for: indexPath  ) as! TableDataCell // Create the cell from the storyboard cell
        
        let ce = stickerz [indexPath.row]
        //show the primitive title
        cell.paint(name:ce.caption)
        
        /// go get the image from our cache and then the net
        let path =  ce.localimagepath // ?????
        if path != "" {  // dont crash but dont paint
            //            let t = allImageData[path]
            //            guard let tp = t else {
            //                fatalError("missing data for url path \(path)")
            //            }
            //
            // have the data onhand
            cell.paintImage(path:path)
        }
        cell.colorFor(options: ce.stickerOptions)
        return cell // Return the cell
    }
}// MARK: Observer for model adjustments
extension MessagesAppViewController : MEObserver {
    
    func newdocument(_ propsDict: JSONDict, _ title:String) {
        
//        self.stickerz.removeAll()
//        self.stickerz = [] // reset CAREFUL not [[]]
//        
    }
    func newpack(_ pack: String,_ showsectionhead:Bool) {
        print("**** new pack \(pack)")
    }
    func newentry(me:RemoteAsset){
        
//        let ce = me.convertToCaptionedEntry()
//        self.stickerz.append(ce) // append this
//        
    }
}
extension MessagesAppViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        theSelectedIndexPath = indexPath
        displayTapMenu()
    }
}
extension SharedCaptionedEntry {
    
    fileprivate func openinImessage() {
    }
    fileprivate mutating func removeCEFromIMessage() {
        
        // unhinge the entry
        let _ =  memSpace.remove(id:self.id)
        memSpace.entries[self.id] = nil
        memSpace.saveToDisk()
    }
}
