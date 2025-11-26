//  Name: Ahmad Hassan
//  Student Number: 991691568
//  MapViewModel.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//

import Foundation
import MapKit
import Combine

@MainActor
class MapViewModel: ObservableObject {

    private let searchService = SearchService()
    private let directionsService = DirectionsService()

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )

    @Published var searchResults: [SearchLocation] = []

    @Published var stop1: MKMapItem?
    @Published var stop2: MKMapItem?
    @Published var destination: MKMapItem?

    @Published var routeLegs: [RouteLeg] = []

    @Published var state: AppState = .idle


    // MARK: - Searching

    func search(query: String) async {
        state = .loading
        searchResults = []

        do {
            let items = try await searchService.search(query: query)

            searchResults = items.map { item in
                SearchLocation(
                    name: item.name ?? "Unknown",
                    subtitle: item.placemark.title ?? "",
                    mapItem: item
                )
            }

            state = .loaded
        }
        catch {
            state = .error("Failed to perform search.")
        }
    }


    // MARK: - Assigning Stops

    func assignStop1(_ item: SearchLocation) { stop1 = item.mapItem }
    func assignStop2(_ item: SearchLocation) { stop2 = item.mapItem }
    func assignDestination(_ item: SearchLocation) { destination = item.mapItem }


    // MARK: - COMPUTE ROUTE (NO GPS REQUIRED)

    func computeRoute(option: Int) async {
        state = .loading
        routeLegs = []

        switch option {

        case 0:
            // Stop1 → Stop2 → Destination
            await computeMultiLeg()

        case 1:
            // Stop1 → Destination
            await computeSingleLeg(from: stop1, to: destination)

        case 2:
            // Stop1 → Stop2
            await computeSingleLeg(from: stop1, to: stop2)

        default:
            break
        }

        state = .loaded
    }


    // MARK: - Single Leg Route
    private func computeSingleLeg(from: MKMapItem?, to: MKMapItem?) async {
        guard let from = from, let to = to else {
            state = .error("Missing stops. Select Stop 1 and the next stop.")
            return
        }

        do {
            let route = try await directionsService.calculateRoute(from: from, to: to)

            let steps = route.steps
                .map { $0.instructions }
                .filter { !$0.isEmpty }

            let leg = RouteLeg(polyline: route.polyline, steps: steps)
            routeLegs.append(leg)
        }
        catch {
            state = .error("Failed to compute route.")
        }
    }


    // MARK: - Multi Leg Route (Stop1 → Stop2 → Destination)
    private func computeMultiLeg() async {
        guard let s1 = stop1,
              let s2 = stop2,
              let dest = destination else {
            state = .error("Select Stop 1, Stop 2, and Destination.")
            return
        }

        await computeSingleLeg(from: s1, to: s2)
        await computeSingleLeg(from: s2, to: dest)
    }
}
