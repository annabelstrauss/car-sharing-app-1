//
//  Trip.swift
//  CarSharingApp
//
//  Created by Chavane Minto on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse


class Trip: NSObject {
    
    //TODO: add array of users and conversation property
    //var tripMembers: [PFUser]!
    
    
    // Method to upload user trip to Parse
    
    /*
     
     Parameters:
        - User can add Departure Location (From)
        - User can add Arrival location (To)
        - User can add the Earliest & Latest times of departure
     
    */
    
    class func postTrip(withName tripName: String?, withDeparture departureLoc: String?, withArrival arrivalLoc: String?, withEarliest earlyDepart: NSDate?, withLatest lateDepart: NSDate?, withEditID editID: String?, withCoords coordinates: [String: [Double]], withCompletion completion: @escaping (PFObject?, Error?) -> ()) {
        
        // Create Trip Object: PFObject
        let trip = PFObject(className: "Trip")
        
        //Add relevant fields to the object
        trip["Name"] = tripName
        trip["Planner"] = PFUser.current()
        trip["DepartureLoc"] = departureLoc // Location where you will leave from
        trip["ArrivalLoc"] = arrivalLoc // Location you will arrive to
        trip["EarliestDate"] = earlyDepart // Earliest time you can leave
        trip["LatestDate"] = lateDepart // Latest timne you can leave
        trip["Coordinates"] = coordinates //lat and long of locations
        
        var tripMembers = [PFUser]()
        if(editID != "-1") {
            tripMembers.append(trip["Planner"] as! PFUser)
        }
        trip["Members"] = tripMembers
        
        trip["EditID"] = editID //this means there's no edit
        trip["Approvals"] = [PFUser]()

        trip["Messages"] = [PFObject]()
        
        
        // Save object (following function will save the object in Parse asynchronously)
        trip.saveInBackground { (success: Bool, error: Error?) in
            completion(trip, error)
        }
        
        
        
    }

}
