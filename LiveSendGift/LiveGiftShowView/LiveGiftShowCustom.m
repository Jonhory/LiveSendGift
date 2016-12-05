//
//  LiveGiftShowCustom.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/12/4.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShowCustom.h"
#import "LiveGiftShowView.h"

@implementation LiveGiftShowCustom

+ (instancetype)addToView:(UIView *)superView{
    LiveGiftShowCustom * v = [[LiveGiftShowCustom alloc]init];
    [superView addSubview:v];
    //布局
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@244);
        make.height.equalTo(@50);
        make.left.equalTo(superView.mas_left);
        make.top.equalTo(superView.mas_top).offset(100);
    }];
    v.backgroundColor = [UIColor yellowColor];
    return v;
}

- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel{
    if (!showModel || ![showModel isKindOfClass:[LiveGiftShowModel class]]) {
        return;
    }
    
    
}

- (void)dealloc{
    NSLog(@"Delloc V1.5 !!  %@",self);
}


@end
