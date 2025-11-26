//  Name: Ahmad Hassan
//  Student Number: 991691568
//  RoutePlannerView.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//

import SwiftUI
import MapKit

struct RoutePlannerView: View {

    @StateObject private var vm = MapViewModel()

    @State private var searchStop1 = ""
    @State private var searchStop2 = ""
    @State private var searchDestination = ""

    @State private var selectedRouteOption = 0

    // Tracks which search field the user is assigning
    @State private var activeSearchField: SearchField? = nil
    enum SearchField { case stop1, stop2, destination }

    var body: some View {
        VStack(spacing: 16) {

            // MARK: - Map
            mapSection

            // MARK: - Search Bars
            searchBarsSection

            // MARK: - Search Results
            searchResultsSection

            // MARK: - Route Picker
            Picker("Route", selection: $selectedRouteOption) {
                Text("Start → Stop1 → Stop2 → Dest").tag(0)
                Text("Start → Stop1").tag(1)
                Text("Stop1 → Stop2").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Button("Compute Route") {
                Task { await vm.computeRoute(option: selectedRouteOption) }
            }
            .buttonStyle(.borderedProminent)

            // MARK: - Steps
            StepsListView(steps: vm.routeLegs.flatMap { $0.steps })
        }
        .onAppear { vm.requestLocation() }
    }

    // ============================================================
    // MARK: - MAP SECTION (iOS 17+ Compatible)
    // ============================================================
    private var mapSection: some View {
        Map(initialPosition: MapCameraPosition.region(vm.region)) {

            // ROUTE LINES
            ForEach(vm.routeLegs) { leg in
                MapPolyline(leg.polyline)
                    .stroke(.blue, lineWidth: 5)
            }

            // USER
            if let user = vm.userLocation {
                Annotation("You", coordinate: user) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
            }

            // STOP 1
            if let s1 = vm.stop1 {
                Annotation("Stop 1", coordinate: s1.placemark.coordinate) {
                    markerPin(color: .blue, text: "1")
                }
            }

            // STOP 2
            if let s2 = vm.stop2 {
                Annotation("Stop 2", coordinate: s2.placemark.coordinate) {
                    markerPin(color: .green, text: "2")
                }
            }

            // DESTINATION
            if let dest = vm.destination {
                Annotation("Destination", coordinate: dest.placemark.coordinate) {
                    markerPin(color: .purple, text: "D")
                }
            }
        }
        .frame(height: 260)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    // ============================================================
    // MARK: - SEARCH BARS
    // ============================================================
    private var searchBarsSection: some View {
        VStack {
            SearchBarView(text: $searchStop1,
                          placeholder: "Search First Stop") {
                activeSearchField = .stop1
                Task { await vm.search(query: searchStop1) }
            }

            SearchBarView(text: $searchStop2,
                          placeholder: "Search Second Stop") {
                activeSearchField = .stop2
                Task { await vm.search(query: searchStop2) }
            }

            SearchBarView(text: $searchDestination,
                          placeholder: "Search Final Destination") {
                activeSearchField = .destination
                Task { await vm.search(query: searchDestination) }
            }
        }
    }

    // ============================================================
    // MARK: - SEARCH RESULTS LIST
    // ============================================================
    private var searchResultsSection: some View {

        List(vm.searchResults) { result in
            Button {
                // Assign based on which field user is choosing for
                switch activeSearchField {
                case .stop1:
                    vm.assignStop1(result)
                    searchStop1 = result.name
                case .stop2:
                    vm.assignStop2(result)
                    searchStop2 = result.name
                case .destination:
                    vm.assignDestination(result)
                    searchDestination = result.name
                case .none:
                    break
                }

                // Clear search results to close list
                vm.searchResults = []
            } label: {
                VStack(alignment: .leading) {
                    Text(result.name)
                    Text(result.subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(height: vm.searchResults.isEmpty ? 0 : 180)
        .animation(.easeInOut, value: vm.searchResults.count)
    }

    // ============================================================
    // MARK: - CUSTOM MARKER PIN
    // ============================================================
    @ViewBuilder
    private func markerPin(color: Color, text: String) -> some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 20, height: 20)

            Text(text)
                .font(.caption2)
                .foregroundColor(.white)
        }
    }
}
