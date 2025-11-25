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

    var body: some View {
        VStack(spacing: 16) {

            // MARK: - Map Section
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

            // MARK: - Steps List
            StepsListView(steps: vm.routeLegs.flatMap { $0.steps })
        }
        .onAppear { vm.requestLocation() }
    }

    // MARK: - Map Section
    private var mapSection: some View {
        Map(initialPosition: MapCameraPosition.region(vm.region)) {

            // ===== ROUTE POLYLINES =====
            ForEach(vm.routeLegs) { leg in
                MapPolyline(leg.polyline)
                    .stroke(.blue, lineWidth: 5)
            }

            // ===== USER LOCATION PIN =====
            if let user = vm.userLocation {
                Annotation("You", coordinate: user) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 15, height: 15)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
            }

            // ===== STOP 1 =====
            if let s1 = vm.stop1 {
                Annotation("Stop 1", coordinate: s1.placemark.coordinate) {
                    markerPin(color: .blue, text: "1")
                }
            }

            // ===== STOP 2 =====
            if let s2 = vm.stop2 {
                Annotation("Stop 2", coordinate: s2.placemark.coordinate) {
                    markerPin(color: .green, text: "2")
                }
            }

            // ===== FINAL DESTINATION =====
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


    // MARK: - Search Bars
    private var searchBarsSection: some View {
        VStack {
            SearchBarView(text: $searchStop1,
                          placeholder: "Search First Stop") {
                Task { await vm.search(query: searchStop1) }
            }

            SearchBarView(text: $searchStop2,
                          placeholder: "Search Second Stop") {
                Task { await vm.search(query: searchStop2) }
            }

            SearchBarView(text: $searchDestination,
                          placeholder: "Search Final Destination") {
                Task { await vm.search(query: searchDestination) }
            }
        }
    }

    // MARK: - Search Results
    private var searchResultsSection: some View {
        List(vm.searchResults) { result in
            Button {

                // Choose which stop to assign based on last edited field
                if searchStop1 == result.name {
                    vm.assignStop1(result)
                } else if searchStop2 == result.name {
                    vm.assignStop2(result)
                } else {
                    vm.assignDestination(result)
                }

            } label: {
                VStack(alignment: .leading) {
                    Text(result.name)
                    Text(result.subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(height: 160)
    }

    // MARK: - Custom Marker Pin
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
