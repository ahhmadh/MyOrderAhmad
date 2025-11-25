//  Name: Ahmad Hassan
//  Student Number: 991691568
//  RouteLeg.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//

import MapKit

/// Represents one leg of a multi-leg route
struct RouteLeg: Identifiable {
    let id = UUID()
    let polyline: MKPolyline
    let steps: [String]
}
