//
//  MarvelManager.swift
//  Firecast
//
//  Created by Lakshmi Narayanan N on 02/11/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import Foundation

import Firebase
import FirebaseDatabase

class MarvelManager {
    let rootReference = Database.database().reference()
    
    init() {
    }
    
    func getMarvelCharacters(then: @escaping ([String : String] ) -> Void) {
        let marvelCharacterRefernce = rootReference.child("Marvel")
        marvelCharacterRefernce.observe(.value) { (dataSnapshot) in
            guard let characters = dataSnapshot.value as? [String : String] else {
                then([:])
                return
            }
            then(characters)
        }
    }
}

