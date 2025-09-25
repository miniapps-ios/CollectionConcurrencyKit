/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021 + Alessandro Oliva 2025
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import CollectionConcurrencyKit

@MainActor
final class MapTests: TestCase, @unchecked Sendable {
    func testNonThrowingAsyncMap() {
        runAsyncTest { array, collector in
            let values = await array.asyncMap { await collector.collectAndTransform($0) }
            XCTAssertEqual(values, array.map(String.init))
        }
    }

    func testThrowingAsyncMapThatDoesNotThrow() {
        runAsyncTest { array, collector in
            let values = try await array.asyncThrowingMap {
                try await collector.tryCollectAndTransform($0)
            }

            XCTAssertEqual(values, array.map(String.init))
        }
    }

    func testThrowingAsyncMapThatThrows() {
        runAsyncTest { array, collector in
            await self.verifyErrorThrown { error in
                try await array.asyncThrowingMap { int in
                    try await collector.tryCollectAndTransform(
                        int,
                        throwError: int == 3 ? error : nil
                    )
                }
            }

            DispatchQueue.main.async {
                XCTAssertEqual(collector.values, [0, 1, 2])
            }
        }
    }

    func testNonThrowingConcurrentMap() {
        runAsyncTest { array, collector in
            let values = await array.concurrentMap {
                await collector.collectAndTransform($0)
            }

            XCTAssertEqual(values, array.map(String.init))
        }
    }

    func testThrowingConcurrentMapThatDoesNotThrow() {
        runAsyncTest { array, collector in
            let values = try await array.concurrentMap {
                try await collector.tryCollectAndTransform($0)
            }

            XCTAssertEqual(values, array.map(String.init))
        }
    }

    func testThrowingConcurrentMapThatThrows() {
        runAsyncTest { array, collector in
            await self.verifyErrorThrown { error in
                try await array.concurrentMap { int in
                    try await collector.tryCollectAndTransform(
                        int,
                        throwError: int == 3 ? error : nil
                    )
                }
            }
        }
    }
}
