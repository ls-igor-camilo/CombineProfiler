//
//  ContentViewModel.swift
//  CombineProfiler
//
//  Created by Igor Camilo on 14.02.23.
//

import Combine
import Foundation
import os

fileprivate let signposter = OSSignposter(subsystem: "TestSubsystem", category: "TestCategory")

@MainActor
class ContentViewModel: ObservableObject {

    private var cancellables: Set<AnyCancellable> = []

    func createPublisher(fail: Bool) {
        let signpostID = signposter.makeSignpostID()
        (1...10)
            .publisher
            .flatMap(maxPublishers: .max(1), step1)
            .flatMap(maxPublishers: .max(1), step2)
            .flatMap(maxPublishers: .max(1), step3)
            .tryMap { try checkFail(fail, value: $0) }
            .handleEvents(
                receiveSubscription: { _ = signposter.beginInterval("Main", id: signpostID, "subscription \(String(describing: $0))") },
                receiveCompletion: { signposter.endInterval("Main", .beginState(id: signpostID), "completion \(String(describing: $0))") },
                receiveCancel: { signposter.endInterval("Main", .beginState(id: signpostID), "cancel") }
            )
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    func removeAll() {
        cancellables.removeAll()
    }
}

fileprivate func step1(value: Int) -> some Publisher<Int, Never> {
    let signpostID = signposter.makeSignpostID()
    return Future { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            promise(.success(value + 1))
        }
    }
    .handleEvents(
        receiveSubscription: { _ = signposter.beginInterval("Step1", id: signpostID, "subscription \(String(describing: $0))") },
        receiveCompletion: { signposter.endInterval("Step1", .beginState(id: signpostID), "completion \(String(describing: $0))") },
        receiveCancel: { signposter.endInterval("Step1", .beginState(id: signpostID), "cancel") }
    )
}

fileprivate func step2(value: Int) -> some Publisher<Int, Never> {
    let signpostID = signposter.makeSignpostID()
    return Future { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            promise(.success(value + 2))
        }
    }
    .handleEvents(
        receiveSubscription: { _ = signposter.beginInterval("Step2", id: signpostID, "subscription \(String(describing: $0))") },
        receiveCompletion: { signposter.endInterval("Step2", .beginState(id: signpostID), "completion \(String(describing: $0))") },
        receiveCancel: { signposter.endInterval("Step2", .beginState(id: signpostID), "cancel") }
    )
}

fileprivate func step3(value: Int) -> some Publisher<Int, Never> {
    let signpostID = signposter.makeSignpostID()
    return Future { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            promise(.success(value + 3))
        }
    }
    .handleEvents(
        receiveSubscription: { _ = signposter.beginInterval("Step3", id: signpostID, "subscription \(String(describing: $0))") },
        receiveCompletion: { signposter.endInterval("Step3", .beginState(id: signpostID), "completion \(String(describing: $0))") },
        receiveCancel: { signposter.endInterval("Step3", .beginState(id: signpostID), "cancel") }
    )
}

fileprivate func checkFail<T>(_ fail: Bool, value: T) throws -> T {
    if fail { throw ContentViewModelError() }
    return value
}

fileprivate struct ContentViewModelError: Error {}
