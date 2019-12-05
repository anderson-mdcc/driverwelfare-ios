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
import GooglePlaces

import CoreLocation


class GoogleMapsController: UIViewController, CLLocationManagerDelegate {

    var locationManager:CLLocationManager!
    let userLocation = GMSMarker()
    var mapView:GMSMapView?
    
    
    
    override func loadView() {
      // Create a GMSCameraPosition that tells the map to display the
      // coordinate -33.86,151.20 at zoom level 6.
      //let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
      let camera = GMSCameraPosition.camera(withLatitude: -3.731941, longitude: -38.490838, zoom: 10.0)
      mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
      view = mapView!
        
      userLocation.position = CLLocationCoordinate2D(latitude: 1, longitude: 1)
      userLocation.title = "Car location"
      userLocation.snippet = "..."
      userLocation.map = mapView!
        
      locationManager = CLLocationManager()
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestAlwaysAuthorization()
      locationManager.distanceFilter = 50
      locationManager.startUpdatingLocation()
      locationManager.delegate = self
      // An array to hold the list of likely places.
      var likelyPlaces: [GMSPlace] = []

      // The currently selected place.
      var selectedPlace: GMSPlace?

      //placesClient = GMSPlacesClient.shared()
        
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
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        // manager.stopUpdatingLocation()
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        self.userLocation.position = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 16.0)
        mapView!.camera = camera
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}
