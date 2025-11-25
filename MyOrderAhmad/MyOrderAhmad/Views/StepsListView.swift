//  Name: Ahmad Hassan
//  Student Number: 991691568
//  StepsListView.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//

import SwiftUI

struct StepsListView: View {
    let steps: [String]

    var body: some View {
        List(steps, id: \.self) { step in
            Text(step)
        }
    }
}
