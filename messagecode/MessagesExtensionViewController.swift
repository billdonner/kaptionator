//
//  MessagesExtensionViewController
//  MessagesExtension
//
//  Created by bill donner on 6/22/16.
//  Copyright © 2016 Bill Donner/ midnightrambler  All rights reserved.
//

import UIKit
import Messages

import stikz


/// this is where sticker files get made, MSstickers get made only in the extension

//MARK:- Singleton StickerPool used by extension only


/// StickerPool is a singleton global struct that is not persisted
//  contains the actual MSStickers used by IOS10 - since these stickers are not movable between the
//  app and the extension, they are generated as needed only in the extension

/// StickerPool is a singleton global struct that is not persisted
//  contains the actual MSStickers used by IOS10 - since these stickers are not movable between the
//  app and the extension, they are generated as needed only in the extension

fileprivate var stickerPool:StickerPool!

struct  StickerPool   {
   fileprivate  var stickers:[MSSticker] = [] {
        
        didSet {
            // print("+++StickerPool now holding \(stickers.count) stickers")
        }
    }
    
    private  mutating func makeMSSticker(url:URL,title: String) {
        print ("&&&&&&&&& Making sticker with \(url) = \(title)")
        let sticker:MSSticker
        do {
            
            try sticker = MSSticker(contentsOfFileURL: url, localizedDescription:  title)
            stickers.append(sticker)
        }
        catch   {
            print("&&&&&&&&& MSSticker(\(url) creation \(error)")
            return
        }
    }
    
    mutating func makeMSStickersFromMemspace() {
        do {
            
            try SharedCaptionSpace.restoreSharespaceFromDisk()
            
            print ("&&&&&&&&& restoreSharespaceFromDisk restored,\(SharedCaptionSpace.itemCount()) items ")
            
            for ce in SharedCaptionSpace.items() {
                //for stickerpath in ce.stickerPath {
                if  let url =  ce.stickerurl {
                let title =  "\(stickers.count)"
                makeMSSticker(url:url,title:title)
                }
                
            }
            
            print ("&&&&&&&&& Total stickers \(SharedCaptionSpace.itemCount())")
        } catch {
            print ("&&&&&&&&& No stickers right now :(")
        }
    }
    mutating func makeMSStickerFromAppIcon() {
        
        let ext = (backgroundImagePath as NSString).pathExtension
        let bar = (backgroundImagePath as NSString).lastPathComponent
        let res = (bar as NSString).deletingPathExtension
        
        let url  =  Bundle.main.url(forResource: res, withExtension: ext)
        
        guard let nurl = url else {
            fatalError("cant find \(backgroundImagePath)")
        }
        do {
            if   let birl = URL(string:backgroundImagePath) {
        let theData = try Data(contentsOf: nurl)
        let options:StickerOptions = .generatemedium
        let stickerurl =   StickerFileFactory.createStickerFileFrom (imageData: theData ,imageurl: birl, caption: "Welcome to \(extensionScheme)", options:options)
            if 
                let stickerurl = stickerurl {
            makeMSSticker(url:stickerurl,title:"Welcome to \(extensionScheme)")
            }
            }
        }
        catch let error {
            print("could not make sticker file \(error)")
        }
            
    }
    mutating func makeMSStickersFromTempFiles() {
        // thru temp file making stickers
        do {
            let documentsUrl =  sharedAppContainerDirectory()
            // if let documentsUrl = documentsUrl {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            
            let _ = directoryContents.map {
                if !$0.absoluteString.hasSuffix("/") { // skip directories
                    let lastpatch = $0.lastPathComponent
                    if !lastpatch.hasPrefix(".")  { // exclude wierd files
                        // $0 has url of file for which to make sticker
                        makeMSSticker(url:$0,title: "\(stickers.count)")
                        
                        // print("********** made ",$0)
                    }}}
            //print ("********** total \(stickers.count)")
        }
        catch {
            print ("&&&&&&&&& couldnt get content of shared docs directory")
        }
    }
    
    init ( ) {
    }
    
}
// MSMessagesAppViewController

 class MessagesExtensionViewController: MSMessagesAppViewController {
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBAction func theButtonTouch(_ sender: AnyObject) {
        openMainAppFromExtension(scheme: extensionScheme)
    }
    @IBOutlet weak var theButton: UIButton!
    
    @IBOutlet weak var zeroItemsLabel: UILabel!  // normally zero
 
    func openMainAppFromExtension (scheme:String) {
        
        let p = "\(scheme)://home"
        let url = URL(string:p)!
        self.extensionContext?.open(url, completionHandler: nil)
        
    }
    
    func resetStickerPool() {
    stickerPool  = StickerPool()
    stickerPool.makeMSStickersFromMemspace()
    print("&&&&&&&&&& makeMSStickersFromMemspace  got ",stickerPool.stickers.count)
    
    /// if we have no stickers its probably because its the first time up
    
    if stickerPool.stickers.count == 0 {
    zeroItemsLabel.isHidden = false
    // make a sticker and add it
    stickerPool.makeMSStickerFromAppIcon()
    } else {
    // hide the label because we have real stickers chosen by user
    zeroItemsLabel.isHidden = true
    }
    }
    
   private func noteToCloud(dict:[String:String]) {  }
    
    private func p(_ s:String) {
        print("&&&&&&&&& ",s)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.topLabel.text = appTitle
        
        // Do any additional setup after loading the view.
        p("messagesviewcontroller viewdidload")
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PassVCToBrowserViewController" {
            if let vc = segue.destination as? SchtickerzBrowserViewController {
                vc.mesExtVC = self
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Conversation Handling

    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
        
//        self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0.1)
//        setupBrowserViewController()
//       browserViewController.loadFromSharedDataSpace()
//        
//        browserViewController.stickerBrowserView.reloadData()
        p("willBecomeActive with \(conversation.localParticipantIdentifier)")
        noteToCloud(dict: ["op":"willBecomeActive", "conversation":"\(conversation.localParticipantIdentifier)"])
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
        
        p("didResignActive with \(conversation)")
    }
    
    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.
        
        // Use this method to trigger UI updates in response to the message.
        self.view.backgroundColor = .red
        
        p("didReceive \(message) with \(conversation)")
        
        noteToCloud(dict: ["op":"didReceive","message":"\(message)","conversation":"\(conversation)"])
    }
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
        
        // whaxky
    
        self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0.5)
        
        p("didStartSending   with \(conversation)")
        noteToCloud(dict: ["op":"didStartSending", "conversation":"\(conversation)"])
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
        
        // Use this to clean up state related to the deleted message.
        
        self.view.backgroundColor = .yellow
        p("didCancelSending   with \(conversation)")
        
        noteToCloud(dict: ["op":"didCancelSending", "conversation":"\(conversation)"])
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
        
        // Use this method to prepare for the change in presentation style.
        
        p("willTransition \(presentationStyle)")
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        
        // Use this method to finalize any behaviors associated with the change in presentation style.
        
        p("didTransition \(presentationStyle)")
    }
    
}
//

extension SchtickerzBrowserViewController { //: MSStickerBrowserViewDataSource {
    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
        let  t = stickerPool.stickers.count
        return t
    }
    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
        return  stickerPool.stickers[index]
    }
}
