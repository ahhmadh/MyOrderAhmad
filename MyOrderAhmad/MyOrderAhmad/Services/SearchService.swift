//  Name: Ahmad Hassan
//  Student Number: 991691568
//  SearchService.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//

import Foundation
import MapKit

/// Performs MKLocalSearch queries and returns map items
class SearchService {

    func search(query: String) async throws -> [MKMapItem] {
        guard !query.isEmpty else { return [] }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let search = MKLocalSearch(request: request)

        let response = try await search.start()
        return response.mapItems
    }
}
