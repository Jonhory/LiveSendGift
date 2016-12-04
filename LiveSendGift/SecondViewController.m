//
//  SecondViewController.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "SecondViewController.h"
#import "ThirdViewController.h"


@interface SecondViewController ()

@property (nonatomic ,weak) UIButton * btn1;
@property (nonatomic ,weak) UIButton * btn2;

@end

@implementation SecondViewController

- (UIButton *)btn2{
    if (!_btn2) {
        UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
        btn.backgroundColor = [UIColor blueColor];
        btn.center = self.view.center;
        [btn setTitle:@"Go TestVC" forState:UIControlStateNormal];
        [self.view addSubview:btn];
        btn.tag = 102;
        [btn addTarget:self action:@selector(goTestVC:) forControlEvents:UIControlEventTouchUpInside];
        _btn2 = btn;
    }
    return _btn2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    
//    [self btn1];
    self.btn2.center = CGPointMake(self.view.center.x, self.view.center.y + 120);
    // Do any additional setup after loading the view.
}


- (void)goTestVC:(UIButton *)btn{
    ThirdViewController * v = [[ThirdViewController alloc]init];
    [self.navigationController pushViewController:v animated:YES];

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
