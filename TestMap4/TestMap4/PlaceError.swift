//
//  PlaceError.swift
//  TestMap4
//
//  Created by Myles Cashwell on 5/27/21.
//

import Foundation

enum PlaceError: LocalizedError {
    case invalidURL
    case thrownError(Error)
    case noData
    case unableToFind
    
    var errorDescription: String? {
        switch self {
        case.invalidURL:
            return "Unable to reach the server."
        case .thrownError(let error):
            print("Error in \(#function)\(#line) : \(error.localizedDescription) \n---\n \(error)")
            return "That place does not exist\nPlease check your spelling"
        case .noData:
            return "The server responded with no data"
        case .unableToFind:
            return "The server responded with bad data. Blame the back-end team, not the front-end"
        }
    }
}
