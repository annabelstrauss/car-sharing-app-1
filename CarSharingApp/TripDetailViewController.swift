//
//  TripDetailViewController.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/17/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit
import Parse
import GoogleMaps

class TripDetailViewController: UIViewController {
    
    var trip: PFObject?
    var globalMembers: [PFUser] = []
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var name1Label: UILabel!
    @IBOutlet weak var name2Label: UILabel!
    @IBOutlet weak var name3Label: UILabel!
    @IBOutlet weak var name4Label: UILabel!
    
    @IBOutlet weak var earliestLabel: UILabel!
    @IBOutlet weak var latestLabel: UILabel!
    @IBOutlet weak var departureLocLabel: UILabel!
    @IBOutlet weak var arrivalLocLabel: UILabel!
    @IBOutlet weak var requestPendingLabel: UILabel!
    @IBOutlet weak var earliestDateLabel: UILabel!
    @IBOutlet weak var latestDateLabel: UILabel!
    
    @IBOutlet weak var member1Prof: UIImageView!
    @IBOutlet weak var member2Prof: UIImageView!
    @IBOutlet weak var member3Prof: UIImageView!
    @IBOutlet weak var member4Prof: UIImageView!
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    var pendingEditAlert: UIAlertController!
    var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    @IBOutlet weak var myMapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserRequests()
        
        //hide all name labels (only make them appear if there's a name to put)
        name2Label.isHidden = true
        name3Label.isHidden = true
        name4Label.isHidden = true
        
        //hide all prof pics (only make them appear if there's a member to put)
        member2Prof.isHidden = true
        member3Prof.isHidden = true
        member4Prof.isHidden = true
        
        //hide edit and leave buttons and request pending
        editButton.isHidden = true
        leaveButton.isHidden = true
        requestPendingLabel.isHidden = true
        
        //make all prof pics circular
        member1Prof.layer.cornerRadius = member1Prof.frame.size.width / 2
        member1Prof.clipsToBounds = true
        member2Prof.layer.cornerRadius = member2Prof.frame.size.width / 2
        member2Prof.clipsToBounds = true
        member3Prof.layer.cornerRadius = member3Prof.frame.size.width / 2
        member3Prof.clipsToBounds = true
        member4Prof.layer.cornerRadius = member4Prof.frame.size.width / 2
        member4Prof.clipsToBounds = true
        
        //Set up the labels to have and colors
        requestPendingLabel.textColor = Helper.coral()
        
        
        //Pending Edit
        //Set up invalid trip alerts
        let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
            // handle cancel response here. Doing nothing will dismiss the view.
        }
        pendingEditAlert = UIAlertController(title: "Pending Edit", message: "There is already an edit in progress for this trip. You must wait until it is approved or denied before making another change.", preferredStyle: .alert)
        pendingEditAlert.addAction(cancelAction)
        
        
        //Fill in the labels to present the trip information
        if let trip = trip {
            let name = trip["Name"] as! String
            tripNameLabel.text = name.capitalized
            
            let earlyDate = trip["EarliestDate"] as! NSDate
            let lateDate = trip["LatestDate"] as! NSDate
            
            let earlyTimeStr = Helper.dateToStringJustTime(date: earlyDate)
            let lateTimeStr = Helper.dateToStringJustTime(date: lateDate)
            let earlyDateStr = Helper.dateToStringJustDate(date: earlyDate)
            let lateDateStr = Helper.dateToStringJustDate(date: lateDate)
            
            earliestLabel.text = earlyTimeStr
            latestLabel.text = lateTimeStr
            earliestDateLabel.text = earlyDateStr
            latestDateLabel.text = lateDateStr

            let members = trip["Members"] as! [PFUser]
            globalMembers = members
            let memberNames = Helper.returnMemberNames(tripMembers: members) as [String]
            print(memberNames)
            self.fillInNamesAndProfPics(memberNames: memberNames, members: members)

            
            //hide the "request to join" button if the current user is already in that trip OR if that trip already has 4 ppl in it
            let currentMemberName = PFUser.current()?["firstname"] as! String?
            if memberNames.contains(currentMemberName!) || memberNames.count == 4 {
                requestButton.isHidden = true
            }
            //show the edit and leave buttons if the current user is in the trip
            if memberNames.contains(currentMemberName!) {
                editButton.isHidden = false
                leaveButton.isHidden = false
            }
            
            //do the google maps thing if a trip has long/lat (newer trips only as of 8/4/17)
            if let coordinates = trip["Coordinates"] as? [String: [Double]] {
                //get the coordinates of the from/to locations
                let fromLat = coordinates["from"]?[0]
                let fromLong = coordinates["from"]?[1]
                let toLat = coordinates["to"]?[0]
                let toLong = coordinates["to"]?[1]
                //set up the google map frame thing and add markers (aka pins)
                let camera = GMSCameraPosition.camera(withLatitude: fromLat!, longitude: fromLong!, zoom: 14.0)
                let fromMarker = GMSMarker()
                fromMarker.position = CLLocationCoordinate2D(latitude: fromLat!, longitude: fromLong!)
                fromMarker.title = trip["DepartureLoc"] as! String
                fromMarker.map = myMapView
                fromMarker.icon = UIImage(named: "startPoint")
                let toMarker = GMSMarker()
                toMarker.position = CLLocationCoordinate2D(latitude: toLat!, longitude: toLong!)
                toMarker.title = trip["ArrivalLoc"] as! String
                toMarker.map = myMapView
                //create path from marker to marker
                let path = GMSMutablePath()
                path.add(CLLocationCoordinate2DMake(fromLat!, fromLong!))
                path.add(CLLocationCoordinate2DMake(toLat!, toLong!))
                let polyline = GMSPolyline(path: path)
                polyline.strokeWidth = 2.0
                polyline.map = myMapView
                //create bounds so the map zooms out to show both markers
                let bounds = GMSCoordinateBounds(path: path)
                myMapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
            }
        }
        
        //make buttons circular and styled
        editButton.layer.cornerRadius = editButton.frame.height / 2
        editButton.clipsToBounds = true
        leaveButton.layer.cornerRadius = leaveButton.frame.height / 2
        leaveButton.clipsToBounds = true
        leaveButton.backgroundColor = UIColor.white
        leaveButton.layer.borderWidth = 2
        leaveButton.layer.borderColor = Helper.peach().cgColor
        editButton.backgroundColor = Helper.peach()
        leaveButton.setTitleColor(Helper.peach(), for: .normal)
        editButton.setTitleColor(UIColor.white, for: .normal)
        requestButton.layer.cornerRadius = requestButton.frame.height / 2
        requestButton.clipsToBounds = true
        requestButton.backgroundColor = Helper.peach()
        requestButton.setTitleColor(UIColor.white, for: .normal)

        
    }//close viewDidLoad()
    
    func fillInNamesAndProfPics(memberNames: [String?], members: [PFUser]) {
        let count = memberNames.count
        
        //fill in first person's info if count > 0
        if let member1 = memberNames[0] {
            name1Label.text = member1.capitalized //fill in their name
            name1Label.textColor = Helper.coral()
            //fill in their prof pic
            if let profPic = members[0]["profPic"] as? PFFile {
                profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                    self.member1Prof.image = UIImage(data: imageData)
                }
            }
        }
        
        //fill in second person's info if count > 1
        if count > 1 {
            name2Label.isHidden = false
            name2Label.textColor = Helper.coral()
            member2Prof.isHidden = false
            if let member2 = memberNames[1] {
                name2Label.text = member2.capitalized //fill in their name
                //fill in their prof pic
                if let profPic = members[1]["profPic"] as? PFFile {
                    profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                        self.member2Prof.image = UIImage(data: imageData)
                    }
                }
            }
        }
        
        //fill in third person's info if count > 2
        if count > 2 {
            name3Label.isHidden = false
            name3Label.textColor = Helper.coral()
            member3Prof.isHidden = false
            if let member3 = memberNames[2] {
                name3Label.text = member3.capitalized //fill in their name
                //fill in their prof pic
                if let profPic = members[2]["profPic"] as? PFFile {
                    profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                        self.member3Prof.image = UIImage(data: imageData)
                    }
                }
            }
        }
        
        //fill in fourth person's info if count > 3
        if count > 3 {
            name4Label.isHidden = false
            name4Label.textColor = Helper.coral()
            member4Prof.isHidden = false
            if let member4 = memberNames[3] {
                name4Label.text = member4.capitalized //fill in their name
                //fill in their prof pic
                if let profPic = members[3]["profPic"] as? PFFile {
                    profPic.getDataInBackground { (imageData: Data!, error: Error?) in
                        self.member4Prof.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }//close fillInNames()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func didTapRequestToJoinTrip(_ sender: Any) {
        performSegue(withIdentifier: "halfModalSegue", sender: nil)
    }
    
    
    //====== ADD USER TO TRIP WHEN "REQUEST TO JOIN" IS PRESSED =======
    func addUserToTrip() {
        var membersArray = trip?["Members"] as! [PFUser]
        if membersArray.count < 4 {
            let memberNames = Helper.returnMemberNames(tripMembers: membersArray)
            if let fullname = PFUser.current()?["fullname"] {
                if memberNames.contains(fullname as! String) == false {
                    membersArray.append(PFUser.current()!)
                    trip?["Members"] = membersArray
                    
                    //SAVE this updated trip into to the trip
                    trip?.saveInBackground(block: { (success: Bool, error: Error?) in
                        if let error = error {
                            print(error.localizedDescription)
                        } else if success{
                            print("😆success! updated trip to add new member")
                            self.addMemberLocally(members: membersArray, currentFullname: fullname as! String)
                        }
                    })
                    trip = nil
                } else if memberNames.contains(fullname as! String) == true{
                    print("You are already in this trip")
                }
            }
        }
        else {
            print("Can't join - this trip is already full")
        }
    }//close addUserToTrip()
    
    //====== LOCALLY ADD MEMBER TO TRIP FOR DETAIL VIEW =======
    func addMemberLocally(members: [PFUser], currentFullname: String) {
        let newCount = members.count
        if newCount == 2 {
            name2Label.isHidden = false
            member2Prof.isHidden = false
            name2Label.text = currentFullname.capitalized
        }
        if newCount == 3 {
            name3Label.isHidden = false
            member3Prof.isHidden = false
            name3Label.text = currentFullname.capitalized
        }
        if newCount == 4 {
            name4Label.isHidden = false
            member4Prof.isHidden = false
            name4Label.text = currentFullname.capitalized
        }
    }
    
    //====== REMOVE THE USER FROM THE TRIP'S LIST OF MEMEBERS =======
    @IBAction func onLeaveTrip(_ sender: Any) {
        
        var membersList = trip?["Members"] as! [PFUser]
        let currentUserName = PFUser.current()?["fullname"] as! String
        //remove current user from trip's list of members
        for member in membersList {
            let memberName = member["fullname"] as! String
            if memberName == currentUserName {
                let removeIndex = membersList.index(of: member)
                 membersList.remove(at: removeIndex!)
            }
        }
        
        if membersList.count > 0 { //if there are still members in the trip, update the trip
            trip?["Members"] = membersList
            trip?.saveInBackground(block: { (success: Bool, error:Error?) in
                if let error = error {
                    print("Error removing user from Trip: \(error.localizedDescription)")
                } else {
                    print("FROM DETAIL VC: user successfully removed from trip")
                }
            })
        } else if membersList.count == 0 { //if there are no members in the trip, delete the trip
            trip?.deleteInBackground(block: { (success: Bool, error: Error?) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("FROM DETAIL VC: user left trip and trip deleted")
                }
            })
        }
        
        //go back to Home VC
        _ = navigationController?.popViewController(animated: true)

    }
    
    @IBAction func didTapMember1(_ sender: Any) {
        let member = globalMembers[0]
        performSegue(withIdentifier: "userProfile", sender: member)
    }
    
    @IBAction func didTapMember2(_ sender: Any) {
        let member = globalMembers[1]
        performSegue(withIdentifier: "userProfile", sender: member)
    }
    
    @IBAction func didTapMember3(_ sender: Any) {
        let member = globalMembers[2]
        performSegue(withIdentifier: "userProfile", sender: member)
    }
    
    @IBAction func didTapMember4(_ sender: Any) {
        let member = globalMembers[3]
        performSegue(withIdentifier: "userProfile", sender: member)
    }
    
    /*
    * Only allow Edit VC to open if the trip doesn't already have a corresponding edit pending
    * Otherwise, present the pending edit alert
    */
    @IBAction func didTapEdit(_ sender: Any) {
        let tripEditId = trip?["EditID"] as! String
        if tripEditId == "" { //only open edit vc if this trip doesn't have a corresponding edit
            performSegue(withIdentifier: "editSegue", sender: nil)
        } else {
            present(pendingEditAlert, animated: true) { } //present pending edit alert if there is a pending edit
        }
    }
    
    /*
     * Passes the current trip over to the Edit vc
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue" {
            let editViewController = segue.destination as! EditViewController //tell it its destination
            editViewController.originalTrip = trip
        }
        if segue.identifier == "halfModalSegue" {
            super.prepare(for: segue, sender: sender)
            self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: segue.destination)
            segue.destination.modalPresentationStyle = .custom
            segue.destination.transitioningDelegate = self.halfModalTransitioningDelegate
            let navigationController = segue.destination as! HalfModalNavViewController
            let halfModelVC = navigationController.childViewControllers[0] as! HalfModalViewController //tell it its destination
            halfModelVC.currentTrip = trip
            halfModelVC.dismissBlock = { () -> () in
                self.requestButton.isHidden = true
                self.requestPendingLabel.isHidden = false
            }
        }
        if segue.identifier == "userProfile" {
            let userProfileViewController = segue.destination as! UserProfileViewController //tell it its destination
            //let profileViewController = destinationNavigationController.topViewController as! UserProfileViewController
            userProfileViewController.user = sender as! PFUser
        }
    }
    
    func getUserRequests() {
        let query = PFQuery(className: "Request")
        query.whereKey("UserID", equalTo: PFUser.current()!.objectId!)
        query.includeKey("Trip")
        query.findObjectsInBackground { (returnedRequests: [PFObject]?, error: Error?) in
            if let returnedRequests = returnedRequests {
                for request in returnedRequests {
                    let requestTrip =  request["Trip"] as! PFObject
                    
                    
                    if requestTrip.objectId == self.trip?.objectId {
                        self.requestButton.isHidden = true
                        self.requestPendingLabel.isHidden = false
                    }
                }
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
        //tripsTableView.reloadData()
        
    }
    
    
}
