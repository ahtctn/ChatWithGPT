//
//  ChatMessageModel.swift
//  ChatWithGPT
//
//  Created by Ahmet Ali ÇETİN on 30.07.2023.
//

import Foundation

struct ChatMessageModel: Identifiable {
    var id = UUID().uuidString
    var owner: MessageOwner
    var text: String
    
    init(owner: MessageOwner = .user, _ text: String) {
        self.owner = owner
        self.text = text
    }
}
