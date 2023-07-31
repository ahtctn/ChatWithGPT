//
//  ContentView.swift
//  ChatWithGPT
//
//  Created by Ahmet Ali ÇETİN on 30.07.2023.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ChatMessageViewModel()
    private var gptURL: [String] = [String]()
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.chatMessage) { message in
                            messageView(message)
                        }
                        
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                }
                
                .onReceive(viewModel.$chatMessage.throttle(for: 0.5, scheduler: RunLoop.main, latest: true)) { chatMessages in
                    guard !chatMessages.isEmpty else { return }
                    withAnimation {
                        proxy.scrollTo("bottom")
                    }
                }
            }
            
            HStack {
                TextField("Message", text: $viewModel.message, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                
                if viewModel.isWaitingForResponse {
                    ProgressView()
                        .padding()
                } else {
                    Button("Send") {
                        sendMessages()
                        sendLink(ChatMessageModel(owner: .bot, viewModel.message))
                        
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
    
    func messageView(_ message: ChatMessageModel) -> some View {
        HStack {
            if message.owner == .user {
                Spacer(minLength: 60)
            }
            
            if !message.text.isEmpty {
                VStack {
                    Text(message.text)
                        .foregroundColor(message.owner == .user ? .white : .black )
                        .padding(12)
                        .background(message.owner == .user ? .blue : .gray.opacity(0.1))
                        .cornerRadius(16)
                        .overlay(alignment: message.owner == .user ? .topTrailing : .topLeading) {
                            Text(message.owner.rawValue.capitalized)
                                .foregroundColor(.gray)
                                .font(.caption)
                                .offset(y: -16)
                        }
                }
            }
            
            if message.owner == .bot {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal)
    }
    
    func sendMessages() {
        Task {
            do {
                try await viewModel.sendMessage()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendLink(_ message: ChatMessageModel) {
        
        var textToShred: String = message.text
        
        if message.owner == .bot {
            if !message.text.isEmpty {
                
                let urlRegularExpression = Constants.urlRegularExpression

                if let regex = try? NSRegularExpression(pattern: urlRegularExpression, options: []) {
                    let textNSRange = NSRange(textToShred.startIndex..<textToShred.endIndex, in: textToShred)
                    let matches = regex.matches(in: textToShred, options: [], range: textNSRange)

                    var urlList: [String] = []

                    for match in matches {
                        if let range = Range(match.range, in: textToShred) {
                            let url = String(textToShred[range])
                            urlList.append(url)
                        }
                    }

                    print(urlList)
                }
            }
        }
        
        //let textToShred = "elbette, senin için bunu yapabilirim. İşte Alihan Samedov'dan Sen gelmez oldun müziği : https://www.example.com/alihansamedoc-sen-gelmez-oldun"

        
        
        
        /*
        if message.owner == .bot {
            if !message.text.isEmpty {
                
            }
        }
        */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
