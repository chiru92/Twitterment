//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier = TweetSentimentClassifier()

    // MARK: Twitter Developer Account API Key and API Secret
    // Instantiation using Twitter's OAuth Consumer Key and secret
    let swifter = Swifter(consumerKey: Constant.consumerKey, consumerSecret: Constant.consumerSecret)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let prediction = try? sentimentClassifier.prediction(text: "@Apple is the best company") {
            print(prediction.label)
        }
        
        swifter.searchTweet(using: "@Apple", lang: "en", count: 100, tweetMode: .extended, success: { (results, metaData) in
            //print(results)
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    @IBAction func predictPressed(_ sender: Any) {
    
    
    }
    
}

