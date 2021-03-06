//
//  Show.swift
//  showbook
//
//  Created by Binay Budhthoki on 11/17/17.
//  Copyright © 2017 Mojo Monkies. All rights reserved.
//

import Foundation
import CleanroomLogger
import Parse

enum ShowValidationError : Error {
    case InvalidEmail
    case InvalidTheater
    case InvalidMovie
}

class Show {
    var movie:Movie?
    var theater:Theater?
    var email:String?
    
    func setEmail(email: String) throws {
        Log.info?.message("Show - Set Email")
        if (email.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
            Log.info?.message("Email is empty - Should Throw Exception")
            throw ShowValidationError.InvalidEmail
        }
        self.email = email
    }
    
    func setTheater(theater: Theater) {
        self.theater = theater
    }
    
    func setMovie(movie: Movie) {
        self.movie = movie
    }

    func describe() -> String {
        let showDetails = "Theater: \(String(describing: theater?.name)) -- Movie: \(String(describing: movie?.title)) -- Booked By: \(String(describing: email))"
        return showDetails
    }
    
    /**Saving the Show data - Parse Server**/
    
    func save() {
        let myShow =  PFObject(className: "Show")
        myShow["theater"] = theater?.name
        myShow["movie"] = movie?.title
        myShow["email"] = email
        
        //ToDo: How do i get hold of the current view controller so that i can
        //send a user notification that the Data has been saved !!
        myShow.saveInBackground(block: {
            (success: Bool, error: Error?) in
            if (success) {Log.info?.message("Parse Server : Show Saved - Sccessful")}
            else {Log.error?.message("Parser Server : Error \n\(error.debugDescription)")}
        })
    }
    
    /**Retrieving the Show data - Parse Server**/
    
    func retrieve() {
        Log.info?.message("Retrieving the Show Data from the Parse Server")
        let query = PFQuery(className: "Show")
        query.includeKeys(["_id", "theater", "movie", "_created_at", "_updated_at"])
        query.findObjectsInBackground { (pfObject, error) in
            for object in pfObject! {
                let movie = object["movie"]
                let theater = object["theater"]
                
                Log.info?.message("Email: \(String(describing: self.email)) - Moive: \(String(describing: movie)) - Theater: \(String(describing: theater))")
            }
        }
    }
    
    /**Retrieving the Show data via Email - Parse Server**/
    
    static func retrieve(email_id: String, reference: UITextView) {
        Log.info?.message("Retrieving Show Data via Email")
        
        let query = PFQuery(className: "Show")
        var dataDescription: String = ""
        
        query.whereKey("email", equalTo: email_id)
        query.findObjectsInBackground(block: { (pfObject, error) in
            for object in pfObject! {
                let movie = object["movie"]
                let theater = object["theater"]
                let email = object["email"]
                let message = "Email: \(String(describing: email)) - Moive: \(String(describing: movie)) - Theater: \(String(describing: theater))"
                
                Log.info?.message(message)
                dataDescription += message
            }
            reference.text = dataDescription
        })
        Log.info?.message("Outside PFQuery")
    }
    
}


class Movie {
    var title:String
    
    init(title: String) {
        self.title = title
    }
}

class Theater {
    var name:String
    
    init(name: String) {
        self.name = name
    }
}
