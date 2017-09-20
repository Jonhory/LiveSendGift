//
//  LiveGiftShowNumberView.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShowNumberView.h"
#import "Masonry.h"

@interface LiveGiftShowNumberView ()

@property (nonatomic ,strong) UIImageView * digitIV;
@property (nonatomic ,strong) UIImageView * ten_digitIV;
@property (nonatomic ,strong) UIImageView * hundredIV;
@property (nonatomic ,strong) UIImageView * thousandIV;

@property (nonatomic ,strong) UIImageView * xIV;

@property (nonatomic ,assign) NSInteger lastNumber;/**< 最后显示的数字 */

@end

@implementation LiveGiftShowNumberView

@synthesize number = _number;

- (void)setNumber:(NSInteger)number{
    self.lastNumber = number;
}

- (NSInteger)number{
    _number = self.lastNumber ;
    self.lastNumber += 1;
    return _number;
}

/**
 获取显示的数字
 
 @return 显示的数字
 */
- (NSInteger)getLastNumber{
    return self.lastNumber - 1;
}

/**
 改变数字显示
 
 @param numberStr 显示的数字
 */
- (void)changeNumber:(NSInteger)numberStr{
    if (numberStr <= 0) {
        return;
    }
    
    NSInteger num = numberStr;
    NSInteger qian = num / 1000;
    NSInteger qianYu = num % 1000;
    NSInteger bai = qianYu / 100;
    NSInteger baiYu = qianYu % 100;
    NSInteger shi = baiYu / 10;
    NSInteger shiYu = baiYu % 10;
    NSInteger ge = shiYu;
    
    if (numberStr > 9999) {
        qian = 9;
        bai = 9;
        shi = 9;
        ge = 9;
    }
    
    
    [self addSubview:self.digitIV];
    
    [self.digitIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.centerY.equalTo(self);
    }];
    self.digitIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",ge]];
    
    NSInteger length = 1;
    
    if (qian > 0) {
        length = 4;
        [self addSubview:self.thousandIV];
        [self addSubview:self.hundredIV];
        [self addSubview:self.ten_digitIV];
        
        self.thousandIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",qian]];
        self.hundredIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",bai]];
        self.ten_digitIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",shi]];
        
        [self.thousandIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.hundredIV.mas_left);
            make.centerY.equalTo(self);
        }];
        
        [self.hundredIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.ten_digitIV.mas_left);
            make.centerY.equalTo(self);
        }];
        
        [self.ten_digitIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.digitIV.mas_left);
            make.centerY.equalTo(self.digitIV);
        }];
    }else if (bai > 0){
        length = 3;
        [self.thousandIV removeFromSuperview];
        [self addSubview:self.hundredIV];
        [self addSubview:self.ten_digitIV];
        
        self.hundredIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",bai]];
        self.ten_digitIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",shi]];
        
        [self.hundredIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.ten_digitIV.mas_left);
            make.centerY.equalTo(self);
        }];
        
        [self.ten_digitIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.digitIV.mas_left);
            make.centerY.equalTo(self.digitIV);
        }];
    }else if (shi > 0){
        length = 2;
        [self.thousandIV removeFromSuperview];
        [self.hundredIV removeFromSuperview];
        [self addSubview:self.ten_digitIV];
        
        self.ten_digitIV.image = [UIImage imageNamed:[NSString stringWithFormat:@"w_%zi",shi]];
        [self.ten_digitIV mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.digitIV.mas_left);
            make.centerY.equalTo(self.digitIV);
        }];
    }else {
        length = 1;
        [self.thousandIV removeFromSuperview];
        [self.hundredIV removeFromSuperview];
        [self.ten_digitIV removeFromSuperview];
    }
    
    [self addSubview:self.xIV];
    
    [self.xIV mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-15*length);
        make.centerY.equalTo(self).offset(2);
        make.width.equalTo(@15);
    }];
    
    [self layoutIfNeeded];
    
}

- (UIImageView *)xIV{
    if (!_xIV) {
        _xIV = [self creatIV];
        _xIV.image = [UIImage imageNamed:@"w_x"];
    }
    return _xIV;
}

- (UIImageView *)digitIV{
    if (!_digitIV) {
        _digitIV = [self creatIV];
    }
    return _digitIV;
}

- (UIImageView *)ten_digitIV{
    if (!_ten_digitIV) {
        _ten_digitIV = [self creatIV];
    }
    return _ten_digitIV;
}

- (UIImageView *)hundredIV{
    if (!_hundredIV) {
        _hundredIV = [self creatIV];
    }
    return _hundredIV;
}

- (UIImageView *)thousandIV{
    if (!_thousandIV) {
        _thousandIV = [self creatIV];
    }
    return _thousandIV;
}

- (UIImageView *)creatIV{
    UIImageView * iv = [[UIImageView alloc]init];
    return iv;
}


@end
