//
//  GooglePlacesManager.swift
//  TestMap4
//
//  Created by Myles Cashwell on 5/27/21.
//

import Foundation
import GooglePlaces
import CoreLocation

struct Place {
    let name: String
    let id: String
}

class GooglePlacesManager {
    static let shared  = GooglePlacesManager()
    private let client = GMSPlacesClient.shared()
    
    private init() {}
    
    public func findPlaces(query: String, completion: @escaping (Result<[Place], PlaceError>) -> Void) {
        let filter  = GMSAutocompleteFilter()
        filter.type = .geocode
        
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { results, error in
            guard let results = results, error == nil else {
                completion(.failure(.unableToFind))
                return
            }
            
            let places: [Place] = results.compactMap({
                Place(name: $0.attributedFullText.string,
                      id: $0.placeID)
            })
            completion(.success(places))
        }
    }
    
    public func resolveLocation(for place: Place, completion: @escaping (Result<CLLocationCoordinate2D, PlaceError>) -> Void) {
        client.fetchPlace(fromPlaceID: place.id, placeFields: .coordinate, sessionToken: nil) { googlePlace, error in
            guard let googlePlace = googlePlace, error == nil else { return completion(.failure(.noCoordinates)) }
            
            let coordinate = CLLocationCoordinate2D(latitude: googlePlace.coordinate.latitude,
                                                    longitude: googlePlace.coordinate.longitude)
            completion(.success(coordinate))
        }
    }
}
