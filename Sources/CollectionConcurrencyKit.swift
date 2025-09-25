/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021 + Alessandro Oliva 2025
*  MIT license, see LICENSE.md file for details
*/

// MARK: - ForEach

public extension Sequence {
    /// Run an async closure for each element within the sequence.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter operation: The closure to run for each element.
    func asyncForEach(
        _ operation: (Element) async -> Void
    ) async {
        for element in self {
            await operation(element)
        }
    }
    
    /// Run an async closure for each element within the sequence.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter operation: The closure to run for each element.
    /// - throws: Rethrows any error thrown by the passed closure.
    func asyncThrowingForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}

public extension Sequence where Element: Sendable {
    /// Run an async closure for each element within the sequence.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter operation: The closure to run for each element.
    func concurrentForEach(
        withPriority priority: TaskPriority? = nil,
        _ operation: @Sendable @escaping (Element) async -> Void
    ) async {
        await withTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask(priority: priority) {
                    await operation(element)
                }
            }
            
            for await _ in group { }
        }
    }

    /// Run an async closure for each element within the sequence.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter operation: The closure to run for each element.
    /// - throws: Rethrows any error thrown by the passed closure.
    func concurrentForEach(
        withPriority priority: TaskPriority? = nil,
        _ operation: @Sendable @escaping (Element) async throws -> Void
    ) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for element in self {
                group.addTask(priority: priority) {
                    try await operation(element)
                }
            }
            
            for try await _ in group { }
        }
    }
    
    /// Run an async closure for each element within the sequence.
    ///
    /// The closure calls will be performed concurrently with a
    /// limit on maximum concurrent operations, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter limit: The maximum number of concurrent operations.
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter operation: The closure to run for each element.
    func concurrentForEach(
        maxConcurrent limit: Int,
        withPriority priority: TaskPriority? = nil,
        _ operation: @Sendable @escaping (Element) async -> Void
    ) async {
        _ = await concurrentLimitedExecute(maxConcurrent: limit, withPriority: priority, operation)
    }
    
    /// Run an async closure for each element within the sequence.
    ///
    /// The closure calls will be performed concurrently with a
    /// limit on maximum concurrent operations, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter limit: The maximum number of concurrent operations.
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter operation: The closure to run for each element.
    /// - throws: Rethrows any error thrown by the passed closure.
    func concurrentForEach(
        maxConcurrent limit: Int,
        withPriority priority: TaskPriority? = nil,
        _ operation: @Sendable @escaping (Element) async throws -> Void
    ) async throws {
        _ = try await concurrentLimitedThrowingExecute(maxConcurrent: limit, withPriority: priority, operation)
    }
}

// MARK: - Map

public extension Sequence {
    /// Transform the sequence into an array of new values using
    /// an async closure.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence.
    func asyncMap<T>(
        _ transform: (Element) async -> T
    ) async -> [T] {
        var values = [T]()

        for element in self {
            await values.append(transform(element))
        }

        return values
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence.
    /// - throws: Rethrows any error thrown by the passed closure.
    func asyncThrowingMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}

public extension Sequence where Element: Sendable {
    /// Transform the sequence into an array of new values using
    /// an async closure.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence.
    func concurrentMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async -> T
    ) async -> [T] {
        return await concurrentExecute(withPriority: priority, transform)
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence.
    /// - throws: Rethrows any error thrown by the passed closure.
    func concurrentMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async throws -> T
    ) async throws -> [T] {
        return try await concurrentThrowingExecute(withPriority: priority, transform)
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure.
    ///
    /// The closure calls will be performed concurrently with a
    /// limit on maximum concurrent operations, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter limit: The maximum number of concurrent operations.
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence.
    func concurrentMap<T: Sendable>(
        maxConcurrent limit: Int,
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async -> T
    ) async -> [T] {
        await concurrentLimitedExecute(
            maxConcurrent: limit,
            withPriority: priority,
            transform
        ).map(\.self)
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure.
    ///
    /// The closure calls will be performed concurrently with a
    /// limit on maximum concurrent operations, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter limit: The maximum number of concurrent operations.
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence.
    /// - throws: Rethrows any error thrown by the passed closure.
    func concurrentMap<T: Sendable>(
        maxConcurrent limit: Int,
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async throws -> T
    ) async throws -> [T] {
        try await concurrentLimitedThrowingExecute(
            maxConcurrent: limit,
            withPriority: priority,
            transform
        ).map(\.self)
    }
}

// MARK: - CompactMap

public extension Sequence {
    /// Transform the sequence into an array of new values using
    /// an async closure that returns optional values. Only the
    /// non-`nil` return values will be included in the new array.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   except for the values that were transformed into `nil`.
    func asyncCompactMap<T>(
        _ transform: (Element) async -> T?
    ) async -> [T] {
        var values = [T]()

        for element in self {
            guard let value = await transform(element) else {
                continue
            }

            values.append(value)
        }

        return values
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure that returns optional values. Only the
    /// non-`nil` return values will be included in the new array.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   except for the values that were transformed into `nil`.
    /// - throws: Rethrows any error thrown by the passed closure.
    func asyncThrowingCompactMap<T>(
        _ transform: (Element) async throws -> T?
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            guard let value = try await transform(element) else {
                continue
            }

            values.append(value)
        }

        return values
    }
}

public extension Sequence where Element: Sendable {
    /// Transform the sequence into an array of new values using
    /// an async closure that returns optional values. Only the
    /// non-`nil` return values will be included in the new array.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   except for the values that were transformed into `nil`.
    func concurrentCompactMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async -> T?
    ) async -> [T] {
        return await concurrentExecute(withPriority: priority, transform).compactMap(\.self)
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure that returns optional values. Only the
    /// non-`nil` return values will be included in the new array.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   except for the values that were transformed into `nil`.
    /// - throws: Rethrows any error thrown by the passed closure.
    func concurrentCompactMap<T: Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async throws -> T?
    ) async throws -> [T] {
        return try await concurrentThrowingExecute(withPriority: priority, transform).compactMap(\.self)
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure that returns optional values. Only the
    /// non-`nil` return values will be included in the new array.
    ///
    /// The closure calls will be performed concurrently with a
    /// limit on maximum concurrent operations, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter limit: The maximum number of concurrent operations.
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   except for the values that were transformed into `nil`.
    func concurrentCompactMap<T: Sendable>(
        maxConcurrent limit: Int,
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async -> T?
    ) async -> [T] {
        await concurrentLimitedExecute(
            maxConcurrent: limit,
            withPriority: priority,
            transform
        ).compactMap(\.self)
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure that returns optional values. Only the
    /// non-`nil` return values will be included in the new array.
    ///
    /// The closure calls will be performed concurrently with a
    /// limit on maximum concurrent operations, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter limit: The maximum number of concurrent operations.
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   except for the values that were transformed into `nil`.
    /// - throws: Rethrows any error thrown by the passed closure.
    func concurrentCompactMap<T: Sendable>(
        maxConcurrent limit: Int,
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async throws -> T?
    ) async throws -> [T] {
        try await concurrentLimitedThrowingExecute(
            maxConcurrent: limit,
            withPriority: priority,
            transform
        ).compactMap(\.self)
    }
}

// MARK: - FlatMap

public extension Sequence {
    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    func asyncFlatMap<T: Sequence>(
        _ transform: (Element) async -> T
    ) async -> [T.Element] {
        var values = [T.Element]()

        for element in self {
            await values.append(contentsOf: transform(element))
        }

        return values
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed in order, by waiting for
    /// each call to complete before proceeding with the next one. If
    /// any of the closure calls throw an error, then the iteration
    /// will be terminated and the error rethrown.
    ///
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    /// - throws: Rethrows any error thrown by the passed closure.
    func asyncThrowingFlatMap<T: Sequence>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T.Element] {
        var values = [T.Element]()

        for element in self {
            try await values.append(contentsOf: transform(element))
        }

        return values
    }
}

public extension Sequence where Element: Sendable {
    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    func concurrentFlatMap<T: Sequence & Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async -> T
    ) async -> [T.Element] where T.Element: Sendable {
        return await concurrentExecute(withPriority: priority, transform).flatMap(\.self)
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed concurrently, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    /// - throws: Rethrows any error thrown by the passed closure.
    func concurrentFlatMap<T: Sequence & Sendable>(
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async throws -> T
    ) async throws -> [T.Element] where T.Element: Sendable {
        return try await concurrentThrowingExecute(withPriority: priority, transform).flatMap(\.self)
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed concurrently with a
    /// limit on maximum concurrent operations, but the call
    /// to this function won't return until all of the closure calls
    /// have completed.
    ///
    /// - parameter limit: The maximum number of concurrent operations.
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    func concurrentFlatMap<T: Sequence & Sendable>(
        maxConcurrent limit: Int,
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async -> T
    ) async -> [T.Element] where T.Element: Sendable {
        await concurrentLimitedExecute(
            maxConcurrent: limit,
            withPriority: priority,
            transform
        ).flatMap(\.self)
    }
    
    /// Transform the sequence into an array of new values using
    /// an async closure that returns sequences. The returned sequences
    /// will be flattened into the array returned from this function.
    ///
    /// The closure calls will be performed concurrently with a
    /// limit on maximum concurrent operations, but the call
    /// to this function won't return until all of the closure calls
    /// have completed. If any of the closure calls throw an error,
    /// then the first error will be rethrown once all closure calls have
    /// completed.
    ///
    /// - parameter limit: The maximum number of concurrent operations.
    /// - parameter priority: Any specific `TaskPriority` to assign to
    ///   the async tasks that will perform the closure calls. The
    ///   default is `nil` (meaning that the system picks a priority).
    /// - parameter transform: The transform to run on each element.
    /// - returns: The transformed values as an array. The order of
    ///   the transformed values will match the original sequence,
    ///   with the results of each closure call appearing in-order
    ///   within the returned array.
    /// - throws: Rethrows any error thrown by the passed closure.
    func concurrentFlatMap<T: Sequence & Sendable>(
        maxConcurrent limit: Int,
        withPriority priority: TaskPriority? = nil,
        _ transform: @Sendable @escaping (Element) async throws -> T
    ) async throws -> [T.Element] where T.Element: Sendable {
        try await concurrentLimitedThrowingExecute(
            maxConcurrent: limit,
            withPriority: priority,
            transform
        ).flatMap(\.self)
    }
}
