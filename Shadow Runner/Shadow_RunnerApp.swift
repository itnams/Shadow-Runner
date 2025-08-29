//
//  Shadow_RunnerApp.swift
//  Shadow Runner
//
//  Created by Nam Nguyễn on 29/8/25.
//

import SwiftUI

@main
struct Shadow_RunnerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .ignoresSafeArea()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        #endif
    }
}
