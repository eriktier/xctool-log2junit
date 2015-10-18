//
//  XcodeLineParser.swift
//  xcodeTestExtractor
//
//  Created by jerome morissard on 18/10/2015.
//  Copyright (c) 2015 Jérôme Morissard. All rights reserved.
//

import Foundation

extension String {
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let utf16start = self.utf16.startIndex
        if let from = String.Index(self.utf16.startIndex + nsRange.location, within: self),
            let to = String.Index(self.utf16.startIndex + nsRange.location + nsRange.length, within: self) {
                return from ..< to
        }
        return nil
    }
}

func matchesForRegexInText(regex: String!, text: String!) -> [String] {
    let regex = NSRegularExpression(pattern: regex,
        options: nil, error: nil)!
    let results = regex.matchesInString(text,
        options: nil, range: NSMakeRange(0, count(text.utf16)))
        as! [NSTextCheckingResult]
    
    return map(results) {
        text.substringWithRange(text.rangeFromNSRange($0.range)!)
    }
}

//http://www.regexr.com/
func extractOneResultFromLine(line: String) -> TestResult {
    //line: 2015-10-17 11:07:35.087 catech[74110:2489398] + 'CATSavingAccount tests, Should have 1 block' [PASSED]
    
    //PARSE DATE ->  [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}
    var matches = matchesForRegexInText("[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\\.[0-9]{3}",line)
    
    var parameters = TestResult()
    parameters.rawValue = line
    
    if matches.count > 0 {
        parameters.dateString = matches.first!
    }
    
    //PARSE TEST CLASS NAME
    matches = matchesForRegexInText("[a-zA-Z ]*,",line)
    if matches.count > 0 {
        var rawName = matches.first
        rawName = rawName?.stringByReplacingOccurrencesOfString("Test ,", withString: "", options: nil, range: nil)
        parameters.testClassName = rawName!
        parameters.testClassNameRawValue = rawName!
    }
    
    //PARSE TEST NAME ->  form "+ '" to "'"
    matches = matchesForRegexInText("\\+ \'.*\'",line)
    if matches.count > 0 {
        var rawName = matches.first
        rawName = rawName?.stringByReplacingOccurrencesOfString(parameters.testClassNameRawValue, withString: "", options: nil, range: nil)
        rawName = rawName?.stringByReplacingOccurrencesOfString("+ '", withString: "", options: nil, range: nil)
        rawName = rawName?.stringByReplacingOccurrencesOfString("'", withString: "", options: nil, range: nil)
        parameters.name = rawName!
    }
    
    //PARSE RESULT -> [PASSED] or [FAILED]
    matches = matchesForRegexInText("PASSED",line)
    if matches.count > 0 {
        parameters.success = true
    }
    
    matches = matchesForRegexInText("FAILED",line)
    
    if matches.count > 0 {
        parameters.success = false
    }
    
    return parameters
}