//
//  ThirdViewController.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "ThirdViewController.h"
#import "LiveGiftShow.h"
#define SCREEN [UIScreen mainScreen].bounds.size

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
        _user1.iconUrl = @"http://ww1.sinaimg.cn/large/c6a1cfeagw1fbksa4vf7uj205k05kaa0.jpg";
    }
    return _user1;
}

- (UserModel *)user2{
    if (!_user2) {
        _user2 = [UserModel random];
        _user2.name = @"热热热热";
        _user2.iconUrl = @"http://ww3.sinaimg.cn/large/c6a1cfeagw1fbks9dl7ryj205k05kweo.jpg";
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
    //初始化数据源
    self.giftArr = [ZYGiftListModel mj_objectArrayWithKeyValuesArray:self.giftDataSource];
    
    [self.view addSubview:self.btn1];
    [self.view addSubview:self.btn2];
    
    //一进来的时候显示一个
    LiveGiftShowModel * listModel = [LiveGiftShowModel giftModel:self.giftArr[3] userModel:[UserModel random]];
    [self.giftShow addGiftListModel:listModel];
}


- (void)bbb:(UIButton *)btn{
    if (btn.tag == 101) {
//        for (int i=0; i<99; i++) {
            LiveGiftShowModel * listModel = [LiveGiftShowModel giftModel:self.giftArr[1] userModel:self.user1];
            [self.giftShow addGiftListModel:listModel];
//        }
    }else{
        LiveGiftShowModel * listModel = [LiveGiftShowModel giftModel:self.giftArr[2] userModel:self.user1];
        [self.giftShow addGiftListModel:listModel];
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self bbb:btn];
//        });
    }
}

- (UIButton *)btn1{
    if (!_btn1) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(10, SCREEN.height - 60, 150, 50)];
        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:@"Btn101" forState:UIControlStateNormal];
        [self.view addSubview:btn];
        btn.tag = 101;
        [btn addTarget:self action:@selector(bbb:) forControlEvents:UIControlEventTouchUpInside];
        _btn1 = btn;
    }
    return _btn1;
}

- (UIButton *)btn2{
    if (!_btn2) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN.width/2, SCREEN.height - 60, 150, 50)];
        btn.backgroundColor = [UIColor blueColor];
        [btn setTitle:@"Btn102" forState:UIControlStateNormal];
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
                                @"picUrl": @"http://ww3.sinaimg.cn/large/c6a1cfeagw1fbks9dl7ryj205k05kweo.jpg",
                                },
                            @{
                                @"name": @"花束",
                                @"rewardMsg": @"献上一束花",
                                @"personSort": @"6",
                                @"goldCount": @"66",
                                @"type": @"1",
                                @"picUrl": @"http://ww1.sinaimg.cn/large/c6a1cfeagw1fbksa4vf7uj205k05kaa0.jpg",
                                },
                            @{
                                @"name": @"果汁",
                                @"rewardMsg": @"递上果汁",
                                @"personSort": @"3",
                                @"goldCount": @"18",
                                @"type": @"2",
                                @"picUrl": @"http://ww2.sinaimg.cn/large/c6a1cfeagw1fbksajipb8j205k05kjri.jpg",
                                },
                            @{
                                @"name": @"棒棒糖",
                                @"rewardMsg": @"递上棒棒糖",
                                @"personSort": @"2",
                                @"goldCount": @"8",
                                @"type": @"3",
                                @"picUrl": @"http://ww2.sinaimg.cn/large/c6a1cfeagw1fbksasl9qwj205k05kt8k.jpg",
                                },
                            ];
    }
    return _giftDataSource;
}

- (void)dealloc{
    NSLog(@"Dealloc testVC:%@",self);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
