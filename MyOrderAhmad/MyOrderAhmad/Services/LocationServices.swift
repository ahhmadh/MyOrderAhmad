//  Name: Ahmad Hassan
//  Student Number: 991691568
//  LocationServices.swift
//  MyOrderAhmad
//
//  Created by Ahmad Hassan on 2025-11-24.
//

import Foundation
import Combine
import CoreLocation

/// Handles user location permissions + coordinate updates.
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var permissionDenied = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    /// Request When-In-Use authorization
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    // MARK: - Delegate Callbacks

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first?.coordinate
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            permissionDenied = true
        default:
            break
        }
    }
}
