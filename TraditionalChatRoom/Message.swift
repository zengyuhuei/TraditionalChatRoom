

import Foundation

struct Message: Codable {
    var name: String
    var message: String
    var chatroom_secret: String
    var timestamp: String
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("Message").appendingPathExtension("plist")
    
    static func loadFromFile() -> [Message]?  {
        guard let codedRooms = try? Data(contentsOf: ArchiveURL) else {return nil}
        let decoder = PropertyListDecoder()
        return try? decoder.decode(Array<Message>.self, from: codedRooms)
    }
    
    static func saveToFile(rooms: [Message]) {
        let encoder = PropertyListEncoder()
        let codedEmojis = try? encoder.encode(rooms)
        try? codedEmojis?.write(to: ArchiveURL, options: .noFileProtection)
    }
}
