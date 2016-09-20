//
//  MessagesViewController.swift
//  MessagesExtension
//
//  Created by bill donner on 6/22/16.
//  Copyright © 2016 martoons. All rights reserved.
//

import UIKit
import Messages
/// this is where sticker files get made, stickers get made only in the extension


//MARK:- Singleton StickerPool used by extension only

//MARK:- Singleton StickerPool used by extension only


/// StickerPool is a singleton global struct that is not persisted
//  contains the actual MSStickers used by IOS10 - since these stickers are not movable between the
//  app and the extension, they are generated as needed only in the extension

/// StickerPool is a singleton global struct that is not persisted
//  contains the actual MSStickers used by IOS10 - since these stickers are not movable between the
//  app and the extension, they are generated as needed only in the extension

struct  StickerPool   {
    
    var stickers:[MSSticker] = [] {
        
        didSet {
            // print("+++StickerPool now holding \(stickers.count) stickers")
        }
    }
    
    private  mutating func makeMSSticker(url:URL,title: String) {
        print ("Making sticker with \(url) = \(title)")
        let sticker:MSSticker
        do {
            
            try sticker = MSSticker(contentsOfFileURL: url, localizedDescription:  title)
            stickers.append(sticker)
        }
        catch   {
            print("******** MSSticker(\(url) creation \(error)")
            return
        }
    }
    
    mutating func makeMSStickersFromMemspace() {
        do {
            
            try memSpace.restoreFromDisk()
            
            print ("makeMSStickersFromMemspace memSpace restored,\(memSpace.itemCount()) items ")
            
            for ce in memSpace.items() {
                let url = URL(string:ce.stickerimagepath)!
                let title =  "\(stickers.count)"
                makeMSSticker(url:url,title:title)
            }
            
            print ("Total stickers \(memSpace.itemCount())")
        } catch {
            print ("No stickers right now :(")
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
            print ("couldnt ge content of shared docs directory")
        }
    }
    
    init ( ) {
    }
    
}


 class MessagesViewController: MSMessagesAppViewController {
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBAction func theButtonTouch(_ sender: AnyObject) {
        openMainAppFromExtension(scheme: extensionScheme)
    }
    @IBOutlet weak var theButton: UIButton!
    
 
    func openMainAppFromExtension (scheme:String) {
        
        let p = "\(scheme)://home"
        let url = URL(string:p)!
        print("opening main app")
        self.extensionContext?.open(url, completionHandler: nil)
        
    }
    
    
    func noteToCloud(dict:[String:String]) {
            }
    
    func p(_ s:String) {
        print("++++ ",s)
    }
//    
//    func setupBrowserViewController () {
//        
//        browserViewController = SchtickerzBrowserViewController(stickerSize: .regular)
//        browserViewController.view.frame = self.view.frame
//        
//        self.addChildViewController(browserViewController)
//        browserViewController.didMove(toParentViewController: self)
//        self.view.addSubview(browserViewController.view)
//        browserViewController.changeBrowserViewBackgroundColor(color:self.view.backgroundColor!)
//        // browserViewController.loadStickers()
//      
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topLabel.text = appTitle
        
        // Do any additional setup after loading the view.
        p("messagesviewcontroller viewdidload")
        
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
