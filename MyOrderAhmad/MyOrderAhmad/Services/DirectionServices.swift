//  Name: Ahmad Hassan
//  Student Number: 991691568
//  DirectionServices.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//

import Foundation
import MapKit

/// Computes directions between two MKMapItems
class DirectionsService {

    func calculateRoute(from: MKMapItem, to: MKMapItem) async throws -> MKRoute {

        let request = MKDirections.Request()
        request.source = from
        request.destination = to

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()

        guard let route = response.routes.first else {
            throw NSError(domain: "Directions", code: -1, userInfo: [NSLocalizedDescriptionKey : "No route found"])
        }

        return route
    }
}
