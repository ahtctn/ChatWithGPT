//
//  ContentView.swift
//  ChatWithGPT
//
//  Created by Ahmet Ali ÇETİN on 30.07.2023.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ChatMessageViewModel()
    
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
