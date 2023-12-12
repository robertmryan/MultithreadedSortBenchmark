//
//  main.swift
//  MultithreadedSortBenchmark
//
//  Created by Robert Ryan on 12/12/23.
//

import CollectionsBenchmark

var benchmark = Benchmark(title: "Array/Buffer Benchmark")

let experiment = SubarraySorts()

benchmark.addSimple(title: "Array", input: Int.self) { input in
    blackHole(experiment.synchronousArrayExperiment(input))
}

benchmark.addSimple(title: "Buffer", input: Int.self) { input in
    blackHole(experiment.synchronousBufferExperiment(input))
}

benchmark.addSimple(title: "Serial", input: Int.self) { input in
    blackHole(experiment.serialExperiment(input))
}

benchmark.main()
