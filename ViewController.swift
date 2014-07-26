//
//  ViewController.swift
//  Dogecoin
//
//  Created by Tim Hadwen on 4/07/2014.
//  Copyright (c) 2014 Tim Hadwen. All rights reserved.
//

import UIKit
import iAd
import AVFoundation


let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
var DOGEAddress: NSString! = "";

var liveUpdateTimer:NSTimer? = nil

//storage class for storage of data
var storageClass: data = data()

class ViewController: UIViewController, ADBannerViewDelegate {
    
    //Outlets for each view interface
    @IBOutlet var BtnRefresh : UIButton
    @IBOutlet var LblDiff : UILabel
    @IBOutlet var LblBal : UILabel
    @IBOutlet var BtnAddress : UIButton
    @IBOutlet var LblBlock : UILabel
    @IBOutlet var LblAddress : UILabel
    @IBOutlet var BtnHideAddress : UIButton
    @IBOutlet var newWordField: UITextField
    @IBOutlet var adBannerView : ADBannerView
    @IBOutlet var LblPrice : UILabel
    @IBOutlet var LblHashrate : UILabel
    @IBOutlet var LblPayout : UILabel = nil
    
    //network error message created and ready to be displayed
    var networkErrorAlert = UIAlertController(title: "Error", message: "Network Connection Failed. Connect to Wifi or Mobile Data", preferredStyle: UIAlertControllerStyle.Alert)
    
    //Address state variable true=displayed false=hidden
    var addressState = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var timerOnce = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("buttonHandler"), userInfo: nil, repeats: false)
        
        liveUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("buttonHandler"), userInfo: nil, repeats: true)
        
        self.canDisplayBannerAds = true
        self.adBannerView.delegate = self
        self.adBannerView.hidden = true
        
        networkErrorAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        userDefaults.synchronize()
        
        if userDefaults.objectForKey("address") != nil {
            DOGEAddress = userDefaults.objectForKey("address") as String
            if addressState {
                LblAddress.text = DOGEAddress
            } else {
                LblAddress.text = ""
            }
            LblBal.text = ""
        }
        buttonHandler()
    }
    
    override func viewDidAppear(animated: Bool) {
        updateFields()
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        //NSLog("bannerViewDidLoadAd")
        self.adBannerView.hidden = false//now show banner as ad is loaded
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        //NSLog("bannerViewDidLoadAd")
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        //NSLog("bannerViewActionShouldBegin")
        return willLeave //I do not know if that is the correct return statement
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func buttonHandler(){
        storageClass.update()
        println("Updated Get Requests")
        updateFields()
    }
    
    @IBAction func recAddress(sender: AnyObject){
        // display an alert
        let newWordPrompt = UIAlertController(title: "Enter Doge Address", message: "Please enter your Doge address", preferredStyle: UIAlertControllerStyle.Alert)
        newWordPrompt.addTextFieldWithConfigurationHandler(addTextField)
        newWordPrompt.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        newWordPrompt.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: wordEntered))
        presentViewController(newWordPrompt, animated: true, completion: nil)
    }
    
    @IBAction func toggleAddress(){
        if addressState {
            LblAddress.text = ""
            addressState = false
        } else {
            LblAddress.text = DOGEAddress
            addressState = true
        }
    }
    
    func wordEntered(alert: UIAlertAction!){
        // store the new word
        DOGEAddress = self.newWordField.text
        if addressState {
            LblAddress.text = DOGEAddress
        }
        
        //Store the doge address in the user defaults
        userDefaults.setObject(DOGEAddress, forKey: "address")
        userDefaults.synchronize()
        
        //Clear the balance text
        LblBal.text = "Press Refresh"
    }
    func addTextField(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "Doge Address"
        self.newWordField = textField
    }
    
    func updateFields(){
        let diff = "Diff: \(storageClass.diff)"
        let blocks = "Blocks: \(storageClass.blocks)"
        let price = storageClass.priceAsString()
        let balance = "Balance: \(storageClass.balance)"
        let hash = "Hashrate: \(storageClass.hashRate) kHash/s"
        let payout = "Payout: \(storageClass.payoutTotal) DOGE"
        
        LblDiff.text = diff
        LblBlock.text = blocks
        LblPrice.text = price
        LblBal.text = balance
        LblHashrate.text = hash
        LblPayout.text = payout
        
        println("Fields Updated")
        
    }
}

