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

static NSInteger live_maxGiftShowCount = 3;
static BOOL live_isEnableInterfaceDebug = NO;

static LiveGiftShowMode live_showModel = LiveGiftShowModeFromTopToBottom;
static LiveGiftHiddenMode live_hiddenModel = LiveGiftHiddenModeRight;
static LiveGiftAppearMode live_appearModel = LiveGiftAppearModeLeft;

@interface LiveGiftShowCustom ()

@property (nonatomic ,strong) NSMutableDictionary * showViewDict;/**< key([self getDictKey]):value(LiveGiftShowView*) */
//用来记录模型的顺序
@property (nonatomic ,strong) NSMutableArray * showViewArr;/**< [LiveGiftShowView, @"kGiftViewRemoved"] */
@property (nonatomic, strong) NSMutableArray <LiveGiftShowModel *> * waitQueueArr;// 待展示礼物队列

@end

@implementation LiveGiftShowCustom

#pragma mark - 初始化
+ (instancetype)addToView:(UIView *)superView{
    LiveGiftShowCustom * v = [[LiveGiftShowCustom alloc]init];
    v.kExchangeAnimationTime = 0.25;
    v.kAppearAnimationTime = 0.5;
    v.addMode = LiveGiftAddModeReplace;
    [superView addSubview:v];
    //布局
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@244);//这个改动之后要注意修改LiveGiftShowView.h的kViewWidth
        make.height.equalTo(@0.01);
        make.left.equalTo(superView.mas_left);//这个可以任意修改
        make.top.equalTo(superView.mas_top).offset(100);//这个参数在的设定应该注意最大礼物数量时不要超出屏幕边界
    }];
    v.backgroundColor = [UIColor clearColor];
    return v;
}

- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel{
    [self addLiveGiftShowModel:showModel showNumber:0];
}

- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel showNumber:(NSInteger)showNumber{
    if (!showModel || ![showModel isKindOfClass:[LiveGiftShowModel class]]) {
        return;
    }
    
    LiveGiftShowView * oldShowView = [self.showViewDict objectForKey:[self getDictKey:showModel]];
    
    //判断是否强制修改显示的数字
    BOOL isResetNumber = showNumber > 0 ? YES : NO;

    //如果不存在旧模型
    if (!oldShowView || ![oldShowView isKindOfClass:[LiveGiftShowView class]]) {
        //如果当前弹幕数量大于最大限制
        if (self.showViewArr.count >= live_maxGiftShowCount) {
            //判断数组是否包含kGiftViewRemoved , 不包含的时候进行排序
            if (![self.showViewArr containsObject:kGiftViewRemoved]) {
                if (self.addMode == LiveGiftAddModeReplace) {
                    //排序 最小的时间在第一个
                    NSArray * sortArr = [self.showViewArr sortedArrayUsingComparator:^NSComparisonResult(LiveGiftShowView * obj1, LiveGiftShowView * obj2) {
                        return [obj1.creatDate compare:obj2.creatDate];
                    }];
                    LiveGiftShowView * oldestView = sortArr.firstObject;
                    //重置模型
                    [self resetView:oldestView nowModel:showModel isChangeNum:isResetNumber number:showNumber];
                }
                return;
            }
        }
        
        //计算视图Y值
        CGFloat   showViewY = 0;
        if (live_showModel == LiveGiftShowModeFromTopToBottom) {
            showViewY = (kViewHeight + kGiftViewMargin) * [self.showViewDict allKeys].count;
        } else if (live_showModel == LiveGiftShowModeFromBottomToTop) {
            showViewY = - ((kViewHeight + kGiftViewMargin) * [self.showViewDict allKeys].count);
        }
        //获取已移除的key的index
        NSInteger kRemovedViewIndex = [self.showViewArr indexOfObject:kGiftViewRemoved];
        if ([self.showViewArr containsObject:kGiftViewRemoved]) {
            if (live_showModel == LiveGiftShowModeFromTopToBottom) {
                showViewY = kRemovedViewIndex * (kViewHeight+kGiftViewMargin);
            } else if (live_showModel == LiveGiftShowModeFromBottomToTop) {
                showViewY = - (kRemovedViewIndex * (kViewHeight+kGiftViewMargin));
            }
        }
        //创建新模型
        CGRect frame = CGRectMake(0, showViewY, 0, 0);
        if (live_appearModel == LiveGiftAppearModeLeft) {
            frame = CGRectMake(-[UIScreen mainScreen].bounds.size.width, showViewY, 0, 0);
        }
        LiveGiftShowView * newShowView = [[LiveGiftShowView alloc]initWithFrame:frame];
        //赋值
        newShowView.model = showModel;
        newShowView.hiddenModel = live_hiddenModel;
        //改变礼物数量
        if (isResetNumber) {
            [newShowView resetTimeAndNumberFrom:showNumber];
        }else{
            [newShowView addGiftNumberFrom:1];
        }
        [self appearWith:newShowView];
        
        //超时移除
        __weak __typeof(self)weakSelf = self;
        newShowView.liveGiftShowViewTimeOut = ^(LiveGiftShowView * willReMoveShowView){
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(giftDidRemove:)]) {
                [weakSelf.delegate giftDidRemove:willReMoveShowView.model];
            }
            //从数组移除
            [weakSelf.showViewArr replaceObjectAtIndex:willReMoveShowView.index withObject:kGiftViewRemoved];
            //从字典移除
            NSString * willReMoveShowViewKey = [weakSelf getDictKey:willReMoveShowView.model];
            [weakSelf.showViewDict removeObjectForKey:willReMoveShowViewKey];
            
            if ([weakSelf isDebug]) {
                WLog(@"移除了第%zi个,移除后数组 = %@ ,词典 = %@",willReMoveShowView.index,weakSelf.showViewArr,weakSelf.showViewDict);
            }
            
            //比较数量大小排序
            [weakSelf sortShowArr];
            [weakSelf resetY];
            if (weakSelf.addMode == LiveGiftAddModeAdd) {
                [weakSelf showWaitView];
            } else if (weakSelf.addMode == LiveGiftAddModeReplace) {
                if (willReMoveShowView.model.animatedTimer) {
                    dispatch_suspend(willReMoveShowView.model.animatedTimer);
                    dispatch_cancel(willReMoveShowView.model.animatedTimer);
                    willReMoveShowView.model.animatedTimer = nil;
                }
            }
        };
        
        [self addSubview:newShowView];
        
        //加入数组
        if ([self.showViewArr containsObject:kGiftViewRemoved]) {
            newShowView.index = kRemovedViewIndex;
            [self.showViewArr replaceObjectAtIndex:kRemovedViewIndex withObject:newShowView];
        }else{
            newShowView.index = self.showViewArr.count;
            [self.showViewArr addObject:newShowView];
        }
        //加入字典
        [self.showViewDict setObject:newShowView forKey:[self getDictKey:showModel]];
        
    }
    //如果存在旧模型
    else{
        //修改数量大小
        if (isResetNumber) {
            [oldShowView resetTimeAndNumberFrom:showNumber];
        }else{
            [oldShowView addGiftNumberFrom:1];
        }
        //比较数量大小排序
        [self sortShowArr];
        //排序后调整Y值
        [self resetY];
        
    }
}

- (void)animatedWithGiftModel:(LiveGiftShowModel *)showModel {
    if (!showModel) { return ;}
    if (self.addMode == LiveGiftAddModeAdd) {
        LiveGiftShowView * oldShowView = [self.showViewDict objectForKey:[self getDictKey:showModel]];
        if (!oldShowView) {// 不存在旧视图
            NSUInteger showCount = 0;
            for (id object in self.showViewArr) {
                if ([object isKindOfClass:[LiveGiftShowView class]]) {
                    showCount ++;
                }
            }
            if (showCount >= live_maxGiftShowCount) {//弹幕数量大于最大数量
                [self addToQueue:showModel];
                return;
            }
        }
    }
    
    dispatch_source_t tt = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(tt, dispatch_walltime(NULL, 0), showModel.interval*NSEC_PER_SEC, 0);
    __block NSInteger i = 0;
    __weak __typeof(self)weakSelf = self;
    dispatch_source_set_event_handler(tt, ^{
        if (i < showModel.toNumber) {
            i ++;
            showModel.animatedTimer = tt;
            [weakSelf addLiveGiftShowModel:showModel];
        } else {
            dispatch_suspend(tt);
            dispatch_cancel(tt);
        }
    });
    dispatch_resume(tt);
}

- (void)appearWith:(LiveGiftShowView *)showView {
    // 出现的动画
    if (live_appearModel == LiveGiftAppearModeLeft) {
        showView.isAppearAnimation = YES;
        [UIView animateWithDuration:self.kAppearAnimationTime animations:^{
            CGRect f = showView.frame;
            f.origin.x = 0;
            showView.frame = f;
        } completion:^(BOOL finished) {
            if (finished) {
                showView.isAppearAnimation = NO;
            }
        }];
    }
}

- (void)resetY {
    for (int i = 0; i < self.showViewArr.count; i++) {
        LiveGiftShowView * show = self.showViewArr[i];
        if ([show isKindOfClass:[LiveGiftShowView class]]) {
            CGFloat showY = i * (kViewHeight+kGiftViewMargin);
            if (live_showModel == LiveGiftShowModeFromBottomToTop) {
                showY = -showY;
            }
            if (show.frame.origin.y != showY) {
                if (!show.isLeavingAnimation) {
                    // 避免出现动画和交换动画冲突
                    if (show.isAppearAnimation) {
                        [show.layer removeAllAnimations];
                    }
                    [UIView animateWithDuration:self.kExchangeAnimationTime animations:^{
                        CGRect showF = show.frame;
                        showF.origin.y = showY;
                        show.frame = showF;
                    } completion:^(BOOL finished) {
                        
                    }];
                    show.isAnimation = YES;
                    if ([self isDebug]) {
                        WLog(@"%@ 重置动画",show);
                    }
                }
            }
        }
    }
}

- (void)sortShowArr{
    //如果当前数组包含kGiftViewRemoved 则将kGiftViewRemoved替换到LiveGiftShowView之后
    for (int i = 0; i < self.showViewArr.count; i++) {
        id current = self.showViewArr[i];
        if ([current isKindOfClass:[NSString class]]){
            if (i+1 < self.showViewArr.count) {
                [self searchLiveShowViewFrom:i+1];
            }
        }
    }
    //以当前 数字大小 比较，降序
    for (int i = 0; i < self.showViewArr.count; i++) {
        for (int j = i; j < self.showViewArr.count; j++) {
            LiveGiftShowView * showViewI = self.showViewArr[i];
            LiveGiftShowView * showViewJ = self.showViewArr[j];
            if ([showViewI isKindOfClass:[LiveGiftShowView class]] && [showViewJ isKindOfClass:[LiveGiftShowView class]]) {
                if ([showViewI.numberView getLastNumber] < [showViewJ.numberView getLastNumber]) {
                    showViewI.index = j;
                    showViewI.isAnimation = YES;
                    showViewJ.index = i;
                    showViewJ.isAnimation = YES;
                    [self.showViewArr exchangeObjectAtIndex:i withObjectAtIndex:j];
                }
            }
        }
    }
    if ([self isDebug]) {
        WLog(@"排序后数组==>>> %@",self.showViewArr);
    }
}

- (void)searchLiveShowViewFrom:(int)i{
    for (int j = i; j < self.showViewArr.count; j++) {
        LiveGiftShowView * next = self.showViewArr[j];
        if ([next isKindOfClass:[LiveGiftShowView class]]) {
            if (next.frame.origin.x == [UIScreen mainScreen].bounds.size.width) {
                continue;
            }
            next.index = i-1;
            [self.showViewArr exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
            return;
        }
    }
}

- (void)setMaxGiftCount:(NSInteger)maxGiftCount{
    live_maxGiftShowCount = maxGiftCount;
}

//设置是否打印信息
- (void)enableInterfaceDebug:(BOOL)isDebug {
    live_isEnableInterfaceDebug = isDebug;
}

- (void)setShowMode:(LiveGiftShowMode)model{
    live_showModel = model;
}

- (void)setHiddenModel:(LiveGiftHiddenMode)model {
    live_hiddenModel = model;
}

- (void)setAppearModel:(LiveGiftAppearMode)model {
    live_appearModel = model;
}

- (BOOL)isDebug {
    return live_isEnableInterfaceDebug;
}

#pragma mark - Private
- (void)addToQueue:(LiveGiftShowModel *)showModel {
    if (!showModel) {
        return;
    }
    NSString * key = [self getDictKey:showModel];
    NSUInteger oldNumber = 0;
    for (NSUInteger i = 0; i<self.waitQueueArr.count; i++) {
        LiveGiftShowModel * oldModel = self.waitQueueArr[i];
        NSString * oldKey = [self getDictKey:oldModel];
        if ([oldKey isEqualToString:key]) {
            oldNumber = oldModel.toNumber;
            showModel.toNumber += oldNumber;
            [self.waitQueueArr removeObject:oldModel];
            break;
        }
    }
    [self.waitQueueArr addObject:showModel];
}

- (void)showWaitView {
    NSUInteger showCount = 0;
    for (id object in self.showViewArr) {
        if ([object isKindOfClass:[LiveGiftShowView class]]) {
            showCount ++;
        }
    }
    if (showCount < live_maxGiftShowCount) {
        LiveGiftShowModel * model = self.waitQueueArr.firstObject;
        [self animatedWithGiftModel:model];
        [self.waitQueueArr removeObject:model];
    }
}

- (void)resetView:(LiveGiftShowView *)view nowModel:(LiveGiftShowModel *)model isChangeNum:(BOOL)isChange number:(NSInteger)number{
    NSString * oldKey = [self getDictKey:view.model];
    NSString * dictKey = [self getDictKey:model];
    //找到时间早的那个视图 替换模型 重置数字
    view.model = model;
    if (isChange) {
        [view resetTimeAndNumberFrom:number];
    }else{
        [view resetTimeAndNumberFrom:1];
    }
    [self.showViewDict removeObjectForKey:oldKey];
    [self.showViewDict setObject:view forKey:dictKey];
}

- (NSString *)getDictKey:(LiveGiftShowModel *)model{
    //默认以 用户名+礼物类型 为key
    NSString * key = [NSString stringWithFormat:@"%@%@",model.user.name,model.giftModel.type];
    return key;
}

#pragma mark - Lazy
- (NSMutableArray<LiveGiftShowModel *> *)waitQueueArr {
    if (!_waitQueueArr) {
        _waitQueueArr = [[NSMutableArray alloc]init];
    }
    return _waitQueueArr;
}

- (NSMutableDictionary *)showViewDict{
    if (!_showViewDict) {
        _showViewDict = [[NSMutableDictionary alloc]init];
    }
    return _showViewDict;
}

-(NSMutableArray *)showViewArr{
    if (!_showViewArr) {
        _showViewArr = [[NSMutableArray alloc]init];
    }
    return _showViewArr;
}

- (void)dealloc{
    if ([self isDebug]) {
        WLog(@"Delloc LiveGiftShowCustom !!  %@",self);
    }
}


@end
