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
    var pvc:UIViewController! // must be set
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
        
        pvc.dismiss(animated: true) {
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
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
              pvc.dismiss(animated: false) {
                self.pvc.present(vc,animated:true,completion:nil)
            }
        }
        
        
    }
    func dismisstapped(_ s: AnyObject) {
        pvc.dismiss(animated: true, completion: nil)
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
       
        addDismissButtonToViewController(self , named:appTheme.dismissButtonAltImageName,#selector(dismisstapped))
        
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
