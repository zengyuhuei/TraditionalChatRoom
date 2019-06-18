//
//  responseCode.swift
//  iOS_final_project
//
//  Created by yochien on 2019/1/9.
//  Copyright © 2019 yochien. All rights reserved.
//

import Foundation

struct addChatRoom: Codable {
    var access_token: String
    var chatroom_name: String
    var chatroom_image_base64: String
}

