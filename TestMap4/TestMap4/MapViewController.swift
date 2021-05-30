//
//  MapViewController.swift
//  TestMap4
//
//  Created by Myles Cashwell on 5/26/21.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    let searchVC = UISearchController(searchResultsController: ResultsViewController())
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Maps"
        setUpSearchVC()
        checkLocationServices()
        centerViewOnUserLocation()
    }
    
    
    // MARK: - Functions
    func setUpSearchVC() {
        navigationItem.searchController = searchVC
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.barTintColor = .systemBackground
    }
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
        } else {
            // MC -
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: - Extensions
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // MC -
            break
        case .denied:
            // MC -
            break
        case .authorizedAlways:
            // MC -
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
            break
        @unknown default:
            print("error")
        }
    }
}

extension MapViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsVC = searchController.searchResultsController as? ResultsViewController else { return }
        
        resultsVC.delegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let places):
                    resultsVC.update(with: places)
                case .failure(let error):
                    print("Error in \(#function)\(#line) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}

// MARK: - Extensions
extension MapViewController: ResultsViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true)
        
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates
        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates,
                                             span: MKCoordinateSpan(latitudeDelta: 0.3,
                                                                    longitudeDelta: 0.3)), animated: true)
    }
}
