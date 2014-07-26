//
//  data.swift
//  Dogecoin
//
//  Created by Tim on 16/07/2014.
//  Copyright (c) 2014 Tim Hadwen. All rights reserved.
//

import UIKit

let diffReq = NSURL.URLWithString("https://dogechain.info/chain/Dogecoin/q/getdifficulty")
var balReq = NSURL.URLWithString("https://dogechain.info/chain/Dogecoin/q/addressbalance/\(DOGEAddress)")
let blockCountReq = NSURL.URLWithString("https://dogechain.info/chain/Dogecoin/q/getblockcount")
let priceReq = NSURL.URLWithString("http://pubapi.cryptsy.com/api.php?method=singlemarketdata&marketid=132")
let hashReq = NSURL.URLWithString("http://multi.pandapool.info/api.php?q=userinfo&user=D7u16nkMRFRYakqEGrZvBLoDUpq8pafHtL")
let cexreq = NSURL.URLWithString("https://cex.io/api/ghash.io/hashrate?key=agrFt2mQGCkgDVGKCgbIbLlet4&signature=y551hZms3ytdqR3ayVuFe5LcP2Q&nonce=1390893786479")

class data: NSObject {
    var balance: String = ""
    var diff: String = ""
    var blocks: String = ""
    var price: Int = 0
    var hashRate: String = "" //in khash
    var payoutTotal: Float = 0
    
    //stores completion of request after update
    var complete: Int = 0
    
    func update(){
        complete = 0
        
        balReq = NSURL.URLWithString("https://dogechain.info/chain/Dogecoin/q/addressbalance/\(DOGEAddress)")
        /* Set up request urls for the requests*/
        let Diffrequest = NSMutableURLRequest(URL: diffReq)
        let BalRequest = NSMutableURLRequest(URL: balReq)
        let BlockRequest = NSMutableURLRequest(URL: blockCountReq)
        let PriceRequest = NSMutableURLRequest(URL: priceReq)
        let HashRequest = NSMutableURLRequest(URL: hashReq)
        let cexRequest = NSMutableURLRequest(URL: cexreq)
        
        /* Send the requests */
        NSURLConnection.sendAsynchronousRequest(HashRequest, queue: NSOperationQueue(), completionHandler: hashHandler)
        NSURLConnection.sendAsynchronousRequest(BalRequest, queue: NSOperationQueue(), completionHandler: BalHandler)
        NSURLConnection.sendAsynchronousRequest(BlockRequest, queue: NSOperationQueue(), completionHandler: BlockHandler)
        NSURLConnection.sendAsynchronousRequest(PriceRequest, queue: NSOperationQueue(), completionHandler: priceHandler)
        NSURLConnection.sendAsynchronousRequest(Diffrequest, queue: NSOperationQueue(), completionHandler: DiffHandler)
        NSURLConnection.sendAsynchronousRequest(cexRequest, queue: NSOperationQueue(), completionHandler: cexHandler)
    }
    
    func cexHandler(response: NSURLResponse!, data: NSData!, error: NSError!) {
        println(NSString(data: data, encoding: NSUTF8StringEncoding))
    }
    
    func updateHashOnly(){
        let HashRequest = NSMutableURLRequest(URL: hashReq)
        NSURLConnection.sendAsynchronousRequest(HashRequest, queue: NSOperationQueue(), completionHandler: hashHandler)
    }
    
    func DiffHandler(response: NSURLResponse!, data: NSData!, error: NSError!) {
        if !error?{
            diff = NSString(data: data, encoding: NSUTF8StringEncoding)
        }
        complete++
    }
    
    func BalHandler(response: NSURLResponse!, data: NSData!, error: NSError!) {
        if !error?{
            if (NSString(data: data, encoding: NSUTF8StringEncoding).length < 70) {
                balance = NSString(data: data, encoding: NSUTF8StringEncoding)
            } else {
                balance = "Bad Address"
            }
        }
        complete++
    }
    
    func BlockHandler(response: NSURLResponse!, data: NSData!, error: NSError!) {
        if !error?{
            blocks = NSString(data: data, encoding: NSUTF8StringEncoding)
        }
        complete++
    }
    
    func priceHandler(response: NSURLResponse!, data: NSData!, error: NSError!) {
        if !error?{
            let jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
            let priceStr: NSString = jsonResult["return"]!["markets"]!["DOGE"]!["lasttradeprice"] as String
            price = Int(priceStr.doubleValue*100000000)
        }
        complete++
    }
    
    func hashHandler(response: NSURLResponse!, data: NSData!, error: NSError!) {
        if !error?{
            
            //parse the json into a dictionary
            var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
            
            
            //if the dictionary contains workers calculate the hashrate
            if(jsonResult["result"]?["workers"]! == nil){
                hashRate = "0"
            } else {
                var hashStr : AnyObject? = jsonResult["result"]!["workers"]![0]![2]
                hashRate = hashStr as String
            }
            
            //if the dictonary contains history then calculate it
            if( jsonResult["result"]?["history"]! == nil){
                payoutTotal = 0
            } else {
                payoutTotal = 0
                for item : AnyObject in (jsonResult["result"]!["history"]! as NSArray) {
                    payoutTotal += (item["payout"] as Float)
                }
            }
        }
        complete++
    }
    
    func priceAsString() -> String{
        let result: String = "\(price) Satoshi"
        return result
    }
}
