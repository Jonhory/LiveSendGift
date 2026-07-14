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
    self.continueAfterFailure = NO;
    [[[XCUIApplication alloc] init] launch];
}

/// 弹幕视图不应被导航栏返回按钮遮挡
- (void)testGiftBannerBelowNavBar {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"左出现 左消失 自上而下 队列模式"] tap];

    // 进入页面后自动发送弹幕，等待第一条出现
    XCUIElement *msg = app.staticTexts[@"扔出一颗松果"];
    XCTAssertTrue([msg waitForExistenceWithTimeout:5], @"弹幕未出现");

    // 等出现动画结束再取坐标
    sleep(1);

    XCUIElement *backButton = app.navigationBars.buttons.firstMatch;
    CGFloat navBottom = CGRectGetMaxY(backButton.frame);
    // sendLabel 底部距弹幕底部 9pt，弹幕高 44pt，反推弹幕顶部
    CGFloat bannerTop = CGRectGetMaxY(msg.frame) + 9 - 44;

    XCTAttachment *att = [XCTAttachment attachmentWithScreenshot:[XCUIScreen mainScreen].screenshot];
    att.name = @"gift-banner";
    att.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:att];

    XCTAssertGreaterThanOrEqual(bannerTop, navBottom, @"弹幕(top=%.1f)被返回按钮(bottom=%.1f)遮挡", bannerTop, navBottom);
}

/// Swift 版演示页应正常展示弹幕（LiveSendGiftSwift 集成验证）
- (void)testSwiftDemoShowsBanner {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"Swift 版演示 队列模式"] tap];

    // 进入页面后自动发送弹幕
    XCUIElement *msg = app.staticTexts[@"扔出一颗松果"];
    XCTAssertTrue([msg waitForExistenceWithTimeout:5], @"Swift 版弹幕未出现");
}

/// 固定轨道模式下"同时添加多条"按钮应正常响应（V2.0 修复）
- (void)testFixedRailwayBatchAddButtonResponds {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.buttons[@"直接出现 左消失 自上而下 队列模式 轨道固定"] tap];

    // 该模式不自动发送，点按钮后弹幕才出现
    [app.buttons[@"同时添加多条"] tap];

    XCUIElement *msg = app.staticTexts[@"扔出一颗松果"];
    XCTAssertTrue([msg waitForExistenceWithTimeout:5], @"点击按钮后弹幕未出现，按钮未响应");
}

@end
