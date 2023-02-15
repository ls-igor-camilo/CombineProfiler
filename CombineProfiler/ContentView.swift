//
//  ContentView.swift
//  CombineProfiler
//
//  Created by Igor Camilo on 14.02.23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        VStack {
            Spacer()
            Button("Create publisher (success)") {
                viewModel.createPublisher(fail: false)
            }
            Spacer()
            Button("Create publisher (failure)") {
                viewModel.createPublisher(fail: true)
            }
            Spacer()
            Button("Remove all") {
                viewModel.removeAll()
            }
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
