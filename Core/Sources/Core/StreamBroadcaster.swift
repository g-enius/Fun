//
//  StreamBroadcaster.swift
//  Core
//
//  Multi-consumer AsyncStream broadcaster. Replaces Combine Subjects
//  for one-to-many reactive state distribution.
//

import Foundation

@MainActor
public final class StreamBroadcaster<Element: Sendable> {

    private var continuations: [UUID: AsyncStream<Element>.Continuation] = [:]

    public init() {}

    /// Creates a new AsyncStream that receives all future yielded values.
    /// Each caller gets an independent stream — safe for multiple consumers.
    public func makeStream() -> AsyncStream<Element> {
        let id = UUID()
        return AsyncStream { continuation in
            self.continuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.continuations.removeValue(forKey: id)
                }
            }
        }
    }

    /// Sends a value to all active streams.
    public func yield(_ value: Element) {
        for continuation in continuations.values {
            continuation.yield(value)
        }
    }

    /// Finishes all active streams.
    public func finish() {
        for continuation in continuations.values {
            continuation.finish()
        }
        continuations.removeAll()
    }
}
