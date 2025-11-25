//
//  SearchLocation.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//

import Foundation
import MapKit

/// Represents a single search result from the search service
struct SearchLocation: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let mapItem: MKMapItem
}
