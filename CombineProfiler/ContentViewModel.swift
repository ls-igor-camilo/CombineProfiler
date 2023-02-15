//
//  ContentViewModel.swift
//  CombineProfiler
//
//  Created by Igor Camilo on 14.02.23.
//

import Combine
import Foundation
import TimelaneCombine

@MainActor
class ContentViewModel: ObservableObject {

    private var cancellables: Set<AnyCancellable> = []

    func createPublisher(fail: Bool) {
        (1...10)
            .publisher
            .flatMap(maxPublishers: .max(1), step1)
            .flatMap(maxPublishers: .max(1), step2)
            .flatMap(maxPublishers: .max(1), step3)
            .tryMap { try checkFail(fail, value: $0) }
            .lane("Main")
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func removeAll() {
        cancellables.removeAll()
    }
}

fileprivate func step1(value: Int) -> some Publisher<Int, Never> {
    Future { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            promise(.success(value + 1))
        }
    }
    .lane("Step1")
}

fileprivate func step2(value: Int) -> some Publisher<Int, Never> {
    Future { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            promise(.success(value + 2))
        }
    }
    .lane("Step2")
}

fileprivate func step3(value: Int) -> some Publisher<Int, Never> {
    Future { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            promise(.success(value + 3))
        }
    }
    .lane("Step3")
}

fileprivate func checkFail<T>(_ fail: Bool, value: T) throws -> T {
    if fail { throw ContentViewModelError() }
    return value
}

fileprivate struct ContentViewModelError: Error {}
