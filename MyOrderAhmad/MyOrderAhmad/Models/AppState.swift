//
//  AppState.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//

enum AppState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}
