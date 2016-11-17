//
//  ThirdViewController.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "ThirdViewController.h"
#import "LiveGiftShow.h"

#import "MJExtension.h"


@interface ThirdViewController ()

@property (nonatomic ,weak) LiveGiftShow * giftShow;

@property (nonatomic ,weak) UIButton * btn1;
@property (nonatomic ,weak) UIButton * btn2;
@property (nonatomic ,strong) NSArray <ZYGiftListModel *>* giftArr;
@property (nonatomic ,strong) NSArray * giftDataSource;

@property (nonatomic ,strong) UserModel * user1;
@property (nonatomic ,strong) UserModel * user2;

@end

@implementation ThirdViewController

- (UserModel *)user1{
    if (!_user1) {
        _user1 = [UserModel random];
        _user1.name = @"依依依依";
        _user1.iconUrl = @"http://cache-img1.51songguo.com/image/gift/songguo_live@2x.png";
    }
    return _user1;
}

- (UserModel *)user2{
    if (!_user2) {
        _user2 = [UserModel random];
        _user2.name = @"热热热热";
        _user2.iconUrl = @"http://cache-img1.51songguo.com/image/gift/flower_live@2x.png";
    }
    return _user2;
}

- (LiveGiftShow *)giftShow{
    if (!_giftShow) {
        LiveGiftShow * giftShow = [[LiveGiftShow alloc]init];
        [self.view addSubview:giftShow];
        _giftShow = giftShow;
        [giftShow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@244);
            make.height.equalTo(@50);
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.view.mas_top).offset(100);
        }];
    }
    return _giftShow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.giftArr = [ZYGiftListModel mj_objectArrayWithKeyValuesArray:self.giftDataSource];
    [self.view addSubview:self.btn1];
    [self.view addSubview:self.btn2];
    
    LiveGiftShowModel * listModel = [LiveGiftShowModel giftModel:self.giftArr[3] userModel:[UserModel random]];
    [self.giftShow addGiftListModel:listModel];
    
    
    NSArray * a = @[@"12",@"2",@"3",@"1"];
    NSLog(@"xx : %zi",[a indexOfObject:@"1"]);
}


- (void)bbb:(UIButton *)btn{
    if (btn.tag == 101) {
        for (int i=0; i<99; i++) {
            LiveGiftShowModel * listModel = [LiveGiftShowModel giftModel:self.giftArr[1] userModel:self.user1];
            [self.giftShow addGiftListModel:listModel];
        }
    }else{
        LiveGiftShowModel * listModel = [LiveGiftShowModel giftModel:self.giftArr[2] userModel:self.user2];
        [self.giftShow addGiftListModel:listModel];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self bbb:btn];
        });
    }
}

- (UIButton *)btn1{
    if (!_btn1) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(50, 600, 100, 50)];
        btn.backgroundColor = [UIColor redColor];
        //        btn.center = self.view.center;
        [self.view addSubview:btn];
        btn.tag = 101;
        [btn addTarget:self action:@selector(bbb:) forControlEvents:UIControlEventTouchUpInside];
        _btn1 = btn;
    }
    return _btn1;
}

- (UIButton *)btn2{
    if (!_btn2) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(200, 600, 100, 50)];
        btn.backgroundColor = [UIColor blueColor];
        //        btn.center = self.view.center;
        [self.view addSubview:btn];
        btn.tag = 102;
        [btn addTarget:self action:@selector(bbb:) forControlEvents:UIControlEventTouchUpInside];
        _btn2 = btn;
    }
    return _btn2;
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
    NSLog(@"%@",self);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
