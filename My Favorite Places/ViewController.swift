//
//  ViewController.swift
//  My Favorite Places
//
//  Created by Lorman Lau on 9/14/17.
//  Copyright © 2017 Lorman Lau. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

protocol MapDelegate: class {
    func cancel()
}

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let manager = CLLocationManager()
    var region = MKCoordinateRegion()
    var myLocation = CLLocationCoordinate2D()
    
    var places = [Place]()
    
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func fetchAllData(){
        let place = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        do {
            let results = try moc.fetch(place)
            places = results as! [Place]
        } catch {
            print("\(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        mapView.delegate = self
        fetchAllData()
        addAllAnnotations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayPlace" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! routeViewController
            controller.delegate = self
            controller.place = sender as! Place
        } else {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! PlacesTableViewController
            controller.delegate = self
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
        myLocation = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(myLocation, span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        self.manager.stopUpdatingLocation()
    }
    
    
    
    
}



extension ViewController: MKMapViewDelegate {
    func addAllAnnotations() {
        for place in places {
            let pin = MKPointAnnotation()
            pin.coordinate.longitude = place.lon
            pin.coordinate.latitude = place.lat
            mapView.addAnnotation(pin)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let cords = view.annotation?.coordinate {
            for place in places {
                if cords.latitude == place.lat && cords.longitude == place.lon {
                    performSegue(withIdentifier: "displayPlace", sender: place)
                }
            }
        }
    }
}

extension ViewController: MapDelegate {
    func cancel() {
        fetchAllData()
        mapView.removeAnnotations(mapView.annotations)
        addAllAnnotations()
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController: routeViewDelegate {
    func viewcancel() {
        dismiss(animated: true, completion: nil)
    }
}
