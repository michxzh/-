//
//  MessageType.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

// Domain/Models/MessageType.swift
enum MessageType: String, Codable {
    case system
    case like
    case comment
    case follow
    case directMessage
}
