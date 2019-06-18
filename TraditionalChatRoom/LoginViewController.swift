
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    var userData: UserData?

    
    @IBAction func unwindSegueToLogin(segue: UIStoryboardSegue){
        //回到登入畫面的unwind segue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("send")
        
    }
    
    @IBAction func btnLoginWithFB(_ sender: Any) {
        let fbLoginManager:FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) {(result, error) in
            if (error == nil){
                let fbLoginResult:FBSDKLoginManagerLoginResult = result!
                if fbLoginResult.grantedPermissions != nil {
                    if(fbLoginResult.grantedPermissions.contains("email")) {
                        self.getFBUserData()
                        self.turnToSecondSreen()
                        //fbLoginManager.logOut()
                    }
                    
                }
            }
        }
    }
    
    
    func turnToSecondSreen() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "second") {
            print("turnToSecondSreen")
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func loginButtonDidLogout(_ loginButton: FBSDKLoginButton!) {
        print("User Logout")
    }
    
    func getFBUserData() {
        
        if(FBSDKAccessToken.current() != nil) {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: {(connection, result, error) -> Void in
                if (error == nil) {
                    print("success")
                    let facebookDic = result as! [String:AnyObject]
                    print(facebookDic)
                    
                    let name = facebookDic["name"] as! String
                    print(name)
                    
                    let email = facebookDic["email"] as! String
                    print(email)
                    
                    let facebookID = facebookDic["id"] as! String
                    print(facebookID)
                    
                    let picture = facebookDic["picture"] as! [String:AnyObject]
                    let pictureData = picture["data"] as! [String:AnyObject]
                    let pictureUrl = pictureData["url"] as! String
                    print(pictureUrl)
                    
                    let facebookAccessToken = FBSDKAccessToken.current()?.tokenString
                    print(facebookAccessToken ?? "null")
                    UserData.save(userData: UserData(name: name, email: email, facebookID: facebookID, pictureUrl: pictureUrl, facebookAccessToken: facebookAccessToken ?? "null"))
                    self.addAccount(facebookAccessToken: facebookAccessToken ?? "null")
                    
                    
                }
                else {
                    print("error")
                    print(error ?? "nothing")
                }
            })
        }
    }
    
    func addAccount(facebookAccessToken: String) {
        do {
            let urlString = "http://140.121.198.84:9600/addAccount?facebook_token="+facebookAccessToken
            print(urlString)
            let urlWithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: urlWithPercentEscapes!)!
            
            let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                if let data = data, let results = try?
                    decoder.decode(ResponseCode.self, from: data)
                {
                    print(results)
                    if(results.code == 200){
                        print("addAccount success")
                    } else {
                        print("addAccount error")
                    }
                    
                } else {
                    print("error")
                }
            }
            
            task.resume()
        }
    }
}

