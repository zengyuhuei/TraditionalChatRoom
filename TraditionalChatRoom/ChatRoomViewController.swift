
import UIKit

class ChatRoomViewController:UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // 取得螢幕的尺寸
    var fullScreenSize :CGSize! = UIScreen.main.bounds.size
    var rooms : [ResponseCode]?
    var roomResult : [RoomCode]?
    var beforeSize = 0
    var myCollectionView : UICollectionView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // 設置底色
        self.view.backgroundColor = UIColor.white
        
        // 建立 UICollectionViewFlowLayout
        let layout = UICollectionViewFlowLayout()
        
        // 設置 section 的間距 四個數值分別代表 上、左、下、右 的間距
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        
        // 設置每一行的間距
        layout.minimumLineSpacing = 5
        
        // 設置每個 cell 的尺寸
        layout.itemSize = CGSize(width: CGFloat(fullScreenSize.width)/2 - 10.0, height: CGFloat(fullScreenSize.width)/2 - 10.0)
        
        // 設置 header 及 footer 的尺寸
        layout.headerReferenceSize = CGSize(width: fullScreenSize.width, height: 40)
        layout.footerReferenceSize = CGSize(width: fullScreenSize.width, height: 40)
        
        // 建立 UICollectionView
        self.myCollectionView = UICollectionView(frame: CGRect(x: 0, y: 20, width: fullScreenSize.width, height: fullScreenSize.height - 20), collectionViewLayout: layout)
        
        // 註冊 cell 以供後續重複使用
        self.myCollectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // 註冊 section 的 header 跟 footer 以供後續重複使用
        self.myCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        self.myCollectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
 
        // 設置委任對象
        self.myCollectionView.delegate = self
        self.myCollectionView.dataSource = self
        self.myCollectionView.backgroundColor = UIColor(red: 0/255, green: 246/255, blue: 255/255, alpha: 0.5)
        // 加入畫面中
        self.view.addSubview(myCollectionView)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewDidLoad()
        //open the tab bar
        self.tabBarController?.tabBar.isHidden = false
        
    }
    // 必須實作的方法：每一組有幾個 cell
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let rooms = RoomCode.loadFromFile()
        return rooms?.count ?? 0
    }
    
    // 必須實作的方法：每個 cell 要顯示的內容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 依據前面註冊設置的識別名稱 "Cell" 取得目前使用的 cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MyCollectionViewCell
        let rooms = RoomCode.loadFromFile()
        // 設置 cell 內容 (即自定義元件裡 增加的圖片與文字元件)
        
        
        let base64String = rooms?[indexPath.item].message["chatroom_image_base64"]
        if base64String != nil {
            let decodedData = NSData(base64Encoded: base64String!, options: [])
            if let data = decodedData {
                let decodedimage = UIImage(data: data as Data)
                cell.imageView.image = decodedimage
            } else {
                print("error with decodedData")
            }
        } else {
            print("error with base64String")
        }
        print(indexPath)
        cell.titleLabel.text = rooms?[indexPath.item].message["chatroom_name"]
        
        return cell
    }
    
    // 有幾個 section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // 點選 cell 後執行的動作
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("你選擇了第 \(indexPath.section + 1) 組的")
        print("第 \(indexPath.item + 1) 張圖片")
        
        let controller =  self.storyboard?.instantiateViewController(withIdentifier: "chatView") as! ChattingViewController
        let rooms = RoomCode.loadFromFile()
        controller.password = rooms?[indexPath.item].message["chatroom_secret"]
        controller.roomName = rooms?[indexPath.item].message["chatroom_name"]
        self.navigationController?.pushViewController(controller, animated:true)
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
                        print("getChatroomInfo success")
                        DispatchQueue.main.async(){
                            self.viewDidLoad()
                        }
                        //show that add room success
                        let controller = UIAlertController(title: "加入聊天室", message: "成功加入", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        controller.addAction(okAction)
                        self.present(controller, animated: true, completion: nil)

                    } else {
                        print("getChatroomInfo error")
                        //show that add room success
                        let controller = UIAlertController(title: "加入聊天室", message: "成功失敗", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        controller.addAction(okAction)
                        self.present(controller, animated: true, completion: nil)
                    }
                    
                } else {
                    print("error")
                }
            }
            
            task.resume()
        }
    }
   
    @objc func press(sender: UIButton!)
    {
        print("create room")
        let controller = UIAlertController(title: "進入聊天室", message: "請輸入聊天室密碼", preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "密碼"
            //textField.isSecureTextEntry = true
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            // password is the key of the room
            let password = controller.textFields?[0].text
            print(password ?? "nothing")
            self.getInfo(password: password!)
            
            
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)

    }

    @IBAction func deleteRoom(_ sender: UIButton) {
        print("delete room")
        let controller = UIAlertController(title: "清除聊天室", message: "確定嗎", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            
            do{
                try FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("roomInfo").appendingPathExtension("plist"))
                try FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("rooms").appendingPathExtension("plist"))
            }catch{
                
            }
            self.rooms?.removeAll()
            DispatchQueue.main.async(){
                self.myCollectionView.reloadData()
            }
        }
        controller.addAction(okAction)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    // 設置 reuse 的 section 的 header 或 footer
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // 建立 UICollectionReusableView
        var reusableView = UICollectionReusableView()
        
       
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: fullScreenSize.width, height: 40)
        
     
        // header
        if kind == UICollectionView.elementKindSectionHeader {
            // 依據前面註冊設置的識別名稱 "Header" 取得目前使用的 header
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath)
            // 設置 header 的內容
            button.addTarget(self, action: #selector(self.press(sender:)), for: .touchUpInside)
            button.setTitle("加入聊天室", for: .normal)
            button.backgroundColor = UIColor(red: 0/255, green: 246/255, blue: 255/255, alpha: 1)
            button.setTitleColor(.black, for: .normal)
            
        } else if kind == UICollectionView.elementKindSectionFooter {
            // 依據前面註冊設置的識別名稱 "Footer" 取得目前使用的 footer
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath)
            // 設置 footer 的內容
            // 設置 header 的內容
         
            
        }
        
        reusableView.addSubview(button)
  
        return reusableView
    }
 
}

