//
//  kaptionatorTests.swift
//  kaptionatorTests
//
//  Created by bill donner on 10/31/16.
//  Copyright © 2016 midnightrambler. All rights reserved.
//

import XCTest

@testable import kaptionator
class kaptionatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        StickerAssetSpace.reset(title: "restarting test")
        
        let x = StickerAssetSpace.itemCount()
        XCTAssert(x==0)
        AppCaptionSpace.reset()
        let y = AppCaptionSpace.itemCount()
        XCTAssert(y==0)
        SharedCaptionSpace.reset()
        let z = SharedCaptionSpace.itemCount()
        XCTAssert(z==0)
        
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        StickerAssetSpace.reset(title: "measuring...")
        AppCaptionSpace.reset()
        SharedCaptionSpace.reset()
        
        self.measure { // seems to run this 10 times
            // Put the code you want to measure the time of here.
            
            let x = StickerAssetSpace.itemCount()
            
            for _ in 0..<100 {
                let ra = StickerAsset(localurl: URL(string:"http://apple.com")!, options: [])
                StickerAssetSpace.addasset(ra: ra)
            }
            
            let y = AppCaptionSpace.itemCount()
            
            let z = SharedCaptionSpace.itemCount()
            
            let _ = x + y + z
            
        }
    }
    
}
