//
//  GoogleMapsController.swift
//  DriverWelfare
//
//  Created by Anderson Calixto on 28/10/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation

class GoogleMapsController: UIViewController, CLLocationManagerDelegate {

    var locationManager:CLLocationManager!
    let userLocation = GMSMarker()
    var mapView:GMSMapView?
    var initialized:Bool = false

    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        //let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView!

        userLocation.position = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        userLocation.title = "Car location"
        userLocation.snippet = "..."

      // Creates a marker in the center of the map.
//      let marker = GMSMarker()
//      //marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//      marker.position = CLLocationCoordinate2D(latitude: -3.731941, longitude: -38.490838)
//      marker.title = "Restaurante Coco Bambu"
//      marker.snippet = "Meireles"
//      marker.map = mapView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
    }

    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation:CLLocation = locations[0] as CLLocation
        CATransaction.begin()
        if (initialized) {
            CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
        } else {
            CATransaction.setValue(0.0, forKey: kCATransactionAnimationDuration)
        }
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        // manager.stopUpdatingLocation()
        print("user latitude = \(currentLocation.coordinate.latitude)")
        print("user longitude = \(currentLocation.coordinate.longitude)")
        self.userLocation.position = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: mapView!.camera.zoom)
        //mapView!.camera = camera
        mapView!.animate(to: camera)
        if (!initialized) {
            self.userLocation.map = mapView!
            initialized = true
        }
        CATransaction.commit()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
