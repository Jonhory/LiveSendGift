//
//  LiveSendGiftUITests.m
//  LiveSendGiftUITests
//
//  Created by Jonhory on 2016/12/6.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface LiveSendGiftUITests : XCTestCase

@end

@implementation LiveSendGiftUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
   
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testV17 {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"Go TestVC = V1.7"] tap];
    
    XCUIElement *secondButton = app.buttons[@"second"];
    [secondButton tap];
    
    XCUIElement *thirdButton = app.buttons[@"third"];
    [thirdButton tap];
    
    XCUIElement *firstButton = app.buttons[@"first"];
    [firstButton tap];
    [secondButton tap];
    [thirdButton tap];
    
    XCUIElement *fourthButton = app.buttons[@"fourth"];
    [fourthButton tap];
    
    XCUIElement *fifthButton = app.buttons[@"fifth"];
    [fifthButton tap];
    [fourthButton tap];
    [thirdButton tap];
    [secondButton tap];
    [firstButton tap];
    [secondButton tap];
    [thirdButton tap];
    [secondButton tap];
    [firstButton tap];
    [secondButton tap];
    [secondButton tap];
    [thirdButton tap];
    [thirdButton tap];
    [secondButton tap];
    [secondButton tap];
    [secondButton tap];
    [secondButton tap];
    [secondButton tap];
    [secondButton tap];
    [secondButton tap];
    [secondButton tap];
    [secondButton tap];
    [secondButton tap];
    [fourthButton tap];
    [fifthButton tap];
    [fourthButton tap];
    [fifthButton tap];
    [fourthButton tap];
    [fifthButton tap];
    [fourthButton tap];
    [fifthButton tap];
    [fourthButton tap];
    [fifthButton tap];
    [fifthButton tap];
    [fifthButton tap];
    [fifthButton tap];
    [thirdButton tap];
    [thirdButton tap];
    [thirdButton tap];
    
}
@end
