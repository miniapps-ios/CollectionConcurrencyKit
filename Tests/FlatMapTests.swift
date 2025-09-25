/**
*  CollectionConcurrencyKit
*  Copyright (c) John Sundell 2021 + Alessandro Oliva 2025
*  MIT license, see LICENSE.md file for details
*/

import XCTest
import CollectionConcurrencyKit

@MainActor
final class FlatMapTests: TestCase, @unchecked Sendable {
    func testNonThrowingAsyncFlatMap() {
        runAsyncTest { array, collector in
            let values = await array.asyncFlatMap {
                await collector.collectAndDuplicate($0)
            }

            XCTAssertEqual(values, array.flatMap { [$0, $0] })
        }
    }

    func testThrowingAsyncFlatMapThatDoesNotThrow() {
        runAsyncTest { array, collector in
            let values = try await array.asyncThrowingFlatMap {
                try await collector.tryCollectAndDuplicate($0)
            }

            XCTAssertEqual(values, array.flatMap { [$0, $0] })
        }
    }

    func testThrowingAsyncFlatMapThatThrows() {
        runAsyncTest { array, collector in
            await self.verifyErrorThrown { error in
                try await array.asyncThrowingFlatMap { int in
                    try await collector.tryCollectAndDuplicate(
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

    func testNonThrowingConcurrentFlatMap() {
        runAsyncTest { array, collector in
            let values = await array.concurrentFlatMap {
                await collector.collectAndDuplicate($0)
            }

            XCTAssertEqual(values, array.flatMap { [$0, $0] })
        }
    }

    func testThrowingConcurrentFlatMapThatDoesNotThrow() {
        runAsyncTest { array, collector in
            let values = try await array.concurrentFlatMap {
                try await collector.tryCollectAndDuplicate($0)
            }

            XCTAssertEqual(values, array.flatMap { [$0, $0] })
        }
    }

    func testThrowingConcurrentFlatMapThatThrows() {
        runAsyncTest { array, collector in
            await self.verifyErrorThrown { error in
                try await array.concurrentFlatMap { int in
                    try await collector.tryCollectAndDuplicate(
                        int,
                        throwError: int == 3 ? error : nil
                    )
                }
            }
        }
    }
}
