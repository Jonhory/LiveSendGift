//
//  V15TestVC.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/12/4.
//  Copyright © 2016年 com.wujh. All rights reserved.
//


#import "TestVC.h"
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

@interface TestVC ()<LiveGiftShowCustomDelegate>

@property (nonatomic ,weak) LiveGiftShowCustom * customGiftShow;

@property (nonatomic ,strong) NSArray <LiveGiftListModel *>* giftArr;
@property (nonatomic ,strong) NSArray * giftDataSource;

@property (nonatomic, strong) LiveUserModel *firstUser;
@property (nonatomic, strong) LiveUserModel *secondUser;
@property (nonatomic, strong) LiveUserModel *thirdUser;
@property (nonatomic, strong) LiveUserModel *fourthUser;
@property (nonatomic, strong) LiveUserModel *fifthUser;

@end

@implementation TestVC

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[3] userModel:self.firstUser];
    [self.customGiftShow addLiveGiftShowModel:model];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"V1.9 Test";
    self.view.backgroundColor = RGB(237, 237, 237);
    
    //初始化按钮
    NSArray * titles = @[@"first",@"second",@"third",@"fourth",@"fifth"];
    NSInteger maxCount = titles.count;
    for (NSInteger i = 0; i<maxCount; i++) {
        [self createBtnWithTag:i+kTag title:titles[i] maxCount:maxCount];
    }
    
    //初始化数据源
    self.giftArr = [LiveGiftListModel mj_objectArrayWithKeyValuesArray:self.giftDataSource];

    //初始化弹幕视图
    [self customGiftShow];
    
    [self animateBtn];
}

- (void)animateBtn{
    UIButton * animateBtn = [self createBtnWithTag:205 title:@"sixth" maxCount:3];
    animateBtn.center = CGPointMake(SCREEN.width/2, SCREEN.height - 80);
}

/*
 以下是测试方法：
 分别是三种添加视图的方法
 animatedWithGiftModel:   从1开始动画展示到 model.toNumber 的效果，会累加；
 addLiveGiftShowModel:   普通的从1显示礼物视图，会+=1；
 addLiveGiftShowModel: showNumber: 普通的礼物显示视图，指定显示特定数字。
 */

- (void)v15BtnClicked:(UIButton *)clickedBtn{
    switch (clickedBtn.tag) {
        case 200:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[0] userModel:self.firstUser];
            model.toNumber = 8;
            model.interval = 0.15;
            [self.customGiftShow animatedWithGiftModel:model];
            break;
        }
        case 201:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[1] userModel:self.secondUser];
            [self.customGiftShow addLiveGiftShowModel:model];
            break;
        }
        case 202:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[2] userModel:self.thirdUser];
            [self.customGiftShow addLiveGiftShowModel:model showNumber:99];
            break;
        }
        case 203:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[3] userModel:self.fourthUser];
            model.toNumber = 3;
            [self.customGiftShow animatedWithGiftModel:model];
            break;
        }
        case 204:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[4] userModel:self.fifthUser];
            model.toNumber = 2;
            [self.customGiftShow animatedWithGiftModel:model];
            break;
        }
        case 205:{
            LiveGiftShowModel * model = [LiveGiftShowModel giftModel:self.giftArr[4] userModel:self.fifthUser];
            [self.customGiftShow animatedWithGiftModel:model];
            break;
        }
        default:
            break;
    }
}

/**
 弹幕移除回调代理

 @param showModel 数据模型
 */
- (void)giftDidRemove:(LiveGiftShowModel *)showModel {
    WLog(@"用户：%@ 送出了 %li 个 %@", showModel.user.name, showModel.currentNumber, showModel.giftModel.name);
}

/*
 礼物视图支持很多配置属性，开发者按需选择。
 */
- (LiveGiftShowCustom *)customGiftShow{
    if (!_customGiftShow) {
        _customGiftShow = [LiveGiftShowCustom addToView:self.view];
        _customGiftShow.addMode = LiveGiftAddModeAdd;
        [_customGiftShow setMaxGiftCount:3];
        [_customGiftShow setShowMode:LiveGiftShowModeFromTopToBottom];
        [_customGiftShow setAppearModel:LiveGiftAppearModeLeft];
        [_customGiftShow setHiddenModel:LiveGiftHiddenModeNone];
        [_customGiftShow enableInterfaceDebug:YES];
        _customGiftShow.delegate = self;
    }
    return _customGiftShow;
}

- (LiveUserModel *)firstUser {
    if (!_firstUser) {
        _firstUser = [[LiveUserModel alloc]init];
        _firstUser.name = @"first";
        _firstUser.iconUrl = @"http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbg8tb6wqj20gl0qogni.jpg";
    }
    return _firstUser;
}

- (LiveUserModel *)secondUser {
    if (!_secondUser) {
        _secondUser = [[LiveUserModel alloc]init];
        _secondUser.name = @"second";
        _secondUser.iconUrl = @"http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbgd5cr5nj209s0akgly.jpg";
    }
    return _secondUser;
}

- (LiveUserModel *)thirdUser {
    if (!_thirdUser) {
        _thirdUser = [[LiveUserModel alloc]init];
        _thirdUser.name = @"third";
        _thirdUser.iconUrl = @"http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbgeuwk21j205k05kq2w.jpg";
    }
    return _thirdUser;
}

- (LiveUserModel *)fourthUser {
    if (!_fourthUser) {
        _fourthUser = [[LiveUserModel alloc]init];
        _fourthUser.name = @"fourth";
        _fourthUser.iconUrl = @"http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbgfpf5bgj205k07v3yk.jpg";
    }
    return _fourthUser;
}

- (LiveUserModel *)fifthUser {
    if (!_fifthUser) {
        _fifthUser = [[LiveUserModel alloc]init];
        _fifthUser.name = @"fifth";
        _fifthUser.iconUrl = @"http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbgg5427qj205k05k748.jpg";
    }
    return _fifthUser;
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
                                @"picUrl": @"http://a3.qpic.cn/psb?/V12A6SP10iIW9i/AL.CfLAFH*W.Ge1n*.LwpXSImK.Hm1eCMtt4rm5WvCA!/b/dFOyjUpCBwAA&bo=yADIAAAAAAABACc!&rf=viewer_4"
                                },
                            ];
    }
    return _giftDataSource;
}

- (void)dealloc{
    NSLog(@"delloc VC ==> %@",self);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
