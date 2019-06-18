
import UIKit
import CoreLocation
import UserNotifications

class UserInfoTableViewController: UITableViewController {
    
    var userData : UserData?
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = UserData.read() {
            userData = data
            
            let url = URL(string: userData?.pictureUrl ?? "")
            let imageData = try? Data(contentsOf: url!)
            userImage.image = UIImage(data: imageData!)
            userName.text = userData?.name
            userEmail.text = userData?.email
            
        }
        
    }
    
    @IBAction func logout(_ sender: Any) {
        print("logout press")
 
    }
    
    
}
