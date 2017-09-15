//
//  PlacesTableViewController.swift
//  My Favorite Places
//
//  Created by Lorman Lau on 9/14/17.
//  Copyright © 2017 Lorman Lau. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

protocol routeViewDelegate: class {
    func viewcancel()
    func getrow() -> Place?
}

class PlacesTableViewController: UITableViewController {
    
    var place: Place?
    var places = [Place]()
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    weak var delegate: MapDelegate?
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
            delegate?.cancel()
    }
    
    func fetchAllPlaces(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        do {
            let result = try moc.fetch(request)
            places = result as! [Place]
        } catch {
            print("\(error)")
        }
    }
    
    func save() {
        print("Saving")
        if moc.hasChanges {
            do {
                try moc.save()
                print("save successful")
            } catch {
                print("\(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllPlaces()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell") as! PlaceCell
        cell.nameLabel.text = places[indexPath.row].name
        var cost = ""
        for _ in 0..<Int(places[indexPath.row].cost) {
            cost += "$"
        }
        cell.costLabel.text = "Cost: \(cost)"
        var hearts = ""
        for _ in 0..<Int(places[indexPath.row].hearts) {
            hearts += "<3"
        }
        cell.heartLabel.text = "Favorite: \(hearts)"
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let object = places[indexPath.row]
        moc.delete(object)
        save()
        places.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "displayPlace", sender: places[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "editPlace", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayPlace" {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! routeViewController
            if let sender = sender as? Place {
                print("this working")
                place = sender
            }
            controller.delegate = self
            
        } else {
            let navController = segue.destination as! UINavigationController
            let controller = navController.topViewController as! AddItemViewController
            controller.delegate = self
            if let indexPath = sender as? IndexPath {
                controller.place = places[indexPath.row]
                controller.indexPath = indexPath
            }
        }
    }
}

extension PlacesTableViewController: placeDelegate {
    
    func save(name: String, desc: String, cost: Int, hearts: Int, lat: Double, lon: Double, indexPath: IndexPath?) {
        if let indexPath = indexPath {
            let place = places[indexPath.row]
            place.name = name
            place.desc = desc
            place.cost = Double(cost)
            place.hearts = Double(hearts)
            place.lat = lat
            place.lon = lon
        } else {
            let place = NSEntityDescription.insertNewObject(forEntityName: "Place", into: moc) as! Place
            place.name = name
            place.desc = desc
            place.cost = Double(cost)
            place.hearts = Double(hearts)
            place.lat = lat
            place.lon = lon
            places.append(place)
        }
        save()
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension PlacesTableViewController: routeViewDelegate {
    func viewcancel(){
        dismiss(animated: true, completion: nil)
    }
    func getrow() -> Place?{
        return place
    }
}

