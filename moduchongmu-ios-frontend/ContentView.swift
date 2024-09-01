//
//  ContentView.swift
//  moduchongmu-ios-frontend
//
//  Created by 이효근 on 14/08/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            MainWebView(url: URL(string: "https://moduchongmu.com/signin")!)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
