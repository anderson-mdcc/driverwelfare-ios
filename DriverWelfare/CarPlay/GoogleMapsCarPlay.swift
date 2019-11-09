//
//  GoogleMapsCarPlay.swift
//  DriverWelfare
//
//  Created by Anderson Calixto on 05/11/19.
//  Copyright © 2019 Anderson Calixto. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import GoogleMaps

class GoogleMapsCarPlay: UIViewController {

    var mapView:GMSMapView?

    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        //let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        //let camera = GMSCameraPosition.camera(withLatitude: -3.731941, longitude: -38.490838, zoom: 6.0)
        //mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        let camera = GMSCameraPosition.camera(withLatitude: -3.731941, longitude: -38.490838, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
    }
    
    func createMarker() {
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        //marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.position = CLLocationCoordinate2D(latitude: -3.731941, longitude: -38.490838)
        marker.title = "Restaurante Coco Bambu"
        marker.snippet = "Meireles"
        marker.map = mapView
    }
}
