import UIKit

class MyCollectionViewCell: UICollectionViewCell {
    var imageView:UIImageView!
    var titleLabel:UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 取得螢幕寬度
        let w = Double(UIScreen.main.bounds.size.width)
        self.backgroundColor = UIColor.white
        // 建立一個 UIImageView!
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: w/2 - 10.0, height: w/2 - 10.0))
        self.addSubview(imageView)
        
        // 建立一個 UILabel
        titleLabel = UILabel(frame:CGRect(x: 0, y: 0, width: w/2 - 10.0, height: 40))
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        titleLabel.backgroundColor = UIColor(white: 1, alpha: 0.5)
        self.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.layer.masksToBounds = true
    }
    
}
