//
//  SecondViewController.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "HomeVC.h"
#import "TestVC.h"

#define SCREEN [UIScreen mainScreen].bounds.size

static NSInteger kTag = 300;

@interface HomeVC ()

@property (nonatomic ,weak) UIButton * btn1;
@property (nonatomic ,weak) UIButton * btn2;
@property (nonatomic ,weak) UIButton * btn3;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.title = @"LiveSendGift";
    
    [self btn1];
    [self btn2];
    [self btn3];
}

- (void)goTestVC:(UIButton *)btn {
    NSLog(@"%@", btn.titleLabel.text);
    
    if (btn.tag == kTag + 0) {
        TestVC * testVC = [TestVC initWithShowMode:LiveGiftShowModeFromTopToBottom hiddenMode:LiveGiftHiddenModeLeft appearMode:LiveGiftAppearModeLeft addMode:LiveGiftAddModeAdd title:btn.titleLabel.text];
        [self.navigationController pushViewController:testVC animated:YES];
    } else if (btn.tag == kTag + 1) {
        TestVC * testVC = [TestVC initWithShowMode:LiveGiftShowModeFromBottomToTop hiddenMode:LiveGiftHiddenModeRight appearMode:LiveGiftAppearModeLeft addMode:LiveGiftAddModeAdd title:btn.titleLabel.text];
        [self.navigationController pushViewController:testVC animated:YES];
    } else if (btn.tag == kTag + 2) {
        TestVC * testVC = [TestVC initWithShowMode:LiveGiftShowModeFromTopToBottom hiddenMode:LiveGiftHiddenModeNone appearMode:LiveGiftAppearModeNone addMode:LiveGiftAddModeReplace title:btn.titleLabel.text];
        [self.navigationController pushViewController:testVC animated:YES];
    }
}

- (UIButton *)btn1{
    if (!_btn1) {
        _btn1 = [self createBtnWithTag:0 title:@"左出现 左消失 自上而下 队列模式"];
        _btn1.backgroundColor = [UIColor blueColor];
    }
    return _btn1;
}

- (UIButton *)btn2{
    if (!_btn2) {
        _btn2 = [self createBtnWithTag:1 title:@"左出现 右消失 自下而上 队列模式"];
        _btn2.backgroundColor = [UIColor blueColor];
    }
    return _btn2;
}

- (UIButton *)btn3{
    if (!_btn3) {
        _btn3 = [self createBtnWithTag:2 title:@"直接出现 直接消失 自上而下 替换模式"];
        _btn3.backgroundColor = [UIColor blueColor];
    }
    return _btn3;
}

- (UIButton *)createBtnWithTag:(NSInteger)tag title:(NSString *)title {
    CGFloat btnWidth = SCREEN.width / 3 * 2.0;
    
    NSInteger number = tag;
    
    UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 88 + 20 + number * 50, btnWidth, 40)];
    btn.backgroundColor = [UIColor randomColor];
    btn.tag = kTag + tag;
    
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [btn setTitle:title forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(goTestVC:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
    btn.center = CGPointMake(self.view.center.x, btn.center.y);
    
    return btn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
