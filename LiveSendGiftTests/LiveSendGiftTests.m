//
//  LiveSendGiftTests.m
//  LiveSendGiftTests
//
//  Created by Jonhory on 2016/12/6.
//  Copyright © 2016年 com.wujh. All rights reserved.
//
/*
XCTFail(format…) 生成一个失败的测试；

XCTAssertNil(a1, format...)为空判断，a1为空时通过，反之不通过；

XCTAssertNotNil(a1, format…)不为空判断，a1不为空时通过，反之不通过；

XCTAssert(expression, format...)当expression求值为TRUE时通过；

XCTAssertTrue(expression, format...)当expression求值为TRUE时通过；

XCTAssertFalse(expression, format...)当expression求值为False时通过；

XCTAssertEqualObjects(a1, a2, format...)判断相等，[a1 isEqual:a2]值为TRUE时通过，其中一个不为空时，不通过；

XCTAssertNotEqualObjects(a1, a2, format...)判断不等，[a1 isEqual:a2]值为False时通过；

XCTAssertEqual(a1, a2, format...)判断相等（当a1和a2是 C语言标量、结构体或联合体时使用,实际测试发现NSString也可以）；

XCTAssertNotEqual(a1, a2, format...)判断不等（当a1和a2是 C语言标量、结构体或联合体时使用）；

XCTAssertEqualWithAccuracy(a1, a2, accuracy, format...)判断相等，（double或float类型）提供一个误差范围，当在误差范围（+/-accuracy）以内相等时通过测试；

XCTAssertNotEqualWithAccuracy(a1, a2, accuracy, format...) 判断不等，（double或float类型）提供一个误差范围，当在误差范围以内不等时通过测试；

XCTAssertThrows(expression, format...)异常测试，当expression发生异常时通过；反之不通过；（很变态） XCTAssertThrowsSpecific(expression, specificException, format...) 异常测试，当expression发生specificException异常时通过；反之发生其他异常或不发生异常均不通过；

XCTAssertThrowsSpecificNamed(expression, specificException, exception_name, format...)异常测试，当expression发生具体异常、具体异常名称的异常时通过测试，反之不通过；

XCTAssertNoThrow(expression, format…)异常测试，当expression没有发生异常时通过测试；

XCTAssertNoThrowSpecific(expression, specificException, format...)异常测试，当expression没有发生具体异常、具体异常名称的异常时通过测试，反之不通过；

XCTAssertNoThrowSpecificNamed(expression, specificException, exception_name, format...)异常测试，当expression没有发生具体异常、具体异常名称的异常时通过测试，反之不通过

特别注意下XCTAssertEqualObjects和XCTAssertEqual。

XCTAssertEqualObjects(a1, a2, format...)的判断条件是[a1 isEqual:a2]是否返回一个YES。

XCTAssertEqual(a1, a2, format...)的判断条件是a1 == a2是否返回一个YES。

文／SOI（简书作者）
原文链接：http://www.jianshu.com/p/c3fe84fa7a13
著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
*/

#import <XCTest/XCTest.h>
#import "LiveGiftShowModel.h"

@interface LiveSendGiftTests : XCTestCase
@property (nonatomic ,strong) NSMutableArray * showViewArr;
@end

@implementation LiveSendGiftTests

- (void)setUp {
    [super setUp];
    //每次测试前调用，可以在测试之前创建在test case方法中需要用到的一些对象等
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.showViewArr = [[NSMutableArray alloc]init];
    [self.showViewArr addObject:@"kk"];
    [self.showViewArr addObject:@"kk"];
    [self.showViewArr addObject:@"kk"];
    [self.showViewArr addObject:@11];
    [self.showViewArr addObject:@33];
    [self.showViewArr addObject:@"kk"];
    [self.showViewArr addObject:@22];


}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    //每次测试结束时调用tearDown方法
    
    
    
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    //1：定义变量和预期，2：执行方法得到实际值，3：断言
    LiveGiftShowModel * model = [[LiveGiftShowModel alloc]init];
    NSString * key = [self getDictKey:model];
    
    XCTAssertNotNil(key,@"key is nil");
    
}

- (NSString *)getDictKey:(LiveGiftShowModel *)model{
    //默认以 用户名+礼物类型 为key
    NSString * key = [NSString stringWithFormat:@"%@%@",model.user.name,model.giftModel.type];
    return key;
}


- (void)testSort{
    NSLog(@"begin sort == %@",self.showViewArr);
    for (int i = 0; i < self.showViewArr.count; i++) {
        id current = self.showViewArr[i];
        if ([current isKindOfClass:[NSString class]]){
            if (i+1 < self.showViewArr.count) {
                [self searchLiveShowViewFrom:i+1];
            }
        }
    }
     NSLog(@"end Sort == %@",self.showViewArr);
}
- (void)searchLiveShowViewFrom:(int)i{
    for (int j = i; j < self.showViewArr.count; j++) {
        id  next = self.showViewArr[j];
        if (![next isKindOfClass:[NSString class]]) {
//            next.index = i-1;
            [self.showViewArr exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
            NSLog(@"i-1 == %zi , j = %zi",i-1,j);
            return;
        }
    }
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        //性能测试方法，通过测试block中方法执行的时间，比对设定的标准值和偏差觉得是否可以通过测试
        // Put the code you want to measure the time of here.
    }];
}

@end
