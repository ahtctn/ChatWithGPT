//
//  ChatMessageViewModel.swift
//  ChatWithGPT
//
//  Created by Ahmet Ali ÇETİN on 30.07.2023.
//

import SwiftUI
import ChatGPTSwift

@MainActor
class ChatMessageViewModel: ObservableObject {
    let api = ChatGPTAPI(apiKey: Constants.api_key)
    
    @Published var message: String = ""
    @Published var chatMessage: [ChatMessageModel] = [ChatMessageModel]()
    @Published var isWaitingForResponse: Bool = false
    
    func sendMessage() async throws {
        let userMessage = ChatMessageModel(message)
        chatMessage.append(userMessage)
        isWaitingForResponse = true
        
        let assistantMessage = ChatMessageModel(owner: .bot, "")
        chatMessage.append(assistantMessage)
        
        let stream = try await api.sendMessageStream(text: message)
        message = ""
        for try await line in stream {
            if let lastMessage = chatMessage.last {
                let text = lastMessage.text
                let newMessage = ChatMessageModel(owner: .bot, text + line)
                chatMessage[chatMessage.count - 1] = newMessage
            }
        }
        
        isWaitingForResponse = false
    }
}
