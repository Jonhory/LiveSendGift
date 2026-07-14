//
//  LiveSendGiftTests.m
//  LiveSendGiftTests
//
//  Created by Jonhory on 2016/12/6.
//  Copyright © 2016年 com.wujh. All rights reserved.
//
//  V2.0 新增：核心队列/计数逻辑的单元测试。
//  历史 bug（#17 #19 #20 #21）全部出在这部分纯逻辑上，用单测防回归。
//

#import "../LiveSendGift/LiveGiftShowView/LiveGiftShowCustom.h"
#import "../LiveSendGift/LiveGiftShowView/LiveGiftShowNumberView.h"
#import "../LiveSendGift/LiveGiftShowView/LiveGiftShowView.h"
#import <XCTest/XCTest.h>

@interface LiveSendGiftTests : XCTestCase

@property (nonatomic, strong) UIView *hostView;
@property (nonatomic, strong) LiveGiftShowCustom *giftShow;

@end

@implementation LiveSendGiftTests

- (void)setUp {
    [super setUp];
    self.hostView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    self.giftShow = [LiveGiftShowCustom addToView:self.hostView y:0];
}

- (LiveGiftShowModel *)modelWithUserId:(NSString *)userId name:(NSString *)name giftType:(NSString *)type {
    LiveUserModel *user = [[LiveUserModel alloc] init];
    user.userId = userId;
    user.name = name;
    LiveGiftListModel *gift = [[LiveGiftListModel alloc] init];
    gift.type = type;
    gift.name = @"测试礼物";
    return [LiveGiftShowModel giftModel:gift userModel:user];
}

- (NSArray<LiveGiftShowView *> *)visibleBanners {
    NSMutableArray *banners = [NSMutableArray array];
    for (UIView *sub in self.giftShow.subviews) {
        if ([sub isKindOfClass:[LiveGiftShowView class]]) {
            [banners addObject:sub];
        }
    }
    return banners;
}

/// 数字视图：显式自增替代旧的副作用 getter，计数语义必须稳定
- (void)testNumberViewIncrease {
    LiveGiftShowNumberView *numberView = [[LiveGiftShowNumberView alloc] init];
    [numberView resetNumber:5];
    XCTAssertEqual([numberView increaseNumber], 5, @"重置后首次自增应返回起点值");
    XCTAssertEqual([numberView increaseNumber], 6);
    XCTAssertEqual([numberView currentNumber], 6, @"currentNumber 应为最后一次自增返回的值");
    [numberView resetNumber:1];
    XCTAssertEqual([numberView increaseNumber], 1, @"重置后计数应重新开始");
}

/// 同名用户必须靠 userId 区分，不能被合并成一条弹幕
- (void)testSameNameDifferentUserIdCreatesTwoBanners {
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"1001" name:@"小明" giftType:@"0"]];
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"1002" name:@"小明" giftType:@"0"]];
    XCTAssertEqual([self visibleBanners].count, 2, @"同名不同 userId 应产生两条弹幕");
}

/// 同一用户同一礼物应合并为一条弹幕并计数
- (void)testSameUserSameGiftMergesIntoOneBanner {
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"1001" name:@"小明" giftType:@"0"]];
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"1001" name:@"小明" giftType:@"0"]];
    NSArray<LiveGiftShowView *> *banners = [self visibleBanners];
    XCTAssertEqual(banners.count, 1);
    XCTAssertEqual([banners.firstObject.numberView currentNumber], 2, @"两次添加应计数到 2");
}

/// 轨道交换：更新计数后，礼物数大的弹幕应排在上面（历史 bug 高发区）
- (void)testRailwaySortByGiftCount {
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"1" name:@"a" giftType:@"0"] showNumber:1];
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"2" name:@"b" giftType:@"0"] showNumber:5];
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"3" name:@"c" giftType:@"0"] showNumber:3];

    // 更新已有弹幕触发排序：user1 从 1 -> 2
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"1" name:@"a" giftType:@"0"]];

    NSArray *showViewArr = [self.giftShow valueForKey:@"showViewArr"];
    NSMutableArray *counts = [NSMutableArray array];
    for (id obj in showViewArr) {
        if ([obj isKindOfClass:[LiveGiftShowView class]]) {
            [counts addObject:@([[(LiveGiftShowView *)obj numberView] currentNumber])];
        }
    }
    NSArray *expected = @[ @5, @3, @2 ];
    XCTAssertEqualObjects(counts, expected, @"槽位应按计数降序排列");
}

/// 弹幕移除后空槽补位，新弹幕复用空出的轨道
- (void)testFreedSlotIsCompactedAndReused {
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"1" name:@"a" giftType:@"0"] showNumber:1];
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"2" name:@"b" giftType:@"0"] showNumber:3];
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"3" name:@"c" giftType:@"0"] showNumber:2];

    // 模拟第 0 槽弹幕超时移除
    NSArray *showViewArr = [self.giftShow valueForKey:@"showViewArr"];
    LiveGiftShowView *first = showViewArr.firstObject;
    XCTAssertTrue([first isKindOfClass:[LiveGiftShowView class]]);
    first.liveGiftShowViewTimeOut(first);

    showViewArr = [self.giftShow valueForKey:@"showViewArr"];
    NSMutableArray *counts = [NSMutableArray array];
    for (id obj in showViewArr) {
        if ([obj isKindOfClass:[LiveGiftShowView class]]) {
            [counts addObject:@([[(LiveGiftShowView *)obj numberView] currentNumber])];
        }
    }
    NSArray *expected = @[ @3, @2 ];
    XCTAssertEqualObjects(counts, expected, @"剩余弹幕应前移补位并保持降序");

    // 新弹幕占用空槽
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"9" name:@"d" giftType:@"0"]];
    NSInteger viewCount = 0;
    for (id obj in [self.giftShow valueForKey:@"showViewArr"]) {
        if ([obj isKindOfClass:[LiveGiftShowView class]]) {
            viewCount++;
        }
    }
    XCTAssertEqual(viewCount, 3, @"新弹幕应复用空出的轨道");
}

/// 轨道数量上限 + 队列模式下同 key 等待模型合并（issue #19/#21 的回归防线）
- (void)testMaxRailwayCountCapAndQueueMerge {
    self.giftShow.addMode = LiveGiftAddModeQueue;
    self.giftShow.maxRailwayCount = 2;

    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"1" name:@"a" giftType:@"0"]];
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"2" name:@"b" giftType:@"0"]];
    XCTAssertEqual([self visibleBanners].count, 2, @"最多显示 maxRailwayCount 条");

    // 第三个用户进入等待队列
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"3" name:@"c" giftType:@"0"]];
    NSArray *waitQueue = [self.giftShow valueForKey:@"waitQueueArr"];
    XCTAssertEqual([self visibleBanners].count, 2);
    XCTAssertEqual(waitQueue.count, 1, @"超出上限的弹幕应进入等待队列");

    // 同 key 再来一条，应合并次数而不是排两条
    [self.giftShow addLiveGiftShowModel:[self modelWithUserId:@"3" name:@"c" giftType:@"0"]];
    waitQueue = [self.giftShow valueForKey:@"waitQueueArr"];
    XCTAssertEqual(waitQueue.count, 1, @"同 key 等待模型应合并");
    LiveGiftShowModel *merged = waitQueue.firstObject;
    XCTAssertEqual(merged.toNumber, 2, @"合并后 toNumber 应累加");
}

/// 注入自定义图片加载器后，头像与礼物图都应走注入的加载器（SDWebImage 解耦）
- (void)testInjectedImageLoaderIsUsed {
    NSMutableArray<NSString *> *loadedUrls = [NSMutableArray array];
    self.giftShow.webImageLoader = ^(UIImageView *imageView, NSString *urlString, UIImage *placeholder) {
        [loadedUrls addObject:urlString ?: @"<nil>"];
        imageView.image = placeholder;
    };

    LiveGiftShowModel *model = [self modelWithUserId:@"1001" name:@"小明" giftType:@"0"];
    model.user.iconUrl = @"https://example.com/icon.png";
    model.giftModel.picUrl = @"https://example.com/gift.png";
    [self.giftShow addLiveGiftShowModel:model];

    XCTAssertEqual(loadedUrls.count, 2, @"头像和礼物图都应通过注入的加载器加载");
    XCTAssertTrue([loadedUrls containsObject:@"https://example.com/icon.png"]);
    XCTAssertTrue([loadedUrls containsObject:@"https://example.com/gift.png"]);
}

/// 公开 API 从后台线程调用不应崩溃，且弹幕最终正常上屏
- (void)testBackgroundThreadAddIsSafe {
    XCTestExpectation *exp = [self expectationWithDescription:@"background add"];
    LiveGiftShowModel *model = [self modelWithUserId:@"1001" name:@"小明" giftType:@"0"];
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self.giftShow addLiveGiftShowModel:model];
        dispatch_async(dispatch_get_main_queue(), ^{
            [exp fulfill];
        });
    });
    [self waitForExpectations:@[ exp ] timeout:2];
    XCTAssertEqual([self visibleBanners].count, 1, @"后台线程调用应自动转主队列并正常上屏");
}

/// issue #17：同 key 并发连击应合并进已有定时器，而不是叠加多个定时器导致数字失控
- (void)testAnimatedTimerMergeForSameKey {
    // toNumber 拉长到 20，保证第二发连击到来时首个定时器仍在存活期（20 ticks × 0.05s ≈ 1s）
    LiveGiftShowModel *first = [self modelWithUserId:@"1001" name:@"小明" giftType:@"0"];
    first.toNumber = 20;
    first.interval = 0.05;
    [self.giftShow animatedWithGiftModel:first];

    // 等首个 tick 上屏，弹幕视图建立
    XCTestExpectation *shown = [self expectationWithDescription:@"first tick"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [shown fulfill];
    });
    [self waitForExpectations:@[ shown ] timeout:2];
    XCTAssertEqual([self visibleBanners].count, 1);
    XCTAssertNotNil(first.animatedTimer, @"首个连击定时器应仍在运行");

    // 同 key 第二次连击：应合并进 first 的定时器
    LiveGiftShowModel *second = [self modelWithUserId:@"1001" name:@"小明" giftType:@"0"];
    second.toNumber = 5;
    second.interval = 0.05;
    [self.giftShow animatedWithGiftModel:second];

    XCTAssertEqual(first.toNumber, 25, @"同 key 连击应合并 toNumber");
    XCTAssertNil(second.animatedTimer, @"不应为第二个模型开新定时器");

    // 等定时器跑完：最终计数应恰好为 25，且定时器已释放（不会“停不下来”）
    XCTestExpectation *finished = [self expectationWithDescription:@"timer finished"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [finished fulfill];
    });
    [self waitForExpectations:@[ finished ] timeout:5];

    XCTAssertNil(first.animatedTimer, @"连击结束后定时器应释放");
    XCTAssertEqual([[self visibleBanners].firstObject.numberView currentNumber], 25, @"最终计数应恰好等于合并后的 toNumber");
}

@end
