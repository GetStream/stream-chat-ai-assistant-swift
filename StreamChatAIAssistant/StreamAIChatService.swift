//
//  StreamAIChatService.swift
//  StreamChatAIAssistant
//
//  Created by Martin Mitrevski on 26.11.24.
//

import Foundation

class StreamAIChatService {
    static let shared = StreamAIChatService()
    
    private let baseURL = "http://localhost:3000"
    private let jsonEncoder = JSONEncoder()
    
    private let urlSession = URLSession.shared
    
    func setupAgent(channelId: String) async throws {
        let url = URL(string: "\(baseURL)/start-ai-agent")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(
            AIAgentRequest(channelId: channelId)
        )
        let result = try await urlSession.data(for: request)
        print(result)
    }
    
    func stopAgent(channelId: String) async throws {
        let url = URL(string: "\(baseURL)/stop-ai-agent")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(
            AIAgentRequest(channelId: channelId)
        )
        let result = try await urlSession.data(for: request)
        print(result)
    }
}

struct AIAgentRequest: Encodable {
    let channelId: String
    
    enum CodingKeys: String, CodingKey {
        case channelId = "channel_id"
    }
}
