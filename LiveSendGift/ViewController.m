//
//  ViewController.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//


#import "ViewController.h"
#import "ZYGiftListModel.h"
#import "MJExtension.h"
#import "LiveGiftShowView.h"

#import "SecondViewController.h"


@implementation UIColor (RandomColor)

+(UIColor *) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
@end

@interface ViewController ()

@property (nonatomic ,strong) NSArray * giftDataSource;
@property (nonatomic ,strong) NSArray <ZYGiftListModel *>* giftArr;
@property (nonatomic ,strong) NSMutableArray <LiveGiftShowView *> * views;

@property (nonatomic ,weak) LiveGiftShowView * giftViewFirst;
@property (nonatomic ,weak) LiveGiftShowView * giftViewSecond;
@property (nonatomic ,assign) NSInteger giftSendTimeFirst;
@property (nonatomic ,assign) NSInteger giftSendTimeSecond;

@end

@implementation ViewController

- (LiveGiftShowView *)giftViewFirst{
    if (!_giftViewFirst) {
        CGFloat Y = 100;
        if (self.giftSendTimeSecond > 0) {
            Y = 200;
        }
        LiveGiftShowView * v = [[LiveGiftShowView alloc]initWithFrame:CGRectMake(0, Y, 0, 0)];
        __weak __typeof(self)weakSelf = self;
        v.liveGiftShowViewTimeOut = ^(){
            weakSelf.giftSendTimeFirst = 0;
        };
        [self.view addSubview:v];
        _giftViewFirst = v;
    }
    return _giftViewFirst;
}

- (LiveGiftShowView *)giftViewSecond{
    if (!_giftViewSecond) {
        CGFloat Y = 100;
        if (self.giftSendTimeFirst > 0) {
            Y = 200;
        }
        LiveGiftShowView * v = [[LiveGiftShowView alloc]initWithFrame:CGRectMake(0, Y, 0, 0)];
        __weak __typeof(self)weakSelf = self;
        v.liveGiftShowViewTimeOut = ^(){
            weakSelf.giftSendTimeSecond = 0;
        };
        [self.view addSubview:v];
        _giftViewSecond = v;
    }
    return _giftViewSecond;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.giftSendTimeFirst = 0;
    self.giftSendTimeSecond = 0;
    
    self.views = [[NSMutableArray alloc]init];
    /// NSString *jsonStr = [cache getStringWithKey:JR_Cache_Key_GiftList];
    self.giftArr = [ZYGiftListModel mj_objectArrayWithKeyValuesArray:self.giftDataSource];
    NSLog(@"%@",self.giftArr);
//    self.giftViewFirst.model = self.giftArr[1];
//    self.giftViewSecond.model = self.giftArr[2];
//
    
    
    
//    for (int i = 0; i<self.giftArr.count; i++) {
//        LiveGiftShowView * vv = [[LiveGiftShowView alloc]initWithFrame:CGRectMake(0, (23+44)*i, 0, 0)];
//        vv.model = self.giftArr[i];
//        [vv changeGiftNumber:arc4random()%100000];
////        vv.backgroundColor = [UIColor randomColor];
//        [self.view addSubview:vv];
//        [_views addObject:vv];
//    }
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(300, 200, 50, 50)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton * btn2 = [[UIButton alloc]initWithFrame:CGRectMake(300, 300, 50, 50)];
    btn2.backgroundColor = [UIColor blueColor];
    [btn2 addTarget:self action:@selector(btnClick2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)btnClick2{
    
    [self liveSendTimeMoreAndMore];

    self.giftViewFirst.model = self.giftArr[1];
    [self.giftViewFirst changeGiftNumber:self.giftSendTimeFirst+=1];
}

- (void)btnClick3{
    [self liveSendTimeMoreAndMore];
    
    self.giftViewSecond.model = self.giftArr[2];
    [self.giftViewSecond changeGiftNumber:self.giftSendTimeSecond+=1];
    
}

- (void)liveSendTimeMoreAndMore{
    if (self.giftSendTimeSecond == 0 || self.giftSendTimeFirst == 0) {
        return;
    }
    
    if (self.giftSendTimeSecond > self.giftSendTimeFirst) {
        [UIView animateWithDuration:0.5 animations:^{
            self.giftViewFirst.transform = CGAffineTransformMakeTranslation(0, 100);
            self.giftViewSecond.transform = CGAffineTransformMakeTranslation(0, -100);
        }];
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            self.giftViewFirst.transform = CGAffineTransformIdentity;
            self.giftViewSecond.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)btnClick{
    for (LiveGiftShowView * vv in _views) {
        [vv changeGiftNumber:arc4random()%100];
        [UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
            vv.transform = CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0);
        } completion:^(BOOL finished) {
            if (finished) {
                [vv removeFromSuperview];
                [_views removeObject:vv];
            }
        }];
    }
    
    if (_views.count < 1) {
        for (int i = 0; i<self.giftArr.count; i++) {
            LiveGiftShowView * vv = [[LiveGiftShowView alloc]initWithFrame:CGRectMake(0, (23+44)*i, 0, 0)];
            vv.model = self.giftArr[i];
            [vv changeGiftNumber:arc4random()%100000];
            //        vv.backgroundColor = [UIColor randomColor];
            [self.view addSubview:vv];
            [_views addObject:vv];
        }
    }
}

- (NSArray *)giftDataSource{
    if (!_giftDataSource) {
        _giftDataSource = @[
                            @{
                                @"name": @"松果",
                                @"rewardMsg": @"扔出一颗松果",
                                @"personSort": @"0",
                                @"goldCount": @"3",
                                @"type": @"0",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/songguo"
                                },
                            @{
                                @"name": @"花束",
                                @"rewardMsg": @"献上一束花",
                                @"personSort": @"6",
                                @"goldCount": @"66",
                                @"type": @"1",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/flower"
                                },
                            @{
                                @"name": @"果汁",
                                @"rewardMsg": @"递上果汁",
                                @"personSort": @"3",
                                @"goldCount": @"18",
                                @"type": @"2",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/juice"
                                },
                            @{
                                @"name": @"棒棒糖",
                                @"rewardMsg": @"递上棒棒糖",
                                @"personSort": @"2",
                                @"goldCount": @"8",
                                @"type": @"3",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/lollipop"
                                },
                            @{
                                @"name": @"松鼠",
                                @"rewardMsg": @"扔出一只松鼠",
                                @"personSort": @"8",
                                @"goldCount": @"88",
                                @"type": @"10",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/songsu"
                                },
                            @{
                                @"name": @"跑车",
                                @"rewardMsg": @"开豪车载走主播",
                                @"personSort": @"10",
                                @"goldCount": @"369",
                                @"type": @"7",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/roadster"
                                },
                            @{
                                @"name": @"666",
                                @"rewardMsg": @"抛出666",
                                @"personSort": @"1",
                                @"goldCount": @"6",
                                @"type": @"6",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/six"
                                },
                            @{
                                @"name": @"草泥马",
                                @"rewardMsg": @"扔出一只草泥马",
                                @"personSort": @"9",
                                @"goldCount": @"208",
                                @"type": @"4",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/caonima"
                                },
                            @{
                                @"name": @"游轮",
                                @"rewardMsg": @"开游轮带走主播",
                                @"personSort": @"11",
                                @"goldCount": @"1888",
                                @"type": @"8",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/pulley"
                                },
                            @{
                                @"name": @"奖章",
                                @"rewardMsg": @"送上奖章",
                                @"personSort": @"4",
                                @"goldCount": @"36",
                                @"type": @"9",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/medal"
                                },
                            @{
                                @"name": @"巧克力",
                                @"rewardMsg": @"献上巧克力",
                                @"personSort": @"7",
                                @"goldCount": @"69",
                                @"type": @"5",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/chocolate"
                                },
                            @{
                                @"name": @"盐袋",
                                @"rewardMsg": @"喂主播盐袋",
                                @"personSort": @"5",
                                @"goldCount": @"48",
                                @"type": @"11",
                                @"picUrl": @"http://cache-img1.51songguo.com/image/gift/salt"
                                }
                            ];
    }
    return _giftDataSource;
}

- (void)dealloc{
    NSLog(@"dddd  %@",self);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//[button sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@_live@2x.png",info.picUrl]] forState:UIControlStateNormal placeholderImage:nil];

@end
