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
import SwiftyJSON
import SVProgressHUD

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
        textField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyBoard))
        self.view.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerAutoKeyboard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unRegisterAutoKeyboard()
    }
    
    @objc func dismissKeyBoard() {
        self.view.endEditing(true)
    }

    @IBAction func predictPressed(_ sender: Any) {
        if let searchText = textField.text {
            fetchTweet(text: searchText)
        }
    }
    
    // MARK: Search Tweet data using Tweet API
    private func fetchTweet(text: String) {
//        if let prediction = try? sentimentClassifier.prediction(text: "@Apple is the best company") {
//            print(prediction.label)
//        }
        SVProgressHUD.show()
        swifter.searchTweet(using: text, lang: "en", count: 100, tweetMode: .extended, success: { [weak self] (results, metaData) in
            guard let `self` = self else {return}
            var tweets: [TweetSentimentClassifierInput] = []
            for i in 0..<100 {
                if let tweet = results[i]["full_text"].string {
                    let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                    tweets.append(tweetForClassification)
                }
                self.makePrediction(data: tweets)
            }
        }) { (error) in
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
        }
    }
    
    // MARK: Apply Sentiment ML Model on tweet data
    private func makePrediction(data: [TweetSentimentClassifierInput]) {
        do {
            let predictionOption = MLPredictionOptions()
            predictionOption.usesCPUOnly = true
            let predictions = try self.sentimentClassifier.predictions(inputs: data, options: predictionOption)
            var sentimentScore = 0
            //print(predictions.map{ $0.label})
            for pred in predictions {
                let sentiment = pred.label
                if sentiment == "Pos" {
                    sentimentScore += 1
                }
                else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            SVProgressHUD.dismiss()
            updateUI(sentimentScore: sentimentScore)
        }
        catch {
            SVProgressHUD.dismiss()
            print(error.localizedDescription)
        }
        //print(tweets)
    }
    
    // MARK: Show emoji on View
    private func updateUI(sentimentScore: Int) {
        if sentimentScore > 20 {
            sentimentLabel.text = "😍"
        }
        else if sentimentScore > 10 {
            sentimentLabel.text = "😃"
        }
        else if sentimentScore > 0 {
            sentimentLabel.text = "🙂"
        }
        else if sentimentScore == 0 {
            sentimentLabel.text = "😐"
        }
        else if sentimentScore > -10 {
            sentimentLabel.text = "😕"
        }
        else if sentimentScore > -20 {
            sentimentLabel.text = "😡"
        }
        else {
            sentimentLabel.text = "🤮"
        }
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.text!.isEmpty {
            self.fetchTweet(text: textField.text!)
        }
        return true
    }
}
