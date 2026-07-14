//
//  UserModel.h
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveUserModel : NSObject

@property (nonatomic, copy, nullable) NSString *userId; /**< 用户唯一标识，用于区分弹幕归属；不传则退化为用 name 区分（同名用户会被合并） */
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, copy, nullable) NSString *iconUrl;

@end

NS_ASSUME_NONNULL_END
