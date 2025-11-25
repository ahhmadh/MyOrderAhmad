//  Name: Ahmad Hassan
//  Student Number: 991691568
//  MapViewModel.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//


import Foundation
import Combine
import MapKit
import SwiftUI

@MainActor
class MapViewModel: ObservableObject {

    // MARK: - Services
    private let locationService = LocationService()
    private let searchService = SearchService()
    private let directionsService = DirectionsService()

    // MARK: - Published Properties

    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),   // Toronto fallback
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )

    @Published var searchResults: [SearchLocation] = []

    @Published var stop1: MKMapItem?
    @Published var stop2: MKMapItem?
    @Published var destination: MKMapItem?

    @Published var routeLegs: [RouteLeg] = []         // Multi-leg routes
    @Published var state: AppState = .idle            // Loading/error state

    // MARK: - Init + Observing Location
    init() {
        observeLocation()
    }

    private func observeLocation() {
        locationService.$userLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] coordinate in
                guard let coord = coordinate else { return }
                self?.region = MKCoordinateRegion(center: coord,
                                                  span: MKCoordinateSpan(latitudeDelta: 0.05,
                                                                         longitudeDelta: 0.05))
            }
            .store(in: &cancellables)
    }

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Permissions
    func requestLocation() {
        locationService.requestPermission()
    }

    // MARK: - Search
    func search(query: String) async {
        state = .loading
        searchResults = []

        do {
            let items = try await searchService.search(query: query)

            searchResults = items.map {
                SearchLocation(
                    name: $0.name ?? "Unknown",
                    subtitle: $0.placemark.title ?? "",
                    mapItem: $0
                )
            }

            state = .loaded
        }
        catch {
            state = .error("Search failed.")
        }
    }

    func assignStop1(_ item: SearchLocation) {
        stop1 = item.mapItem
    }

    func assignStop2(_ item: SearchLocation) {
        stop2 = item.mapItem
    }

    func assignDestination(_ item: SearchLocation) {
        destination = item.mapItem
    }

    // MARK: - Routing

    func computeRoute(option: Int) async {
        guard let userLocation = locationService.userLocation else {
            state = .error("User location not available yet.")
            return
        }

        state = .loading
        routeLegs = []

        let userMapItem = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))

        switch option {
        case 0:
            await computeMultiLeg(start: userMapItem)
        case 1:
            await computeSingleLeg(from: userMapItem, to: stop1)
        case 2:
            await computeSingleLeg(from: stop1, to: stop2)
        default:
            break
        }

        state = .loaded
    }

    private func computeSingleLeg(from: MKMapItem?, to: MKMapItem?) async {
        guard let from = from, let to = to else {
            state = .error("Missing stop(s).")
            return
        }

        do {
            let route = try await directionsService.calculateRoute(from: from, to: to)

            let steps = route.steps.map { $0.instructions }.filter { !$0.isEmpty }

            let leg = RouteLeg(polyline: route.polyline, steps: steps)
            routeLegs.append(leg)
        }
        catch {
            state = .error("Failed to calculate route.")
        }
    }

    private func computeMultiLeg(start: MKMapItem) async {
        guard let s1 = stop1, let s2 = stop2, let dest = destination else {
            state = .error("Please select all stops.")
            return
        }

        await computeSingleLeg(from: start, to: s1)
        await computeSingleLeg(from: s1, to: s2)
        await computeSingleLeg(from: s2, to: dest)
    }
}
