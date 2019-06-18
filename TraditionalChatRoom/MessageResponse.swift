

import Foundation

struct MessageResponse: Codable {
    var code: Int
    var status: String
    var message: [[String : String]]
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("message").appendingPathExtension("plist")
    
    static func loadFromFile() -> [MessageResponse]?  {
        guard let codedRooms = try? Data(contentsOf: ArchiveURL) else {return nil}
        let decoder = PropertyListDecoder()
        return try? decoder.decode(Array<MessageResponse>.self, from: codedRooms)
    }
    
    static func saveToFile(rooms: [MessageResponse]) {
        let encoder = PropertyListEncoder()
        let codedEmojis = try? encoder.encode(rooms)
        try? codedEmojis?.write(to: ArchiveURL, options: .noFileProtection)
    }
}
