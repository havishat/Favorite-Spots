//
//  PlaceDelegate.swift
//  My Favorite Places
//
//  Created by Lorman Lau on 9/14/17.
//  Copyright © 2017 Lorman Lau. All rights reserved.
//

import UIKit
import CoreLocation

protocol placeDelegate: class {
    func save(name: String, desc: String, cost: Int, hearts: Int, lat: Double, lon: Double, indexPath: IndexPath?)
    func cancel()
}
