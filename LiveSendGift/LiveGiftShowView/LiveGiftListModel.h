//
//  ZYGiftListModel.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveGiftListModel : NSObject

@property(nonatomic, copy, nullable) NSString *type;/**< 礼物类型 */
@property(nonatomic, copy, nullable) NSString *name;/**< 礼物的名称*/
@property(nonatomic, copy, nullable) NSString *picUrl;/**< 右侧礼物图片url */
@property(nonatomic, copy, nullable) NSString *rewardMsg;/**< 礼物配置的语句 */

@end

NS_ASSUME_NONNULL_END
