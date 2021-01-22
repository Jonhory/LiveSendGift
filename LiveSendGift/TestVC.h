//
//  V15TestVC.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/12/4.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveGiftShowCustom.h"

@interface UIColor (RandomColor)
+ (UIColor *)randomColor;
@end

@interface TestVC : UIViewController

+ (instancetype)initWithShowMode:(LiveGiftShowMode)showMode hiddenMode:(LiveGiftHiddenMode)hiddenMode appearMode:(LiveGiftAppearMode)appearMode addMode:(LiveGiftAddMode)addMode title:(NSString *)title;

@end
