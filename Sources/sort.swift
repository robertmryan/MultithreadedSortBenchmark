//
//  sort.swift
//  MultithreadedSortBenchmark
//
//  Created by Robert Ryan on 12/12/23.
//

import Foundation

class SubarraySorts {
    let defaultDevisions = 20
    let rangeOfValues = 0..<1_000_000

    nonisolated func arrayExperiment(_ size: Int) async -> Int {
        guard size > 0 else { return -1 }
        let array: [Int] = (0 ..< size).map { _ in .random(in: rangeOfValues) }

        var divisions = defaultDevisions
        var (divisionLength, remainder) = size.quotientAndRemainder(dividingBy: divisions)
        if remainder != 0 { divisionLength += 1 }
        (divisions, remainder) = size.quotientAndRemainder(dividingBy: divisionLength)
        if remainder != 0 { divisions += 1 }

        let result = await withTaskGroup(of: (Int, [Int]).self) { group in
            for division in 0 ..< divisions {
                let start = division * divisionLength
                let end = min((division + 1) * divisionLength, array.endIndex)

                group.addTask {
                    (division, array[start..<end].sorted())
                }
            }

            let dictionary: [Int: [Int]] = await group.reduce(into: [:]) { $0[$1.0] = $1.1 }
            return (0 ..< divisions).flatMap { dictionary[$0]! }
        }

        return result.count
    }

    func synchronousArrayExperiment(_ size: Int) -> Int {
        let group = DispatchGroup()
        group.enter()
        _Concurrency.Task.detached { [self] in
            _ = await arrayExperiment(size)
            group.leave()
        }
        group.wait()
        return 0
    }

    nonisolated func bufferExperiment(_ size: Int) async -> Int {
        guard size > 0 else { return -1 }

        let pointer = UnsafeMutableBufferPointer<Int>.allocate(capacity: size)
        _ = pointer.initialize(from: (0 ..< size).map { _ in .random(in: rangeOfValues) })

        defer {
            pointer.deinitialize()
            pointer.deallocate()
        }

        var divisions = defaultDevisions
        var (divisionLength, remainder) = size.quotientAndRemainder(dividingBy: divisions)
        if remainder != 0 { divisionLength += 1 }
        (divisions, remainder) = size.quotientAndRemainder(dividingBy: divisionLength)
        if remainder != 0 { divisions += 1 }

        await withTaskGroup(of: Void.self) { group in
            for division in 0 ..< divisions {
                let start = division * divisionLength
                let end = min((division + 1) * divisionLength, size)

                group.addTask {
                    pointer[start..<end].sort()
                }
            }
        }

        return size
    }

    nonisolated func serialExperiment(_ size: Int) -> Int {
        guard size > 0 else { return -1 }
        var array: [Int] = (0 ..< size).map { _ in .random(in: rangeOfValues) }

        var divisions = defaultDevisions
        var (divisionLength, remainder) = size.quotientAndRemainder(dividingBy: divisions)
        if remainder != 0 { divisionLength += 1 }
        (divisions, remainder) = size.quotientAndRemainder(dividingBy: divisionLength)
        if remainder != 0 { divisions += 1 }

        for division in 0 ..< divisions {
            let start = division * divisionLength
            let end = min((division + 1) * divisionLength, array.endIndex)

            array[start..<end].sort()
        }

        return array.count
    }

    func synchronousBufferExperiment2(_ array: [Int]) -> Int {
        let result = array.sorted()
        return result.count
    }

    func synchronousBufferExperiment(_ size: Int) -> Int {
        let group = DispatchGroup()
        group.enter()
        _Concurrency.Task.detached { [self] in
            _ = await bufferExperiment(size)
            group.leave()
        }
        group.wait()
        return 0
    }
}
