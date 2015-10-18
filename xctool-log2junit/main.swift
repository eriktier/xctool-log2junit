//
//  main.swift
//  xctool-log2junit
//
//  Created by jerome morissard on 18/10/2015.
//  Copyright (c) 2015 Jérôme Morissard. All rights reserved.
//

import Foundation

let arguments = NSProcessInfo.processInfo().arguments

//Open Xcode output file
var inputFilepath: String
var outputFilepath: String

if arguments.count == 4 {
    inputFilepath = arguments[1] as! String
    outputFilepath = arguments[3] as! String
    
} else {
    println("\n")
    println("arguments.count:\(arguments.count)")
    println("arguments:\(arguments)")
    println("\n")

    println("\nUSAGE")
    println("\txctool-log2junit your_xcodebuild_tests_log -o your_junit_filepath")
    exit(1)
}

let content = NSString(contentsOfFile: inputFilepath, usedEncoding: nil, error: nil)

var loadedfile = ""
if let test = content {
    loadedfile = test as String
}

//Reduce lines
let lines = loadedfile.componentsSeparatedByString("\n")
var results: [TestResult]
results = [TestResult]()

//Parse lines by lines (PASSED / FAILED)
for line in lines {
    
    var oneResult : TestResult?
    if line.rangeOfString("PASSED") != nil{
        oneResult = extractOneResultFromLine(line)
        if let r = oneResult {
            results.append(r)
        }
        
    } else if line.rangeOfString("FAILED") != nil{
        oneResult = extractOneResultFromLine(line)
        if let r = oneResult {
            results.append(r)
        }
    }
}

//Generate JUnit valid ouput
var nbFailures = 0
var nbErrors = 0
var fullDuration = 0.0
var nbTests = 0

for result in results {
    if (false == result.success) {
        nbErrors++;
        nbFailures++;
    }
    
    /*
    if (result.skipped) {
        nbFailures++;
    }
    */
    
    nbTests++;
    //fullDuration = fullDuration + result.duration;
}

var fullXMLResult = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
fullXMLResult = fullXMLResult + "<testsuites tests=\"\(nbTests)\" name=\"AllTestUnits\" timestamp=\"0\" hostname=\"jenkins\" failures=\"\(nbFailures)\" errors=\"\(nbFailures)\" time=\"\(0)\">\n"
fullXMLResult = fullXMLResult + "<properties>\n"
fullXMLResult = fullXMLResult + "<property name=\"jmo\" value=\"1\"/>\n"
fullXMLResult = fullXMLResult + "</properties>"

for result in results {
    fullXMLResult = fullXMLResult + "\n\t<testcase classname=\"\(result.testClassName)\" name=\"\(result.name)\" time=\"\(0.123456)\">"
    fullXMLResult = fullXMLResult + "\n\t\t<system-out>"
    fullXMLResult = fullXMLResult + "\n\t\t\(result.rawValue)"
    fullXMLResult = fullXMLResult + "\n\t\t</system-out>"
    fullXMLResult = fullXMLResult + "\n\t</testcase>"
}
fullXMLResult = fullXMLResult + "\n</testsuites\n"

let path = outputFilepath
fullXMLResult.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)

