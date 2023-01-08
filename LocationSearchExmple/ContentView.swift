//
//  ContentView.swift
//  LocationSearchExmple
//
//  Created by cano on 2023/01/08.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            SearchView()
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
