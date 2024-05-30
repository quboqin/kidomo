//
//  LocationHelp.swift
//  kidomo
//
//  Created by qinqubo on 2024/5/31.
//

import CoreLocation
import UIKit

// MARK: - LocationManagerDelegate Protocol
protocol LocationManagerDelegate: AnyObject {
    func locationMananger(_ locationManger: LocationManager, didUpdateLocation location: CLLocation)
}

class LocationManager: NSObject {
    private static let sharedManager = LocationManager()
    private let locationManager = CLLocationManager()
    
    public weak var hostController: LocationManagerDelegate?
      
    class func shared() -> LocationManager {
        return sharedManager
    }
      
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("When user did not yet determined")
            manager.requestWhenInUseAuthorization()
        case .restricted:
            print("Restricted by parental control")
        case .denied:
            print("When user select option Dont't Allow")
        case .authorizedWhenInUse:
            print("When user select option Allow While Using App or Allow Once")
            manager.requestAlwaysAuthorization()
        default:
            print("default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        
        if let clErr = error as? CLError {
            switch clErr.code {
            case .locationUnknown, .denied, .network:
                print("Location request failed with error: \(clErr.localizedDescription)")
            case .headingFailure:
                print("Heading request failed with error: \(clErr.localizedDescription)")
            case .rangingUnavailable, .rangingFailure:
                print("Ranging request failed with error: \(clErr.localizedDescription)")
            case .regionMonitoringDenied, .regionMonitoringFailure, .regionMonitoringSetupDelayed, .regionMonitoringResponseDelayed:
                print("Region monitoring request failed with error: \(clErr.localizedDescription)")
            default:
                print("Unknown location manager error: \(clErr.localizedDescription)")
            }
        } else {
            print("Unknown error occurred while handling location manager error: \(error.localizedDescription)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
    
        hostController?.locationMananger(self, didUpdateLocation: location)
    }
}
