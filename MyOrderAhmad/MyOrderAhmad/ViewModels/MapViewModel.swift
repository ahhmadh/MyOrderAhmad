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

    // MARK: - Services
    private let locationService = LocationService()
    private let searchService = SearchService()
    private let directionsService = DirectionsService()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Published Properties

    /// Exposed for the View (RoutePlannerView) to display the user pin.
    @Published var userLocation: CLLocationCoordinate2D?

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


    // MARK: - Init

    init() {
        bindLocationUpdates()
    }


    // MARK: - Bindings

    private func bindLocationUpdates() {

        // Listen to location changes from LocationService
        locationService.$userLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] coordinate in
                guard let coord = coordinate else { return }
                guard let self = self else { return }

                // Update View-exposed property
                self.userLocation = coord

                // Update map region
                self.region = MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
            .store(in: &cancellables)
    }


    // MARK: - Request Location

    func requestLocation() {
        locationService.requestPermission()
    }


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


    // MARK: - Assign Stops

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
        guard let startCoord = userLocation else {
            state = .error("User location not available yet.")
            return
        }

        state = .loading
        routeLegs = []

        let startMapItem = MKMapItem(placemark: MKPlacemark(coordinate: startCoord))

        switch option {

        case 0:
            // Multi-leg: Start → Stop1 → Stop2 → Destination
            await computeMultiLeg(start: startMapItem)

        case 1:
            // Start → Stop1
            await computeSingleLeg(from: startMapItem, to: stop1)

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
            state = .error("Missing stop(s) for route.")
            return
        }

        do {
            let route = try await directionsService.calculateRoute(from: from, to: to)

            let stepInstructions = route.steps
                .map { $0.instructions }
                .filter { !$0.isEmpty }

            let leg = RouteLeg(polyline: route.polyline, steps: stepInstructions)
            routeLegs.append(leg)
        }
        catch {
            state = .error("Failed to compute route between stops.")
        }
    }


    // MARK: - Multi Leg Route

    private func computeMultiLeg(start: MKMapItem) async {

        guard let s1 = stop1,
              let s2 = stop2,
              let dest = destination
        else {
            state = .error("Please select First Stop, Second Stop, and Final Destination.")
            return
        }

        await computeSingleLeg(from: start, to: s1)
        await computeSingleLeg(from: s1, to: s2)
        await computeSingleLeg(from: s2, to: dest)
    }
}
