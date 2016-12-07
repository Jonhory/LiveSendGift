//
//  LiveGiftShowCustom.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/12/4.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShowCustom.h"
#import "LiveGiftShowView.h"

static CGFloat const kGiftViewMargin = 50.0;/**< 两个弹幕之间的高度差 */
static NSString * const kGiftViewRemoved = @"kGiftViewRemoved";/**< 弹幕已移除的key */
static CGFloat const kExchangeAnimationTime = 0.25;/**< 交换动画时长 */

@interface LiveGiftShowCustom ()

@property (nonatomic ,strong) NSMutableDictionary * modelDict;/**< key([self getDictKey]):value(LiveGiftShowView*) */

@end

@implementation LiveGiftShowCustom

#pragma mark - Lazy
- (NSMutableDictionary *)modelDict{
    if (!_modelDict) {
        _modelDict = [[NSMutableDictionary alloc]init];
    }
    return _modelDict;
}

#pragma mark - 初始化
+ (instancetype)addToView:(UIView *)superView{
    LiveGiftShowCustom * v = [[LiveGiftShowCustom alloc]init];
    [superView addSubview:v];
    //布局
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@244);//这个改动之后要注意修改LiveGiftShowView.h的kViewWidth
        make.height.equalTo(@44);//这个改动之后要注意修改LiveGiftShowView.h的kViewHeight
        make.left.equalTo(superView.mas_left);//这个可以任意修改
        make.top.equalTo(superView.mas_top).offset(100);//这个可以任意修改
    }];
    v.backgroundColor = [UIColor yellowColor];
    return v;
}

- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel{
    [self addLiveGiftShowModel:showModel showNumber:0];
}

- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel showNumber:(NSInteger)showNumber{
    if (!showModel || ![showModel isKindOfClass:[LiveGiftShowModel class]]) {
        return;
    }
    
    LiveGiftShowView * oldShowView = [self.modelDict objectForKey:[self getDictKey:showModel]];
    
    //判断是否强制修改显示的数字
    BOOL isResetNumber = showNumber > 0 ? YES : NO;

    //如果不存在旧模型
    if (!oldShowView || ![oldShowView isKindOfClass:[LiveGiftShowView class]]) {
        //计算视图Y值
        CGFloat   showViewY = (kViewHeight + kGiftViewMargin) * [self.modelDict allKeys].count;
        
        NSLog(@"%@ Y = %f",self,showViewY);

        //创建新模型
        LiveGiftShowView * newShowView = [[LiveGiftShowView alloc]initWithFrame:CGRectMake(0, showViewY, 0, 0)];
        //赋值
        newShowView.model = showModel;
        if (isResetNumber) {
            [newShowView resetTimeAndNumberFrom:showNumber];
        }else{
            [newShowView addGiftNumberFrom:1];
        }
        //超时动画
        __weak __typeof(self)weakSelf = self;
        newShowView.liveGiftShowViewTimeOut = ^(LiveGiftShowView * willReMoveShowView){
            //从字典移除
            NSString * willReMoveShowViewKey = [NSString stringWithFormat:@"%@%@",willReMoveShowView.model.user.name,willReMoveShowView.model.giftModel.type];
            [weakSelf.modelDict removeObjectForKey:willReMoveShowViewKey];
            //移除之后更新自身约束
            [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@((kViewHeight+kGiftViewMargin) * [weakSelf.modelDict allKeys].count));
            }];
        };
        
        [self addSubview:newShowView];
        
        //加入字典
        [self.modelDict setObject:newShowView forKey:[self getDictKey:showModel]];
        //更新自身约束
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(showViewY+(kViewHeight+kGiftViewMargin)));
        }];
    }
    //如果存在旧模型
    else{
        if (isResetNumber) {
            [oldShowView resetTimeAndNumberFrom:showNumber];
        }else{
            [oldShowView addGiftNumberFrom:1];
        }
    }
}

#pragma mark - Private
- (NSString *)getDictKey:(LiveGiftShowModel *)model{
    //默认以 用户名+礼物类型 为key
    NSString * key = [NSString stringWithFormat:@"%@%@",model.user.name,model.giftModel.type];
    NSLog(@"key ==  %@  model == %@",key,model);
    return key;
}


- (void)dealloc{
    NSLog(@"Delloc V1.5 !!  %@",self);
}


@end
