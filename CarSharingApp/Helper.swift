//
//  Helper.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/26/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import Foundation
import Parse

class Helper {
    
    static func teal() -> UIColor {
        return UIColor(red: 68.0/255.0, green: 105.0/255.0, blue: 171.0/255.0, alpha: 1.0)
    }
    
    static func navy() -> UIColor {
        return UIColor(red: 68.0/255.0, green: 105.0/255.0, blue: 171.0/255.0, alpha: 1.0)
    }
    
    static func coral() -> UIColor {
        return UIColor(red: 254.0/255.0, green: 104.0/255.0, blue: 106.0/255.0, alpha: 1.0)
    }
    
    /*
     * Deletes the trip from the user's list of trips
     * Deletes the trip from parse
     */
    static func deleteTrip(trip: PFObject) {
        
        trip.deleteInBackground(block: { (success: Bool, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if success == true{
                print("trip deleted !")
            }
        })
    }
    
    static func dateToString(date: NSDate) -> String {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, h:mm a"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: date as Date)
        return selectedDate
    }
    
    static func returnMemberNames(tripMembers: [PFUser]) -> [String] {
        var memberNames: [String] = []
        for member in tripMembers {
            if let memberName = member["fullname"] as? String {
                memberNames.append(memberName)
            }
        }
        return memberNames
    }
    
    static func  returnMemberProfPics(tripMembers: [PFUser]) -> [PFFile] {
        var memberPics: [PFFile] = []
        for member in tripMembers {
            print("HI")
            if let profPic = member["profPic"] as? PFFile {
                memberPics.append(profPic)
            }
        }
        return memberPics
    }

    static func displayProfilePics(withCell cell: TripCell, withMemberPics pics: [PFFile]){
        let count = pics.count
        cell.onePersonImageView.isHidden = true
        cell.twoPeopleImageView1.isHidden = true
        cell.twoPeopleImageView2.isHidden = true
        cell.threePeopleImageView1.isHidden = true
        cell.threePeopleImageView2.isHidden = true
        cell.threePeopleImageView3.isHidden = true
        cell.fourPeopleImageView1.isHidden = true
        cell.fourPeopleImageView2.isHidden = true
        cell.fourPeopleImageView3.isHidden = true
        cell.fourPeopleImageView4.isHidden = true
        
        if(count == 1){
            cell.onePersonImageView.isHidden = false
            let profPic = pics[0]
            profPic.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.onePersonImageView.image = UIImage(data: data!)
            })
        } else if (count == 2) {
            let profPic1 = pics[0]
            let profPic2 = pics[1]
            profPic1.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.twoPeopleImageView1.image = UIImage(data: data!)
            })
            profPic2.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.twoPeopleImageView2.image = UIImage(data: data!)
            })
            cell.twoPeopleImageView1.isHidden = false
            cell.twoPeopleImageView2.isHidden = false
        } else if (count == 3) {
            let profPic1 = pics[0]
            let profPic2 = pics[1]
            let profPic3 = pics[2]
            cell.threePeopleImageView1.isHidden = false
            cell.threePeopleImageView2.isHidden = false
            cell.threePeopleImageView3.isHidden = false
            profPic1.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.threePeopleImageView1.image = UIImage(data: data!)
            })
            profPic2.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.threePeopleImageView2.image = UIImage(data: data!)
            })
            profPic3.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.threePeopleImageView3.image = UIImage(data: data!)
            })
        } else if (count == 4) {
            let profPic1 = pics[0]
            let profPic2 = pics[1]
            let profPic3 = pics[2]
            let profPic4 = pics[3]
            cell.fourPeopleImageView1.isHidden = false
            cell.fourPeopleImageView2.isHidden = false
            cell.fourPeopleImageView3.isHidden = false
            cell.fourPeopleImageView4.isHidden = false
            profPic1.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView1.image = UIImage(data: data!)
            })
            profPic2.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView2.image = UIImage(data: data!)
            })
            profPic3.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView3.image = UIImage(data: data!)
            })
            profPic4.getDataInBackground(block: { (data: Data?, error: Error?) in
                cell.fourPeopleImageView4.image = UIImage(data: data!)
            })
        }
        
    }
    
}