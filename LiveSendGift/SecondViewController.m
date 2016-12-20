//
//  SecondViewController.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "V15TestVC.h"


@interface SecondViewController ()

@property (nonatomic ,weak) UIButton * btn1;
@property (nonatomic ,weak) UIButton * btn2;

@end

@implementation SecondViewController

- (UIButton *)btn1{
    if (!_btn1) {
        _btn1 = [self createBtnWithFrame:CGRectMake(0, 300, 150, 50) tag:101 title:@"Go TestVC = V1.5"];
        _btn1.backgroundColor = [UIColor blueColor];
    }
    return _btn1;
}

- (UIButton *)btn2{
    if (!_btn2) {
        _btn2 = [self createBtnWithFrame:CGRectMake(0, 0, 150, 50) tag:102 title:@"Go TestVC = V1.4"];
        _btn2.backgroundColor = [UIColor redColor];
    }
    return _btn2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
    label.text = @"V1.5 请看V15TestVC";
    label.numberOfLines = 0;
    label.center = CGPointMake(self.view.center.x, self.btn1.center.y - 150);
    label.textColor = [UIColor redColor];
    [label sizeToFit];

    [self.view addSubview:label];
    
    self.btn1.center = CGPointMake(self.view.center.x, self.btn1.center.y);
    self.btn2.center = CGPointMake(self.view.center.x, self.btn1.center.y + 150);
    // Do any additional setup after loading the view.
}


- (void)goTestVC:(UIButton *)btn{
    switch (btn.tag) {
        case 101:{
            V15TestVC * vc = [[V15TestVC alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 102:{
            ThirdViewController * vc = [[ThirdViewController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        default:
            break;
    }
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
