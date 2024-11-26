//
//  TypingIndicatorHandler.swift
//  StreamChatAIAssistant
//
//  Created by Martin Mitrevski on 25.11.24.
//

import Foundation
import StreamChat
import StreamChatSwiftUI

class TypingIndicatorHandler: ObservableObject, EventsControllerDelegate, ChatChannelMemberListControllerDelegate {
    
    @Injected(\.chatClient) var chatClient: ChatClient
    
    private var eventsController: EventsController!
    
    @Published var state: String = ""
    
    private let aiBotId = "ai-bot"
    
    @Published var aiBotPresent = false
    
    @Published var generatingMessageId: String?
    
    var channelId: ChannelId? {
        didSet {
            if let channelId = channelId {
                memberListController = chatClient.memberListController(query: .init(cid: channelId))
                memberListController?.delegate = self
                memberListController?.synchronize { [weak self] _ in
                    guard let self else { return }
                    self.aiBotPresent = self.isAiBotPresent
                }
            }
        }
    }
    
    @Published var typingIndicatorShown = false
    
    var isAiBotPresent: Bool {
        let aiAgent = memberListController?
            .members
            .first(where: { $0.id == self.aiBotId })
        return aiAgent?.isOnline == true
    }
    
    var memberListController: ChatChannelMemberListController?
        
    init() {
        eventsController = chatClient.eventsController()
        eventsController.delegate = self
    }
    
    func eventsController(_ controller: EventsController, didReceiveEvent event: any Event) {
        if event is AIClearTypingEvent {
            typingIndicatorShown = false
            generatingMessageId = nil
            return
        }
        
        guard let typingEvent = event as? AITypingEvent else {
            return
        }
        
        state = typingEvent.title
        if typingEvent.state == .generating {
            generatingMessageId = typingEvent.messageId
        } else {
            generatingMessageId = nil
        }
        typingIndicatorShown = !typingEvent.title.isEmpty
    }
    
    func memberListController(
        _ controller: ChatChannelMemberListController,
        didChangeMembers changes: [ListChange<ChatChannelMember>]
    ) {
        self.aiBotPresent = isAiBotPresent
    }
}

extension AITypingEvent {
    var title: String {
        switch state {
        case .thinking:
            return "Thinking"
        case .checkingExternalSources:
            return "Checking external sources"
        default:
            return ""
        }
    }
}
