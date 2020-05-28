import Cocoa
import CreateML

// MARK: Load the data into a variable
let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/qratilabs/Desktop/iOS-Dev/XCode/Practice-Projects/Twittermenti/twitter-sanders-apple3.csv"))

// MARK: Split the data into 80% Training and 20% Tes Data. Make seed to 5 for future split in same randomness
let (trainingData, testingData) = data.randomSplit(by: 0.80, seed: 5)

// MARK: Create the Sentiment Model using MLTextClassifier where "textColumn" is the name of the column in which we are appling Seniment Analysis and "label" is the column name that represent the sentiment feature.

let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "class")

// MARK: Generate Eveluation Matrics with the help of Test Data to find the Accuraccy
let evaluationMetrics = sentimentClassifier.evaluation(on: testingData, textColumn: "text", labelColumn: "class")
let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100

// MARK: Create meta data for new CoreML Model and Save the model in new .mlmodel file
let metaData = MLModelMetadata(author: "Chiru", shortDescription: "A model trained to classify sentiment on Tweets", version: "1.0")

try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/qratilabs/Desktop/iOS-Dev/XCode/Practice-Projects/Twittermenti/TweetSentimentClassifier.mlmodel"))


// MARK: Testing the model with custom String comment
try sentimentClassifier.prediction(from: "@Apple is a horrible company")
try sentimentClassifier.prediction(from: "@Apple is a terrible company")
try sentimentClassifier.prediction(from: "@Google is a very good company")

