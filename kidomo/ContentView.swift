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
                Image("Kidomo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.tint)
                Text("Hello, kidomo!")
                NavigationLink("Show Opsfast View") {
                    let urlString = "https://m-saas.opsfast.com/"
                    let url = URL(string: urlString)!
                    SecondView(url: url)
                }
                NavigationLink("Show Test View") {
                    SecondView(url: nil)
                }
            }
            .padding()
        }.tint(.blue)
    }
}

#Preview {
    ContentView()
}
