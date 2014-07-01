//
//  SWRouteTests.swift
//  SWRouteTests
//
//  Created by Dmitry Rodionov on 6/15/14.
//  Copyright (c) 2014 rodionovd. All rights reserved.
//

import XCTest
import SWRoute

class DemoClass {
    func demoMethod(arg: Int) -> Int {
        return (42 + arg);
    }
}

class SWRouteTests: XCTestCase {

    func testRouting() {

        /* Preconditions */
        let arg = 13
        XCTAssert(DemoClass().demoMethod(arg) == (42 + arg))

        /*
        * Replacing the method with a custom closure
        */
        var err = SwiftRoute.replace(function: DemoClass().demoMethod, with: {
            (arg : Int) -> Int in
                return (90 + arg)
        })
        XCTAssert(err == Int(KERN_SUCCESS))
        XCTAssert(DemoClass().demoMethod(arg) == (90 + arg))

        /*
        * Replacing the method with a function
        */
        func replacement(arg : Int) -> Int {
            return (567 - arg);
        }
        err = SwiftRoute.replace(function: DemoClass().demoMethod, with: replacement)
        XCTAssert(err == Int(KERN_SUCCESS))
        XCTAssert(DemoClass().demoMethod(arg) == (567 - arg))

        /*
        * Replacing a function with another function
        */
        func target(arg : Int) -> Int {
            return 0;
        }
        err = SwiftRoute.replace(function: target, with: replacement)
        XCTAssert(err == Int(KERN_SUCCESS))
        XCTAssert(target(arg) == (567 - arg))
    }

    func testKeepingOriginalImplementation() {

        func target(arg: Int) -> String {
            return "This is \(arg)"
        }
        func replacement(arg: Int) -> String {
            return "This is \(arg-40)"
        }

        var original_imp:uintptr_t = 0;
        let err = withUnsafePointer(&original_imp) {
            (pointer: UnsafePointer<uintptr_t>) -> (Int) in
            return SwiftRoute.replace(function: target, with: replacement, originalImp: pointer);
        }
        XCTAssert(err == Int(KERN_SUCCESS))
        XCTAssert(target(40) == replacement(40))
        XCTAssert(original_imp != 0);
    }
}
