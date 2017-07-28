//
//  SecondViewController.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "SecondViewController.h"
#import "TestVC.h"


@interface SecondViewController ()

@property (nonatomic ,weak) UIButton * btn1;

@end

@implementation SecondViewController

- (UIButton *)btn1{
    if (!_btn1) {
        _btn1 = [self createBtnWithFrame:CGRectMake(0, 300, 150, 50) tag:101 title:@"Go TestVC = V1.8"];
        _btn1.backgroundColor = [UIColor blueColor];
    }
    return _btn1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.btn1.center = CGPointMake(self.view.center.x, self.btn1.center.y);
    
}


- (void)goTestVC:(UIButton *)btn{
    TestVC * vc = [[TestVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIButton *)createBtnWithFrame:(CGRect )frame tag:(NSInteger )tag title:(NSString *)title{
    UIButton * btn = [[UIButton alloc]initWithFrame:frame];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goTestVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
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
