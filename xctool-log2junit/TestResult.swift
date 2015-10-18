//
//  TestResult.swift
//  xcodeTestExtractor
//
//  Created by jerome morissard on 18/10/2015.
//  Copyright (c) 2015 Jérôme Morissard. All rights reserved.
//

import Foundation

class TestResult {
    var dateString :String
    var name :String
    var success :Bool
    var rawValue :String
    var testClassName :String
    var testClassNameRawValue :String

    init () {
        self.dateString = ""
        self.name = ""
        self.success = false
        self.rawValue = ""
        self.testClassName = ""
        self.testClassNameRawValue = ""
    }
}