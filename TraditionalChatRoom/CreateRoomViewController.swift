

import UIKit

class CreateRoomViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate{
    let imagePicker = UIImagePickerController()
    var userData : UserData?
    var base64image :String?
    var info:[ResponseCode]?
    var roomResult : [RoomCode]?
    @IBOutlet weak var roomName: UITextField!
    @IBOutlet weak var roomImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePicker.delegate = self
        roomName.delegate = self
        /*do{
            try FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("roomInfo").appendingPathExtension("plist"))
            try FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("rooms").appendingPathExtension("plist"))
        }catch{
            
        }*/
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func choosePicture(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    
    func requestWithJSONBody(urlString: String, parameters: [String: Any]){
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions())
        }catch let error{
            print(error)
        }
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        fetchedDataByDataTask(from: request)
    }
    private func fetchedDataByDataTask(from request: URLRequest){
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil{
                print(error as Any)
            }else{
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let data = data, let results = try?
                    decoder.decode(ResponseCode.self, from: data)
                {
                    print(results)
                    if(results.code == 200){
                        
                        print("createRoom success")
                        if let rooms = ResponseCode.loadFromFile(){
                            self.info = rooms
                        }
                        self.info?.append(results)
                        ResponseCode.saveToFile(rooms: self.info ?? [results])
                        let controller = UIAlertController(title: "房間密碼", message: results.message, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        controller.addAction(okAction)
                        self.present(controller, animated: true, completion: nil)
                        self.getInfo(password: results.message)
                       
                        
                    } else {
                        print("createRoom error")
                        let controller = UIAlertController(title: "創立房間", message: "新建失敗", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        controller.addAction(okAction)
                        self.present(controller, animated: true, completion: nil)
                    }
                    
                } else {
                    print("error")
                }
            }
        }
        task.resume()
    }
    @IBAction func createRoom(_ sender: Any) {
        print("createRoom")
        if let data = UserData.read() {
            userData = data
            let info = ["access_token": userData?.facebookAccessToken ?? "null","chatroom_name": roomName.text ?? "null","chatroom_image_base64": base64image ?? "null"]
            requestWithJSONBody(urlString:"http://140.121.198.84:9600/addChatroom", parameters: info)
        } else {
            //no user data
            //logout user
            
        }
     
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        roomImage.image = selectedImage
        let imageData = selectedImage.pngData()!
        base64image = imageData.base64EncodedString()
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func getInfo(password: String) {
        do {
            let urlString = "http://140.121.198.84:9600/getChatroomInfo?chatroom_secret="+password
            print(urlString)
            let urlWithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: urlWithPercentEscapes!)!
            
            let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                if let data = data, let results = try?
                    decoder.decode(RoomCode.self, from: data)
                {
                    if(results.code == 200){
                        if let rooms = RoomCode.loadFromFile(){
                            self.roomResult = rooms
                        }
                        self.roomResult?.append(results)
                        RoomCode.saveToFile(rooms: self.roomResult ?? [results])
                        print("get room info success")
                    } else {
                        print("get room info  error")
                    }
                    
                } else {
                    print("error")
                }
            }
            
            task.resume()
        }
    }
}

