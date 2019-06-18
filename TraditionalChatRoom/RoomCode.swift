

import Foundation

struct RoomCode: Codable {
    var code: Int
    var status: String
    var message: [String : String]
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("roomInfo").appendingPathExtension("plist")
    
    static func loadFromFile() -> [RoomCode]?  {
        guard let codedRooms = try? Data(contentsOf: ArchiveURL) else {return nil}
        let decoder = PropertyListDecoder()
        return try? decoder.decode(Array<RoomCode>.self, from: codedRooms)
    }
    
    static func saveToFile(rooms: [RoomCode]) {
        let encoder = PropertyListEncoder()
        let codedEmojis = try? encoder.encode(rooms)
        try? codedEmojis?.write(to: ArchiveURL, options: .noFileProtection)
    }
}
