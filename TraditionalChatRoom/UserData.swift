

import Foundation

struct UserData: Codable {
    var name: String
    var email: String
    var facebookID: String
    var pictureUrl: String
    var facebookAccessToken: String
    
    static func read() -> UserData? {
        if let data = UserDefaults.standard.data(forKey: "userData"), let userData = try? PropertyListDecoder().decode(UserData.self, from: data) {
            return userData
        } else {
            return nil
        }
    }
    
    static func save(userData: UserData) {
        let encoder = PropertyListEncoder()
        if let data = try? encoder.encode(userData) {
            UserDefaults.standard.set(data, forKey: "userData")
            
        }
    }
}
