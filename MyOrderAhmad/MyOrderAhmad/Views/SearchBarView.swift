//  Name: Ahmad Hassan
//  Student Number: 991691568
//  SearchBarView.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//



import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String
    let onSearch: () -> Void

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)

            Button("Search") {
                onSearch()
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
    }
}
