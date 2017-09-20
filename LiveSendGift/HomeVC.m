//
//  SecondViewController.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "HomeVC.h"
#import "TestVC.h"


@interface HomeVC ()

@property (nonatomic ,weak) UIButton * btn1;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.title = @"Home VC";
    self.btn1.center = CGPointMake(self.view.center.x, self.btn1.center.y);
}

- (void)goTestVC:(UIButton *)btn{
    TestVC * testVC = [[TestVC alloc]init];
    [self.navigationController pushViewController:testVC animated:YES];
}

- (UIButton *)btn1{
    if (!_btn1) {
        _btn1 = [self createBtnWithFrame:CGRectMake(0, 300, 150, 50) tag:101 title:@"Go TestVC = V1.9"];
        _btn1.backgroundColor = [UIColor blueColor];
    }
    return _btn1;
}

-(UIButton *)createBtnWithFrame:(CGRect )frame tag:(NSInteger )tag title:(NSString *)title{
    UIButton * btn = [[UIButton alloc]initWithFrame:frame];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goTestVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
