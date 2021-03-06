//
//  HomeHeaderCell.swift
//  CarSharingApp
//
//  Created by Elan Halpern on 7/12/17.
//  Copyright © 2017 FBU. All rights reserved.
//

import UIKit

protocol HomeHeaderCellDelegate: class {
    func HomeHeaderCell(_ homeHeaderCell: HomeHeaderCell, didTap label: UILabel)
}

class HomeHeaderCell: UITableViewCell {
    
    @IBOutlet weak var startTextLabel: UILabel!
    @IBOutlet weak var endTextLabel: UILabel!
    @IBOutlet weak var earliestTextField: UITextField!
    @IBOutlet weak var latestTextField: UITextField!
    
    @IBOutlet weak var minTimeLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    
    weak var delegate: HomeHeaderCellDelegate?
    
    var earlyDate: NSDate!
    var lateDate: NSDate!
    var today: NSDate!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Set up tap gesture recognizer for start and end labels
        let startLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapStartLabel(_sender:))
        )
        let endLabelTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapEndLabel(_sender:))
        )
        
        //Add boarder to start and end labels
        startTextLabel.layer.borderColor = Helper.veryLightGray().cgColor
        startTextLabel.layer.borderWidth = 0.5
        startTextLabel.addGestureRecognizer(startLabelTapGestureRecognizer)
        startTextLabel.isUserInteractionEnabled = true
        startTextLabel.layer.cornerRadius = startTextLabel.frame.height / 5
        startTextLabel.clipsToBounds = true
        
        
        endTextLabel.layer.borderColor = Helper.veryLightGray().cgColor
        endTextLabel.layer.borderWidth = 0.5
        endTextLabel.addGestureRecognizer(endLabelTapGestureRecognizer)
        endTextLabel.isUserInteractionEnabled = true
        endTextLabel.layer.cornerRadius = endTextLabel.frame.height / 5
        endTextLabel.clipsToBounds = true
        
        //Make Go Button circular
        goButton.layer.cornerRadius = goButton.frame.height / 2
        goButton.clipsToBounds = true
        
        //Make Clear Button Circular
        clearButton.layer.cornerRadius = goButton.frame.height / 2
        clearButton.clipsToBounds = true
        
        //give the Search and Clear buttons color
        clearButton.backgroundColor = UIColor.white
        clearButton.layer.borderWidth = 2
        clearButton.layer.borderColor = Helper.peach().cgColor
        goButton.backgroundColor = Helper.peach()
        clearButton.setTitleColor(Helper.peach(), for: .normal)
        
        //create the date picker FOR EARLIEST and make it appear / be functional
        let EarliestDatePickerView  : UIDatePicker = UIDatePicker()
        EarliestDatePickerView.minuteInterval = 10
        EarliestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        earliestTextField.inputView = EarliestDatePickerView
        EarliestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForEarliest(_:)), for: UIControlEvents.valueChanged)
        today = Helper.currentTimeToNearest10()
        earlyDate =  today
        
        //create the date picker FOR LATEST and make it appear / be functional
        let LatestDatePickerView  : UIDatePicker = UIDatePicker()
        LatestDatePickerView.minuteInterval = 10
        LatestDatePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        latestTextField.inputView = LatestDatePickerView
        LatestDatePickerView.addTarget(self, action: #selector(self.handleDatePickerForLatest(_:)), for: UIControlEvents.valueChanged)
        lateDate = LatestDatePickerView.date.addingTimeInterval(2000000000000.0*60.0) as NSDate

        /*
        let toolBar = UIToolbar().ToolbarPiker(select: #selector(self.dismissPicker))
        latestTextField.inputAccessoryView = toolBar
        earliestTextField.inputAccessoryView = toolBar
        */
        
        //create the toolbar so there's a Done button in the datepicker
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.dismissPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        latestTextField.inputAccessoryView = toolBar
        earliestTextField.inputAccessoryView = toolBar
 
    }
    
    
    
    /*
     * Dismiss datepicker when Done button pressed
     */
    func dismissPicker() {
        latestTextField.resignFirstResponder()
        earliestTextField.resignFirstResponder()
    }

    func handleDatePickerForLatest(_ sender: UIDatePicker)
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        
        lateDate = sender.date as NSDate
        let minimumDate = earlyDate.addMinutes(minutesToAdd: 20)
        sender.minimumDate = minimumDate as Date
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        latestTextField.text =  selectedDate
    }
    
    func handleDatePickerForEarliest(_ sender: UIDatePicker)
    {
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        earlyDate = sender.date as NSDate
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"
        let maximumDate = lateDate.addMinutes(minutesToAdd: -20)
        sender.maximumDate = maximumDate as Date
        sender.minimumDate = today as NSDate as Date
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        earliestTextField.text =  selectedDate
    }
    
    func didTapStartLabel(_sender: UITapGestureRecognizer) {
        delegate?.HomeHeaderCell(self, didTap: startTextLabel)
        print("Tapped start label")
    }
    
    func didTapEndLabel(_sender: UITapGestureRecognizer) {
        delegate?.HomeHeaderCell(self, didTap: endTextLabel)
        print("Tapped End label")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
