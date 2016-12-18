//
//  LiveGiftShow.m
//  LiveSendGift
//
//  Created by Jonhory on 2016/11/11.
//  Copyright © 2016年 com.wujh. All rights reserved.
//

#import "LiveGiftShow.h"
#import "LiveGiftShowView.h"

static CGFloat const kGiftViewMargin = 50.0;/**< 两个弹幕之间的高度差 */
static NSString * const kGiftViewRemoved = @"kGiftViewRemoved";/**< 弹幕已移除的key */
static CGFloat const kExchangeAnimationTime = 0.25;/**< 交换动画时长 */

@interface LiveGiftShow ()

@property (nonatomic ,strong) NSMutableDictionary * giftModelDict;/**< 装礼物视图 */
@property (nonatomic ,strong) NSMutableArray * giftViewArr;/**< 限制总数量 */

@end

@implementation LiveGiftShow



/**
 唯一入口
 
 @param model 传入模型数据 显示的数字自动从1开始加1
 */
- (void)addGiftListModel:(LiveGiftShowModel *)model{
    if (!model) {
        return;
    }
    
    NSString * dictKey = [NSString stringWithFormat:@"%@%@",model.user.name,model.giftModel.type];
    
    LiveGiftShowView * showView = [self.giftModelDict objectForKey:dictKey];
    if (!showView && ![showView isKindOfClass:[LiveGiftShowView class]]) {//如果不存在该用户 新建
        //此处用来判断最多显示两个弹幕,第三个弹幕进来时，替换旧的弹幕
        if (self.giftViewArr.count >= 1) {
            for (int i = 0; i<self.giftViewArr.count; i++) {
                LiveGiftShowView * viewNow = self.giftViewArr[i];
                if (viewNow && [viewNow isKindOfClass:[LiveGiftShowView class]]) {//安全判断
                    if (i>0) {
                        LiveGiftShowView * viewAgo = self.giftViewArr[i-1];//前一个视图
                        if (viewAgo && [viewAgo isKindOfClass:[LiveGiftShowView class]]) {//安全判断
                            NSComparisonResult result = [viewNow.creatDate compare:viewAgo.creatDate];
                            if (result == 1) {
                                //替换模型之后 字典的key要改变
                                [self resetView:viewAgo nowModel:model];
                                return;
                            }else{//否则viewNow是更早的时间 替换该视图
                                //替换模型之后 字典的key要改变
                                [self resetView:viewNow nowModel:model];
                                return;
                            }
                        }
                    }
                }
            }
        }
        
        CGFloat   topOrY = (kViewHeight + kGiftViewMargin) * [self.giftModelDict allKeys].count;
        NSInteger index = [self.giftViewArr indexOfObject:kGiftViewRemoved];
        
        if ([self.giftViewArr containsObject:kGiftViewRemoved]) {
            topOrY = index * (kViewHeight+kGiftViewMargin);
        }
        
        LiveGiftShowView * view = [[LiveGiftShowView alloc]initWithFrame:CGRectMake(0, topOrY, 0, 0)];
        view.creatDate = [NSDate date];
        __weak __typeof(self)weakSelf = self;
        view.liveGiftShowViewTimeOut = ^(LiveGiftShowView * selfView){//视图移除之后
            //从数组移除
            [weakSelf.giftViewArr replaceObjectAtIndex:selfView.index withObject:kGiftViewRemoved];
            //从字典移除
            NSString * selfViewKey = [NSString stringWithFormat:@"%@%@",selfView.model.user.name,selfView.model.giftModel.type];
            [weakSelf.giftModelDict removeObjectForKey:selfViewKey];
            [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@((kViewHeight+kGiftViewMargin) * [weakSelf.giftModelDict allKeys].count));
            }];
        };
        
        view.model = model;
        [view addGiftNumberFrom:1];
        [self addSubview:view];
        
        //将视图加入数组
        if ([self.giftViewArr containsObject:kGiftViewRemoved]) {
            view.index = index;
            [self.giftViewArr replaceObjectAtIndex:index withObject:view];
        }else {
            view.index = self.giftViewArr.count;
            [self.giftViewArr addObject:view];
        }

        
        //将视图加入字典
        [self.giftModelDict setObject:view forKey:dictKey];
        
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(topOrY+(kViewHeight+kGiftViewMargin)));
        }];
    }else{//存在该用户 修改数值
        [showView addGiftNumberFrom:1];
        if ([self.giftViewArr containsObject:kGiftViewRemoved]) {
            if ([self.giftViewArr indexOfObject:kGiftViewRemoved] == 0 && showView.isAnimation == NO) {
                [UIView animateWithDuration:kExchangeAnimationTime animations:^{
                    CGRect frame = showView.frame;
                    frame.origin.y = 0;
                    showView.frame = frame;
                } completion:^(BOOL finished) {
                    if (finished) {
                    }
                }];
                showView.index = 0;
                showView.isAnimation = YES;
                [self.giftViewArr exchangeObjectAtIndex:0 withObjectAtIndex:1];
            }
        }
        
        LiveGiftShowView * firstShowView = self.giftViewArr[0];
        if (firstShowView && [firstShowView isKindOfClass:[LiveGiftShowView class]] && firstShowView != showView) {
            if ([showView.numberView getLastNumber] > [firstShowView.numberView getLastNumber]){
                [UIView animateWithDuration:kExchangeAnimationTime animations:^{
                    CGRect firstF = firstShowView.frame;
                    CGRect showF = showView.frame;
                    showF.origin.y = 0;
                    firstF.origin.y = kViewHeight+kGiftViewMargin;
                    firstShowView.frame = firstF;
                    showView.frame = showF;
                } completion:^(BOOL finished) {
                    
                }];
                showView.isAnimation = YES;
                firstShowView.isAnimation = YES;
                showView.index = 0;
                firstShowView.index = 1;
                [self.giftViewArr exchangeObjectAtIndex:0 withObjectAtIndex:1];
            }
        }
    }
    
}

- (void)resetView:(LiveGiftShowView *)view nowModel:(LiveGiftShowModel *)model{
    NSString * oldKey = [NSString stringWithFormat:@"%@%@",view.model.user.name,view.model.giftModel.type];
    NSString * dictKey = [NSString stringWithFormat:@"%@%@",model.user.name,model.giftModel.type];
    //找到时间早的那个视图 替换模型 重置数字
    view.model = model;
    [view resetTimeAndNumberFrom:1];
    [self.giftModelDict removeObjectForKey:oldKey];
    [self.giftModelDict setObject:view forKey:dictKey];
}

- (NSMutableDictionary *)giftModelDict{
    if (!_giftModelDict) {
        _giftModelDict = [NSMutableDictionary dictionary];
    }
    return _giftModelDict;
}

- (NSMutableArray *)giftViewArr{
    if (!_giftViewArr) {
        _giftViewArr = [NSMutableArray array];
    }
    return _giftViewArr;
}

@end
