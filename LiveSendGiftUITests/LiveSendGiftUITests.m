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

- (void)testV15VCClicked{
    
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"Go TestVC = V1.5"] tap];
    
    XCUIElement *addoldmodelButton = app.buttons[@"addOldModel"];
    [addoldmodelButton tap];
    
    XCUIElement *addnewmodelButton = app.buttons[@"addNewModel"];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    
    
}

- (void)testSecondVCClicked{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"Go TestVC = V1.5"] tap];
    [[[[app.navigationBars[@"V1.5 Test"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
    [app.buttons[@"Go TestVC = V1.4"] tap];
    [[[[app.navigationBars[@"ThirdView"] childrenMatchingType:XCUIElementTypeButton] matchingIdentifier:@"Back"] elementBoundByIndex:0] tap];
    
}

- (void)testV15{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"Go TestVC = V1.5"] tap];
    
    XCUIElement *addoldmodelButton = app.buttons[@"addOldModel"];
    [addoldmodelButton tap];
    
    XCUIElement *addnewmodelButton = app.buttons[@"addNewModel"];
    [addnewmodelButton tap];
    
    XCUIElement *randommodelButton = app.buttons[@"randomModel"];
    [randommodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [randommodelButton tap];
    [randommodelButton tap];
    [randommodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [randommodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [randommodelButton tap];
    [randommodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [randommodelButton tap];
    [randommodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [randommodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [randommodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [randommodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [[[[[app.otherElements containingType:XCUIElementTypeNavigationBar identifier:@"V1.5 Test"] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [addnewmodelButton tap];
    [randommodelButton tap];
    [addnewmodelButton tap];
    [addnewmodelButton tap];
    [addoldmodelButton tap];
    [randommodelButton tap];
    [randommodelButton tap];
    [randommodelButton tap];
    
}

- (void)testThirdVCClicked{
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"Go TestVC = V1.4"] tap];
    
    XCUIElement *btn101Button = app.buttons[@"Btn101"];
    [btn101Button tap];
    [btn101Button tap];
    [btn101Button tap];
    [btn101Button tap];
    [btn101Button tap];
    [btn101Button tap];
    [btn101Button tap];
    [btn101Button tap];
    [btn101Button tap];
    [btn101Button tap];
    [btn101Button tap];
    
    XCUIElement *btn102Button = app.buttons[@"Btn102"];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn101Button tap];
    [btn102Button tap];
    [btn101Button tap];
    [btn102Button tap];
    [btn101Button tap];
    [btn101Button tap];
    [btn102Button tap];
    [btn101Button tap];
    [btn102Button tap];
    [btn101Button tap];
    [btn102Button tap];
    [btn101Button tap];
    [btn102Button tap];
    [btn101Button tap];
    [btn102Button pressForDuration:0.5];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    [btn102Button tap];
    
}

@end
