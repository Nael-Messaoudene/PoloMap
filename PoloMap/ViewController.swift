//
//  ViewController.swift
//  PoloMap
//
//  Created by Nael Messaoudene on 28/03/2020.
//  Copyright © 2020 Nael Messaoudene. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var textFieldForAddress: UITextField!
    @IBOutlet weak var getDirectionsButton: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        map.showsUserLocation = true
        
        self.hideKeyboard()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        map.delegate = self
                
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = locationManager.location else {
                return
            }
            print(currentLocation.coordinate.latitude)
            print(currentLocation.coordinate.longitude)
            
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegion(center: currentLocation.coordinate,
                                                      latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
                     map.setRegion(coordinateRegion, animated: true)
                   
        }
        
       
    }
    
    @IBAction func getDirectionTapped(_ sender: UIButton) {
        getAddress()
    }
    
    func getAddress(){
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(textFieldForAddress.text!){
           (placemarks, error)
            in
            guard let placemarks = placemarks, let location = placemarks.first?.location
                else{
                    print("No location found")
                    return
            }
            print(location)
            
            print("eeeeeeeeeeeeeeee")
            print(location.coordinate)
            self.mapThis(destinationCoord: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations)
    
    }
    
    func mapThis(destinationCoord : CLLocationCoordinate2D){
        
        let sourceCoodinate = (locationManager.location?.coordinate)!
        
        print(sourceCoodinate)
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoodinate)
        
        let destPlacemark = MKPlacemark(coordinate: destinationCoord)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        print(destinationCoord)
        ////
        let address = [CNPostalAddressStreetKey: "BLA BLA Adresse", CNPostalAddressCityKey: "Ville", CNPostalAddressPostalCodeKey: "Code postal", CNPostalAddressISOCountryCodeKey: "Country code"]
        
        let pin = MKPlacemark(coordinate: destinationCoord, addressDictionary: address)
         let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        map.addAnnotation(pin)
        
        
        
        let destinationRequest = MKDirections.Request()
        
        destinationRequest.source = sourceItem
        destinationRequest.destination = destItem
        
        // get the transport type for the destination
        destinationRequest.transportType = .automobile
        
        destinationRequest.requestsAlternateRoutes = true

        let directions = MKDirections(request: destinationRequest)
        
        directions.calculate{ (response, error) in
            guard let response = response else{
                if let error = error {
                    print("something is wrong : ")
                }
                return
            }
            
            let route = response.routes[0]

            self.map.addOverlay(route.polyline)
            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
    
        render.strokeColor = .blue
        
        print(render)
        return render
    }
    
}

extension UIViewController{
    func hideKeyboard(){
        let tap: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}
