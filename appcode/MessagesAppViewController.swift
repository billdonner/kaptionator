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
    
    var stickerz:[SharedCE] = []
    var theSelectedIndexPath:IndexPath?
    
    @IBOutlet internal  var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func unwindToMessagesAppViewController(_ segue: UIStoryboardSegue)  {
        refreshFromMemSpace()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        print ("**********removed all cached images because MessagesAppViewController short on memory")
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        refreshFromMemSpace()
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
    fileprivate  func refreshFromMemSpace(){
        var items = memSpace.items()
        
        // group similar images together in reverse ti
        items.sort(by: { a,b in  let aa = a as SharedCE
            let bb = b as SharedCE
            
            return aa.id > bb.id
            }
        )
        self.stickerz = items
        self.tableView?.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       refreshFromMemSpace()
    }
    
    func displayTapMenu () {
        // todo: analyze safety of passing indexpath thru, sees to work for now
        performSegue(withIdentifier: "MessagesAppCellTapMenuID", sender: self)
    }
    
}
// MARK: Delegates for actions from our associated menu
extension  MessagesAppViewController:MessagesAppMenuViewDelegate {
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
        let line2 = ce.stickerOptions.description()
        cell.paint2(name:ce.caption,line2:line2)
        
        /// go get the image from our cache and then the net
        let path =  ce.stickerPaths[0] // ?????
        if path != "" {  
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
        
//        let ce = me.convertToAppCE()
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
extension SharedCE {
    
    fileprivate func openinImessage() {
    }
    fileprivate mutating func removeCEFromIMessage() {
        let _ =  memSpace.remove(id:self.id)
        memSpace.saveToDisk()
        SharedCaptionSpace.unhinge(id: self.id)
    
    }
}
