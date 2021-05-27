//
//  GooglePlacesManager.swift
//  TestMap4
//
//  Created by Myles Cashwell on 5/27/21.
//

import Foundation
import GooglePlaces

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
}
