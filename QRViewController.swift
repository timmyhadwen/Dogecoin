//
//  QRViewController.swift
//  Dogecoin
//
//  Created by Tim on 16/07/2014.
//  Copyright (c) 2014 Tim Hadwen. All rights reserved.
//

import UIKit

class QRViewController: UIViewController {

    @IBOutlet var LblAddress : UILabel

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(Animated: Bool){
        LblAddress.text = "Scanning..."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
