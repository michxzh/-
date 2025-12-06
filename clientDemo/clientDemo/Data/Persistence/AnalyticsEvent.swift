//
//  AnalyticsEvent.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//
import Foundation

struct AnalyticsEvent {
    let eventId: String
    let eventType: String   
    let messageId: String?
    let messageType: String?
    let timestamp: TimeInterval
}
