//
//  AppDelegate.swift
//  Dogecoin
//
//  Created by Tim Hadwen on 4/07/2014.
//  Copyright (c) 2014 Tim Hadwen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var timer: NSTimer?
    var hashRate: Int = 0
    var payout: Float = 0
    
    let hashReq = NSURL.URLWithString("http://multi.pandapool.info/api.php?q=userinfo&user=D7u16nkMRFRYakqEGrZvBLoDUpq8pafHtL")


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        liveUpdateTimer = nil
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        payout = storageClass.payoutTotal
        hashRate = Int((storageClass.hashRate as NSString).doubleValue)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        timer = nil
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func update(){
        let HashRequest = NSMutableURLRequest(URL: hashReq)
        NSURLConnection.sendAsynchronousRequest(HashRequest, queue: NSOperationQueue(), completionHandler: hashHandler)
    }
    
    func hashHandler(response: NSURLResponse!, data: NSData!, error: NSError!) {
        if !error?{
            
            //parse the json into a dictionary
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            
            //if the dictionary contains workers calculate the hashrate
            if(jsonResult["result"]?["workers"]! == nil){
                //do nothing
            } else {
                var hashStr : AnyObject? = jsonResult["result"]!["workers"]![0]![2]
                if hashRate == 0 && (hashStr as NSString).doubleValue != 0 {
                    println("Miner has started")
                } else if hashRate != 0 && (hashStr as NSString).doubleValue == 0 {
                    println("Miner has stopped")
                } else {
                    println("Miner continues as normal")
                }
            }
            
            //if the dictonary contains history then calculate it
            if( jsonResult["result"]?["history"]! == nil){
                // do nothing
            } else {
                var payoutTotal: Float = 0
                for item : AnyObject in (jsonResult["result"]!["history"]! as NSArray) {
                    payoutTotal += (item["payout"] as Float)
                }
                if( payout < payoutTotal){
                    //send push notification
                    println("Received \(payout-payoutTotal) DOGE")
                }
            }
            println("Hashrate: \(hashRate) Payout: \(payout) DOGE")
        }
    }

}

