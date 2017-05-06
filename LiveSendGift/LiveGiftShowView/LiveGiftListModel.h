//
//  ZYGiftListModel.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LiveGiftListModel : NSObject


@property(nonatomic, strong) NSString *personSort;
@property(nonatomic, strong) NSString *goldCount;
@property(nonatomic, strong) NSString *highlightedImage;
@property(nonatomic, strong) NSString *type;/**< 礼物类型 */
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *picUrl;/**< 右侧礼物图片url */
@property(nonatomic, strong) NSString *rewardMsg;/**< 礼物配置的语句 */


@end
