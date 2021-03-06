//
//  HalfModalViewController.swift
//  CarSharingApp
//
//  Created by Annabel Strauss on 7/28/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse

class HalfModalViewController: UIViewController, HalfModalPresentable {

    @IBOutlet weak var myDatePicker: UIDatePicker!
    var newTime: NSDate!
    var currentTrip: PFObject?
    var originalTripEarliestTime: NSDate!
    var originalTripLatestTime: NSDate!
    @IBOutlet weak var leaveTimeButton: UIButton!
    @IBOutlet weak var changeTimeButton: UIButton!
    
    var dismissBlock: (() -> ())?
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Make Buttons Circular
        leaveTimeButton.layer.cornerRadius = leaveTimeButton.frame.height / 2
        leaveTimeButton.clipsToBounds = true
        changeTimeButton.layer.cornerRadius = changeTimeButton.frame.height / 2
        changeTimeButton.clipsToBounds = true
        
        //give the Search and Clear buttons color
        leaveTimeButton.backgroundColor = UIColor.white
        leaveTimeButton.layer.borderWidth = 2
        leaveTimeButton.layer.borderColor = Helper.peach().cgColor
        changeTimeButton.backgroundColor = Helper.peach()
        leaveTimeButton.setTitleColor(Helper.peach(), for: .normal)

        myDatePicker.minuteInterval = 10
        newTime = myDatePicker.date as NSDate
        originalTripLatestTime = currentTrip?["LatestDate"] as! NSDate
        originalTripEarliestTime = currentTrip?["EarliestDate"] as! NSDate
        
        myDatePicker.minimumDate = originalTripEarliestTime.addMinutes(minutesToAdd: 20) as Date
        myDatePicker.maximumDate = originalTripLatestTime as Date
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func changeTimeDatePickerAction(_ sender: Any) {
        newTime = myDatePicker.date as NSDate
        print("new time = \(newTime)")
    }
    
    @IBAction func didTapChangeTime(_ sender: Any) {
        
        Request.postRequest(withTrip: currentTrip, withUser: PFUser.current(), withDate: newTime) { (request: PFObject?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let request = request {
                print("request created with NEW TIME! 🐹")
            }
        }
        
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        dismiss(animated: true, completion: nil)
        dismissBlock!()
    }

    @IBAction func didTapLeaveTime(_ sender: Any) {
        
        Request.postRequest(withTrip: currentTrip, withUser: PFUser.current(), withDate: originalTripLatestTime) { (request: PFObject?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let request = request {
                print("request created with SAME TIME! 🐹")
            }
        }
        
        
        if let delegate = navigationController?.transitioningDelegate as? HalfModalTransitioningDelegate {
            delegate.interactiveDismiss = false
        }
        dismiss(animated: true, completion: nil)
        dismissBlock!()
    }
    
    //====== ADD USER TO TRIP WHEN "REQUEST TO JOIN" (aka "Merge") IS PRESSED =======
    func addUserToTrip(withNewTime newTime: NSDate) {
        var membersArray = currentTrip?["Members"] as! [PFUser]
        if membersArray.count < 4 {
            let memberNames = Helper.returnMemberNames(tripMembers: membersArray)
            if let fullname = PFUser.current()?["fullname"] {
                if memberNames.contains(fullname as! String) == false {
                    membersArray.append(PFUser.current()!)
                    currentTrip?["Members"] = membersArray
                    
                    //change the latest time of the trip
                    currentTrip?["LatestDate"] = newTime
                    
                    //SAVE this updated trip info to the trip
                    currentTrip?.saveInBackground(block: { (success: Bool, error: Error?) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if success{
                            print("😆success! updated trip to add new member")
                        }
                    })
                    currentTrip = nil
                } else if memberNames.contains(fullname as! String) == true{
                    print("You are already in this trip")
                }
            }
        }
        else {
            print("Can't join - this trip is already full")
        }
    }//close addUserToTrip()

}
