//
//  ContentView.swift
//  kidomo
//
//  Created by qinqubo on 2024/5/30.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                NavigationLink("Show Second View") {
                    SecondView()
                }
            }
            .padding()
        }.tint(.blue)
    }
}

#Preview {
    ContentView()
}
