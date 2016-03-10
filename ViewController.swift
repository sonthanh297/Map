//
//  ViewController.swift
//  Map
//
//  Created by Phi Van Son on 3/8/16.
//  Copyright © 2016 Phi Van Son. All rights reserved.
//
import UIKit
import GoogleMaps
enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}
class ViewController: UIViewController {
    var mapTasks = MapTasks()
    
    var locationMarker: GMSMarker!
    
    var originMarker: GMSMarker!
    
    var destinationMarker: GMSMarker!
    
    var routePolyline: GMSPolyline!
    
    var markersArray: Array<GMSMarker> = []
    
    var waypointsArray: Array<String> = []
    
    var travelMode = TravelModes.driving
    
    @IBOutlet var ViewMap: GMSMapView!
   
    @IBOutlet weak var AddressCarLabel: UILabel!
    @IBOutlet weak var AdressPersonLabl: UILabel!
    let locationMan = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  locationMan.delegate = self
        ViewMap.delegate = self
        locationMan.requestWhenInUseAuthorization()
        //self.getAddressForLatLng("-33.86", longitude: "151.20")
        self.draw()
    }
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                self.AddressCarLabel.text = lines.joinWithSeparator("\n")
                UIView.animateWithDuration(0.25) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    func draw(){
        self.mapTasks.getDirections("Toronto", destination: "Montreal", waypoints: nil, travelMode: self.travelMode, completionHandler: { (status, success) -> Void in
            if success {
                self.drawRoute()
                self.ViewMap.camera = GMSCameraPosition.cameraWithLatitude(45.5018118, longitude: -73.5663868, zoom: 6)
            }
            else {
                print(status)
            }
        })    }
    func drawRoute() {
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = ViewMap
    }
    func getAddressForLatLng(latitude: String, longitude: String) {
        let str: String = "\(latitude),\(longitude)"
        let str1 = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.symbolCharacterSet())
let url = NSURL(string:"https://maps.googleapis.com/maps/api/geocode/json?latlng=\(str)")
        let data = NSData(contentsOfURL: url!)
        let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
        if let result = json["results"] as? NSArray {
            if let address = result[0]["address_components"] as? NSArray {
                let number = address[0]["short_name"] as! String
                let street = address[1]["short_name"] as! String
                let city = address[2]["short_name"] as! String
                let state = address[4]["short_name"] as! String
                let string = "\n\(number) \(street), \(city), \(state)"
                self.AdressPersonLabl.text = string
            }
        }
    }
}
//extension ViewController: CLLocationManagerDelegate {
//    
//    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//    
//        if status == .AuthorizedWhenInUse {
//            locationMan.startUpdatingLocation()
//            ViewMap.myLocationEnabled = true
//            ViewMap.settings.myLocationButton = true
//        }
//    }
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            ViewMap.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
//                locationMan.stopUpdatingLocation()
//        }
//        
//    }
//}
extension ViewController: GMSMapViewDelegate {
    func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }

}