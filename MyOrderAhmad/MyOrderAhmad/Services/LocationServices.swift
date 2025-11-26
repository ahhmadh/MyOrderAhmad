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

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var permissionDenied = false

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Request Permission
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
        // DO NOT start updating here.
    }

    // MARK: - Authorization Change
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {

        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()

        case .denied, .restricted:
            permissionDenied = true

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }

    // MARK: - Location Update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last?.coordinate
    }
}
