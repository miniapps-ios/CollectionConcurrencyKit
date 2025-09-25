/**
*  CollectionConcurrencyKit
*  Copyright (c) Alessandro Oliva 2025
*  MIT license, see LICENSE.md file for details
*/

import Foundation

extension Sequence where Element: Sendable {
    
    func initialResults<T: Sendable>() -> [(Int, T)?] {
        return Array<(Int, T)?>(repeating: nil, count: self.count(where: { _ in true }))
    }
    
    func concurrentExecute<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ body: @Sendable @escaping (Element) async -> T
    ) async -> [T] {
        await withTaskGroup(of: (Int, T).self) { group in
            var results: [(Int, T)?] = initialResults()
            
            for (index, element) in enumerated() {
                group.addTask(priority: priority) {
                    return (index, await body(element))
                }
            }
            
            for await (index, value) in group {
                results[index] = (index, value)
            }
            
            return results.compactMap(\.self).map(\.1)
        }
    }
    
    func concurrentThrowingExecute<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ body: @Sendable @escaping (Element) async throws -> T
    ) async throws -> [T] {
        try await withThrowingTaskGroup(of: (Int, T).self) { group in
            var results: [(Int, T)?] = initialResults()
            
            for (index, element) in enumerated() {
                group.addTask(priority: priority) {
                    return (index, try await body(element))
                }
            }
            
            for try await (index, value) in group {
                results[index] = (index, value)
            }
            
            return results.compactMap(\.self).map(\.1)
        }
    }
    
    func concurrentLimitedExecute<T: Sendable>(
        maxConcurrent limit: Int,
        withPriority priority: TaskPriority? = nil,
        _ body: @Sendable @escaping (Element) async -> T
    ) async -> [T] {
        precondition(limit > 0, "limit must be > 0")
        
        return await withTaskGroup(of: (Int, T).self) { group in
            var results: [(Int, T)?] = initialResults()
            var iterator = enumerated().makeIterator()
            var active = 0
            
            while active < limit, let (index, element) = iterator.next() {
                active += 1
                
                group.addTask(priority: priority) {
                    return (index, await body(element))
                }
            }
            
            for await (index, value) in group {
                results[index] = (index, value)
                active -= 1
                
                if let (index, element) = iterator.next() {
                    active += 1
                    
                    group.addTask(priority: priority) {
                        return (index, await body(element))
                    }
                }
            }
            
            return results.compactMap(\.self).map(\.1)
        }
    }
    
    func concurrentLimitedThrowingExecute<T: Sendable>(
        maxConcurrent limit: Int,
        withPriority priority: TaskPriority? = nil,
        _ body: @Sendable @escaping (Element) async throws -> T
    ) async throws -> [T] {
        precondition(limit > 0, "limit must be > 0")
        
        return try await withThrowingTaskGroup(of: (Int, T).self) { group in
            var results: [(Int, T)?] = initialResults()
            var iterator = enumerated().makeIterator()
            var active = 0
            
            while active < limit, let (index, element) = iterator.next() {
                active += 1
                
                group.addTask(priority: priority) {
                    return (index, try await body(element))
                }
            }
            
            for try await (index, value) in group {
                results[index] = (index, value)
                active -= 1
                
                if let (index, element) = iterator.next() {
                    active += 1
                    group.addTask(priority: priority) {
                        return (index, try await body(element))
                    }
                }
            }
            
            return results.compactMap(\.self).map(\.1)
        }
    }
}
