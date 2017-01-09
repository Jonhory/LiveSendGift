//
//  V15TestVC.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/12/4.
//  Copyright © 2016年 com.wujh. All rights reserved.
//


#import "V15TestVC.h"
#import "LiveGiftShowCustom.h"

#import "MJExtension.h"


#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define SCREEN [UIScreen mainScreen].bounds.size
static NSInteger kTag = 200;

@implementation UIColor (RandomColor)

+(UIColor *) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
@end

@interface V15TestVC ()

@property (nonatomic ,weak) LiveGiftShowCustom * customGiftShow;

@property (nonatomic ,strong) NSArray <ZYGiftListModel *>* giftArr;
@property (nonatomic ,strong) NSArray * giftDataSource;

@property (nonatomic ,strong) UserModel * oldUser;

@end

@implementation V15TestVC

- (UserModel *)oldUser{
    if (!_oldUser) {
        _oldUser = [UserModel random];
    }
    return _oldUser;
}

- (LiveGiftShowCustom *)customGiftShow{
    if (!_customGiftShow) {
        _customGiftShow = [LiveGiftShowCustom addToView:self.view];
        [_customGiftShow setMaxGiftCount:5];
        [_customGiftShow enableInterfaceDebug:NO];
    }
    return _customGiftShow;
}

- (UIButton *)createBtnWithTag:(NSInteger)tag title:(NSString *)title maxCount:(NSInteger)maxCount{
    CGFloat btnWidth = (SCREEN.width - 40)/maxCount;
    
    NSInteger number = tag - kTag;
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(20+number * btnWidth, 400, btnWidth, 40)];
    btn.backgroundColor = [UIColor randomColor];
    btn.tag = tag;
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateHighlighted];
    
    [btn addTarget:self action:@selector(v15BtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    return btn;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"V1.5 Test";
    self.view.backgroundColor = RGB(237, 237, 237);
    
    //初始化按钮
    NSArray * titles = @[@"one",@"two",@"three",@"four",@"five"];
    NSInteger maxCount = titles.count;
    for (NSInteger i = 0; i<maxCount; i++) {
        [self createBtnWithTag:i+kTag title:titles[i] maxCount:maxCount];
    }
    
    //初始化数据源
    self.giftArr = [ZYGiftListModel mj_objectArrayWithKeyValuesArray:self.giftDataSource];

    //初始化弹幕视图
    [self customGiftShow];
    
    LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[3] userModel:self.oldUser];
    [self.customGiftShow addLiveGiftShowModel:model];
    // Do any additional setup after loading the view.
}

- (void)v15BtnClicked:(UIButton *)clickedBtn{
    switch (clickedBtn.tag) {
        case 200:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[0] userModel:self.oldUser];
            [self.customGiftShow addLiveGiftShowModel:model];
            break;
        }
        case 201:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[1] userModel:self.oldUser];
            [self.customGiftShow addLiveGiftShowModel:model];
            break;
        }
        case 202:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[2] userModel:self.oldUser];
            [self.customGiftShow addLiveGiftShowModel:model];
            break;
        }
        case 203:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[3] userModel:self.oldUser];
            [self.customGiftShow addLiveGiftShowModel:model];
            break;
        }
        case 204:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[4] userModel:self.oldUser];
            [self.customGiftShow addLiveGiftShowModel:model];
            break;
        }
        default:
            break;
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
                            @{
                                @"name": @"泡泡糖",
                                @"rewardMsg": @"一起吃泡泡糖吧",
                                @"personSort": @"2",
                                @"goldCount": @"8",
                                @"type": @"4",
                                @"picUrl": @"http://ww2.sinaimg.cn/large/c6a1cfeagw1fbksasl9qwj205k05kt8k.jpg",
                                },
                            ];
    }
    return _giftDataSource;
}

- (void)dealloc{
    NSLog(@"delloc V1.5 %@",self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
