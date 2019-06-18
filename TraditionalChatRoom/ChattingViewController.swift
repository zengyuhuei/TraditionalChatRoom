
import UIKit
import Starscream
class ChattingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // get the size of the screen
    let fullScreenSize = UIScreen.main.bounds.size
    var textView: UITextView!
    var myTableView: UITableView!
    var password :String!
    var roomName :String!
    //info contains the message
    var info = [Message]()
    var user : UserData?
    
    
    private var mWebSocket: WebSocket!
    @objc func press(sender: UIButton!)
    {
        print(textView.text ?? "")
        
        let message = textView.text ?? ""
        
        print("{\"access_token\":\"" + String(self.user!.facebookAccessToken) + "\",\"chatroom_secret\":\""+self.password+"\",\"message\":\""+message+"\"}")
        
        mWebSocket.write(string: "{\"access_token\":\"" + String(self.user!.facebookAccessToken) + "\",\"chatroom_secret\":\""+self.password+"\",\"message\":\""+message+"\"}")
        
        textView.text = ""
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the navigation bar title
        mWebSocket = WebSocket(url: URL(string: "ws://140.121.198.84:9500/")!)
        mWebSocket.delegate = self
        mWebSocket.connect()
        
        if let data = UserData.read() {
            self.user = data
        }
        //拿到之前的聊天記錄
        self.getMessage(password: password)
        
        self.title = roomName
        //hide the tab bar
        self.tabBarController?.tabBar.isHidden = true
        // 建立 UITableView 並設置原點及尺寸
        self.myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: fullScreenSize.width, height: fullScreenSize.height - 200), style: .grouped)
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.estimatedRowHeight = 100
        //建立text
        textView = UITextView(frame: CGRect(x: 0, y: fullScreenSize.height - 200, width: fullScreenSize.width, height:160))
        //建立提交按鈕
        let button = UIButton()
        button.frame = CGRect(x:0, y:fullScreenSize.height - 60, width:fullScreenSize.width,height:60)
        button.addTarget(self, action: #selector(self.press(sender:)), for: .touchUpInside)
        button.setTitle("送出", for: .normal)
        button.backgroundColor = UIColor(red: 0/255, green: 246/255, blue: 255/255, alpha: 1)
        button.setTitleColor(.black, for: .normal)
        
        
        textView.contentInsetAdjustmentBehavior = .automatic
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor(red: 0/255, green: 246/255, blue: 255/255, alpha: 0.5)
        textView.font = UIFont(name: "NameOfTheFont", size: 30)
        // 註冊 cell 的樣式及名稱
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // 設置委任對象
        myTableView.delegate = self
        myTableView.dataSource = self
        
        // 分隔線的樣式
        myTableView.separatorStyle = .singleLine
        
        // 分隔線的間距 四個數值分別代表 上、左、下、右 的間距
        myTableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        // 是否可以點選 cell
        myTableView.allowsSelection = true
        
        // 是否可以多選 cell
        myTableView.allowsMultipleSelection = false
        
        // 加入到畫面中
        self.view.addSubview(myTableView)
        self.view.addSubview(textView)
        self.view.addSubview(button)
        
       
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if mWebSocket.isConnected {
            mWebSocket.disconnect()
        }
        print("disconnect")
    }
    func getMessage(password: String) {
        do {
            let urlString = "http://140.121.198.84:9600/getMessage?chatroom_secret="+password
            print(urlString)
            let urlWithPercentEscapes = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: urlWithPercentEscapes!)!
            
            let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                if let data = data, let results = try?
                    decoder.decode(MessageResponse.self, from: data)
                {
                    print(results)
                    if(results.code == 200){
                        print("get message success")
                        if results.message.count != 0{
                            for i in 0...results.message.count-1{
                                self.info.append(Message(name: results.message[i]["name"]!, message: results.message[i]["message"]!, chatroom_secret: results.message[i]["chatroom_secret"]!, timestamp: results.message[i]["timestamp"]!))
                            }
                            self.myTableView.reloadData()
                        }
                        
                        
                        
                    } else {
                        print("get message error")
                    }
                    
                } else {
                    print("error")
                }
            }
            
            task.resume()
        }
    }
    // 必須實作的方法：每一組有幾個 cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.count
    }
    
    // 必須實作的方法：每個 cell 要顯示的內容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 取得 tableView 目前使用的 cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        
        // 顯示的內容
        if let myLabel = cell.textLabel {
            myLabel.lineBreakMode = .byWordWrapping
            myLabel.numberOfLines = 100
            let attributedText = NSMutableAttributedString(string:"[\(info[indexPath.row].timestamp)]", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),NSAttributedString.Key.foregroundColor:UIColor.black])
            attributedText.append( NSMutableAttributedString(string:"\(info[indexPath.row].name):\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20),NSAttributedString.Key.foregroundColor:UIColor.blue]))
            
            attributedText.append( NSMutableAttributedString(string:"\(info[indexPath.row].message)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),NSAttributedString.Key.foregroundColor:UIColor.brown]))
            myLabel.attributedText = attributedText
           
        }
        return cell
    }
    
    // 點選 cell 後執行的動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消 cell 的選取狀態
        tableView.deselectRow(at: indexPath, animated: true)
        
        let name = info[indexPath.row]
        print("選擇的是 \(name)")
    }
    
    // 點選 Accessory 按鈕後執行的動作
    // 必須設置 cell 的 accessoryType
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let name = info[indexPath.row]
        print("按下的是 \(name) 的 detail")
    }
    
    // 有幾組 section
    func numberOfSections(in tableView: UITableView) -> Int {
        //return info.count
        return 1
    }
    
    // 每個 section 的標題
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /*let title = section == 0 ? "籃球" : "棒球"*/
        return " "
    }
    // 設置 section header 的高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    /*// 設置 cell 的高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }*/
    /*
     // 設置每個 section 的 title 為一個 UIView
     // 如果實作了這個方法 會蓋過單純設置文字的 section title
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
     return UIView()
     }
     // 設置 section header 的高度
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
     return 80
     }
     // 每個 section 的 footer
     func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
     return "footer"
     }
     // 設置每個 section 的 footer 為一個 UIView
     // 如果實作了這個方法 會蓋過單純設置文字的 section footer
     func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
     return UIView()
     }
     // 設置 section footer 的高度
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
     return 80
     }
     // 設置 cell 的高度
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     return 80
     }
     */
    
}

extension ChattingViewController: WebSocketDelegate {
    
    /// 连接成功后的回调
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect")
    }
    
    /// 断开连接后的回调
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocketDidDisconnect, error = \(String(describing: error))")
        self.mWebSocket.connect()
    }
    
    /// 接收到消息后的回调(String)
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("websocketDidReceiveMessage, text = \(text)")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let data = text.data(using: .utf8), let results = try?
            decoder.decode(Message.self, from: data)
        {
            print(results)
            if results.chatroom_secret == self.password {
                print("[\(results.timestamp)] \(results.name): \(results.message)")
                self.info.append(Message(name: results.name, message: results.message, chatroom_secret: results.chatroom_secret, timestamp: results.timestamp))
                DispatchQueue.main.async(){
                    self.myTableView.reloadData()
                    let indexPath = IndexPath(row: self.info.count-1, section: 0)
                    self.myTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
            
        } else {
            print("error")
        }
    }
    
    /// 接收到消息后的回调(Data)
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData")
    }
}
