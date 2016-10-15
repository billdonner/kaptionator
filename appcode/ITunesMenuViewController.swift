//
//  ITunesMenuViewController
//  ub ori
//
//  Created by bill donner on 8/24/16.
//  Copyright © 2016 Martoons and MedCommons. All rights reserved.
//

import UIKit
protocol ITunesMenuViewDelegate {
    func useAsIs(remoteAsset:RemoteAsset)
    func useWithCaption(remoteAsset:RemoteAsset,caption:String)
    func useWithNoCaption(remoteAsset:RemoteAsset)
} 
class ITunesMenuViewController: UIViewController,AddDismissButton {
    var mvc:MasterViewController! // must be set
    var remoteAsset:RemoteAsset! // must be set
    var delegate: ITunesMenuViewDelegate?  // mig
    fileprivate var changesMade: Bool = false
    
    @IBAction func unwindToITunesMenuViewController(_ segue: UIStoryboardSegue)  {
    }
    @IBOutlet weak var outerView: UIView!
    
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var imageCaption: UITextField!
    @IBOutlet weak var useasis: UIButton!
    @IBOutlet weak var useasisnocaption: UIButton!
    @IBOutlet weak var addcaption: UIButton!
    
    
    @IBOutlet weak var animatedLabel: UILabel!
    
    @IBAction func useStickerNoCaptionPressed(_ sender: AnyObject) {
        
        mvc.dismiss(animated: true) {
        self.delegate?.useAsIs(remoteAsset:self.remoteAsset) // elsewhere
        }
    }
    @IBAction func addCaptionToSticker(_ sender: AnyObject) {
        imageCaption.textColor = .darkGray
        imageCaption.becomeFirstResponder()
        imageCaption.isHidden = false
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GetCaptionViewControllerID" ) as? GetCaptionViewController
        if let vc = vc {
            vc.delegate = self
            vc.unwinder = "UnwindToITunesAppVC"
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
              mvc.dismiss(animated: true) {
                self.mvc.present(vc,animated:true,completion:nil)
            }
        }
        
        
    }
    func dismisstapped(_ s: AnyObject) {
        mvc.dismiss(animated: true, completion: nil)
    }
    //MARK:- VC LIFECYLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //veryBottomButton.setTitleColor( appTheme.buttonTextColor, for: .normal)
        
//        useasis.setTitleColor(appTheme.buttonTextColor, for: .normal)
        
        useasisnocaption.setTitleColor(appTheme.buttonTextColor, for: .normal)
        addcaption.setTitleColor(appTheme.buttonTextColor, for: .normal)
        
        
        // Do any additional setup after loading the view.
        
        //isAnimated = remoteAsset.options.contains(.generateasis)
        do {
            let data = try  Data(contentsOf: URL(string:remoteAsset.localimagepath )!)
            menuImageView.image = UIImage(data:data)
            menuImageView.contentMode = .scaleAspectFit
        }
        catch {
            menuImageView.image = nil
        }
        imageCaption.isEnabled  = false
        imageCaption.text = showVendorTitles ? remoteAsset.caption : ""
//        imageCaption.delegate = self
//        
//        imageCaption.isHidden = imageCaption.text == ""
//        imageCaption.textColor = .white
//        imageCaption.backgroundColor = .clear
//        
//        imageCaption.keyboardAppearance = .dark
//     
//        if isAnimated {
//            self.menuImageView.isHidden = true
//            self.addcaption.isHidden = true
//            
//            self.useasisnocaption.isHidden = true
//            self.animatedLabel.isHidden = true
//            
//            
//            webViewOverlay = animatedViewOf(frame:self.view.frame, size:menuImageView.image!.size, imageurl: remoteAsset.localimagepath)
//            self.view.addSubview(webViewOverlay!)
//            addDismissButtonToViewController(self , named:appTheme.dismissButtonImageName,#selector(dismisstapped))
//            
//            return
//        }
//        
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

//MARK:- CALLBACKS

extension ITunesMenuViewController : GetCaptionDelegate {
    func captionWasEntered(caption: String) {
        changesMade = true
        delegate?.useWithCaption(remoteAsset: remoteAsset, caption: caption )
        imageCaption.isEnabled  = false
    }
}
