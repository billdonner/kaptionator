//
//  MessagesTableCell
//  Kaptionator
//
//  Created by bill donner on 9/12/16.
//  Copyright © 2016 Bill Donner/midnightrambler. All rights reserved.
//
import UIKit
class MessagesTableCell: UITableViewCell {
    @IBOutlet  fileprivate weak var detailsImageView: UIImageView!
    @IBOutlet  fileprivate weak var nameLabel: UILabel!
    @IBOutlet  fileprivate weak var line2Label: UILabel!
    override func prepareForReuse() {
        detailsImageView.image = nil // clean this out
        nameLabel.text = ""
        line2Label.text = ""
    }
    func colorFor(options:StickerMakingOptions) {
        let  isAnimated = options.contains(.generateasis)
        nameLabel.textColor = isAnimated ? appTheme.redColor : appTheme.textColor
    }
    // methods to adjust cell contents
    func paint2(ce:SharedCE,line2:String ) {
        let line1 = ce.caption != "" ? ce.caption : "<no caption>"
        if ce.stickerOptions.contains(.generateasis) {
            nameLabel.text =  "-this is an animated image and can not have a caption-"
            nameLabel.font = UIFont.systemFont(ofSize: 12)
        } else {
            nameLabel.text = line1
            nameLabel.textColor = appTheme.textColor
        }
        line2Label.text = line2
        line2Label.textColor = appTheme.textColor
    }
    func paint(name:String ) {
        nameLabel.text = name
        nameLabel.textColor = appTheme.textColor
    }
    func paintImage(path: String) {
        do {
            let data =  try Data(contentsOf: URL(string:path)!)
            let img = UIImage(data:data)
            if let img = img {
                detailsImageView.image = img
            }
        }
        catch let error {
            print("Cant paint image in messages table vc, \(error)")
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay() // Redraw the border
    }
}
