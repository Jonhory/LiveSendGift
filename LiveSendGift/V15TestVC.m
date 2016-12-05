//
//  V15TestVC.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/12/4.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#import "V15TestVC.h"
#import "LiveGiftShowCustom.h"

@interface V15TestVC ()

@property (nonatomic ,weak) LiveGiftShowCustom * customGiftShow;

@end

@implementation V15TestVC

- (LiveGiftShowCustom *)customGiftShow{
    if (!_customGiftShow) {
        _customGiftShow = [LiveGiftShowCustom addToView:self.view];
    }
    return _customGiftShow;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"V1.5 Test";
    self.view.backgroundColor = RGB(237, 237, 237);
    
    [self customGiftShow];
    // Do any additional setup after loading the view.
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
