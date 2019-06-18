

import Foundation

struct ResponseCode: Codable {
    var code: Int
    var status: String
    var message: String

    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("rooms").appendingPathExtension("plist")
    
    static func loadFromFile() -> [ResponseCode]?  {
        guard let codedRooms = try? Data(contentsOf: ArchiveURL) else {return nil}
        let decoder = PropertyListDecoder()
        return try? decoder.decode(Array<ResponseCode>.self, from: codedRooms)
    }
    
    static func saveToFile(rooms: [ResponseCode]) {
        let encoder = PropertyListEncoder()
        let codedEmojis = try? encoder.encode(rooms)
        try? codedEmojis?.write(to: ArchiveURL, options: .noFileProtection)
    }
}
