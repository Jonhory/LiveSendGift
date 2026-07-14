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

@interface LiveGiftShowCustom ()

@property (nonatomic ,strong) NSLayoutConstraint * heightConstraint;/**< 容器高度约束，随 maxRailwayCount 更新 */
@property (nonatomic ,strong) NSMutableDictionary * showViewDict;/**< key([self getDictKey]):value(LiveGiftShowView*) */
// 用来记录模型的顺序
@property (nonatomic ,strong) NSMutableArray * showViewArr;/**< [LiveGiftShowView, @"kGiftViewRemoved"] */
// 待展示礼物队列
@property (nonatomic, strong) NSMutableArray <LiveGiftShowModel *> * waitQueueArr;

@end

@implementation LiveGiftShowCustom

#pragma mark - 初始化
+ (instancetype)addToView:(UIView *)superView {
    return [self addToView:superView y:100];
}

+ (instancetype)addToView:(UIView *)superView y:(CGFloat)y {
    LiveGiftShowCustom * v = [[LiveGiftShowCustom alloc]init];
    v.userInteractionEnabled = NO;
    [superView addSubview:v];
    // 布局（V2.0 起用系统 NSLayoutAnchor，移除 Masonry 依赖）
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.heightConstraint = [v.heightAnchor constraintEqualToConstant:(kViewHeight + kGiftViewMargin) * (v.maxRailwayCount - 1) + kViewHeight];
    [NSLayoutConstraint activateConstraints:@[
        [v.widthAnchor constraintEqualToConstant:kViewWidth],
        v.heightConstraint,
        // 这个可以任意修改
        [v.leftAnchor constraintEqualToAnchor:superView.leftAnchor],
        // 这个参数在的设定应该注意最大礼物数量时不要超出屏幕边界
        [v.topAnchor constraintEqualToAnchor:superView.topAnchor constant:y],
    ]];
    v.backgroundColor = [UIColor clearColor];
    return v;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认配置（V2.0 起为实例属性，多实例互不影响）
        _kExchangeAnimationTime = 0.25;
        _kAppearAnimationTime = 0.5;
        _addMode = LiveGiftAddModeReplace;
        _maxRailwayCount = 3;
        _railwayCanExchange = YES;
        _showMode = LiveGiftShowModeFromTopToBottom;
        _hiddenMode = LiveGiftHiddenModeRight;
        _appearMode = LiveGiftAppearModeLeft;
        _interfaceDebugEnabled = NO;
    }
    return self;
}

- (void)setMaxRailwayCount:(NSInteger)maxRailwayCount {
    _maxRailwayCount = maxRailwayCount;
    self.heightConstraint.constant = (kViewHeight + kGiftViewMargin) * (maxRailwayCount - 1) + kViewHeight;
}

- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel{
    [self addLiveGiftShowModel:showModel showNumber:0];
}

- (void)addLiveGiftShowModel:(LiveGiftShowModel *)showModel showNumber:(NSInteger)showNumber{
    if (!showModel || ![showModel isKindOfClass:[LiveGiftShowModel class]]) {
        return;
    }
    // 线程安全：礼物消息常来自 IM/网络回调线程，统一转到主队列
    if (![NSThread isMainThread]) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf addLiveGiftShowModel:showModel showNumber:showNumber];
        });
        return;
    }

    LiveGiftShowView * oldShowView = [self.showViewDict objectForKey:[self getDictKey:showModel]];
    
    // 判断是否强制修改显示的数字
    BOOL isResetNumber = showNumber > 0 ? YES : NO;
    
    // 如果不存在旧模型
    if (!oldShowView || ![oldShowView isKindOfClass:[LiveGiftShowView class]]) {
        // 如果当前弹幕数量大于最大限制
        if (self.showViewArr.count >= self.maxRailwayCount) {
            // 判断数组是否包含kGiftViewRemoved , 不包含的时候进行排序
            if (![self.showViewArr containsObject:kGiftViewRemoved]) {
                if (self.addMode == LiveGiftAddModeReplace) {
                    // 排序 最小的时间在第一个
                    NSArray * sortArr = [self.showViewArr sortedArrayUsingComparator:^NSComparisonResult(LiveGiftShowView * obj1, LiveGiftShowView * obj2) {
                        return [obj1.createDate compare:obj2.createDate];
                    }];
                    LiveGiftShowView * oldestView = sortArr.firstObject;
                    // 重置模型
                    [self resetView:oldestView nowModel:showModel isChangeNum:isResetNumber number:showNumber];
                } else {
                    if (showNumber > 0) {
                        showModel.currentNumber = showNumber;
                    }
                    [self addToQueue:showModel];
                }
                return;
            }
        }
        
        // 计算视图Y值
        CGFloat   showViewY = 0;
        if (self.showMode == LiveGiftShowModeFromTopToBottom) {
            showViewY = (kViewHeight + kGiftViewMargin) * [self.showViewDict allKeys].count;
        } else if (self.showMode == LiveGiftShowModeFromBottomToTop) {
            showViewY = - ((kViewHeight + kGiftViewMargin) * [self.showViewDict allKeys].count);
        }
        // 获取已移除的key的index
        NSInteger kRemovedViewIndex = [self.showViewArr indexOfObject:kGiftViewRemoved];
        if ([self.showViewArr containsObject:kGiftViewRemoved]) {
            if (self.showMode == LiveGiftShowModeFromTopToBottom) {
                showViewY = kRemovedViewIndex * (kViewHeight+kGiftViewMargin);
            } else if (self.showMode == LiveGiftShowModeFromBottomToTop) {
                showViewY = - (kRemovedViewIndex * (kViewHeight+kGiftViewMargin));
            }
        }
        // 创建新模型
        CGRect frame = CGRectMake(0, showViewY, 0, 0);
        if (self.appearMode == LiveGiftAppearModeLeft) {
            // 用宿主视图宽度计算离屏起点，iPad 分屏等非全屏容器下 mainScreen 宽度会偏大
            CGFloat containerWidth = self.superview ? CGRectGetWidth(self.superview.bounds) : CGRectGetWidth([UIScreen mainScreen].bounds);
            frame = CGRectMake(-containerWidth, showViewY, 0, 0);
        }
        LiveGiftShowView * newShowView = [[LiveGiftShowView alloc]initWithFrame:frame];
        // 赋值（imageLoader 须在 model 之前，setModel 内会触发图片加载）
        newShowView.imageLoader = self.webImageLoader;
        newShowView.model = showModel;
        newShowView.hiddenMode = self.hiddenMode;
        // 改变礼物数量
        if (isResetNumber) {
            [newShowView resetTimeAndNumberFrom:showNumber];
        }else{
            [newShowView addGiftNumberFrom:1];
        }
        [self appearWith:newShowView];
        
        // 超时移除
        __weak __typeof(self)weakSelf = self;
        newShowView.liveGiftShowViewTimeOut = ^(LiveGiftShowView * willReMoveShowView){
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(giftDidRemove:)]) {
                [weakSelf.delegate giftDidRemove:willReMoveShowView.model];
            }
            // 从数组移除（index 由 sortShowArr 手工维护，做边界防护避免状态不同步时越界崩溃）
            if (willReMoveShowView.index >= 0 && willReMoveShowView.index < weakSelf.showViewArr.count) {
                [weakSelf.showViewArr replaceObjectAtIndex:willReMoveShowView.index withObject:kGiftViewRemoved];
            } else if ([weakSelf.showViewArr containsObject:willReMoveShowView]) {
                NSInteger realIndex = [weakSelf.showViewArr indexOfObject:willReMoveShowView];
                [weakSelf.showViewArr replaceObjectAtIndex:realIndex withObject:kGiftViewRemoved];
            }
            // 从字典移除
            NSString * willReMoveShowViewKey = [weakSelf getDictKey:willReMoveShowView.model];
            [weakSelf.showViewDict removeObjectForKey:willReMoveShowViewKey];
            
            if ([weakSelf isDebug]) {
                WLog(@"移除了第%zi个,移除后数组 = %@ ,词典 = %@",willReMoveShowView.index,weakSelf.showViewArr,weakSelf.showViewDict);
            }
            
            if (weakSelf.railwayCanExchange) {
                // 比较数量大小排序
                [weakSelf sortShowArr];
                [weakSelf resetY];
            }
            
            if (weakSelf.addMode == LiveGiftAddModeQueue) {
                [weakSelf showWaitView];
            } else if (weakSelf.addMode == LiveGiftAddModeReplace) {
                if (willReMoveShowView.model.animatedTimer) {
                    dispatch_cancel(willReMoveShowView.model.animatedTimer);
                    willReMoveShowView.model.animatedTimer = nil;
                }
            }
        };
        
        [self addSubview:newShowView];
        
        // 加入数组
        if ([self.showViewArr containsObject:kGiftViewRemoved]) {
            newShowView.index = kRemovedViewIndex;
            [self.showViewArr replaceObjectAtIndex:kRemovedViewIndex withObject:newShowView];
        }else{
            newShowView.index = self.showViewArr.count;
            [self.showViewArr addObject:newShowView];
        }
        // 加入字典
        [self.showViewDict setObject:newShowView forKey:[self getDictKey:showModel]];
        
    }
    // 如果存在旧模型
    else{
        // 修改数量大小
        if (isResetNumber) {
            [oldShowView resetTimeAndNumberFrom:showNumber];
        }else{
            [oldShowView addGiftNumberFrom:1];
        }
        if (self.railwayCanExchange) {
            // 比较数量大小排序
            [self sortShowArr];
            // 排序后调整Y值
            [self resetY];
        }
    }
}

- (void)animatedWithGiftModel:(LiveGiftShowModel *)showModel {
    if (!showModel) { return ;}
    // 线程安全：统一转到主队列
    if (![NSThread isMainThread]) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf animatedWithGiftModel:showModel];
        });
        return;
    }

    // 同一弹幕已有连击定时器在跑时，合并次数而不是再开一个定时器。
    // 多个并发定时器同时驱动同一个视图自增，是数字异常膨胀（issue #17）的根源。
    LiveGiftShowView * showingView = [self.showViewDict objectForKey:[self getDictKey:showModel]];
    if (showingView.model.animatedTimer != nil && showingView.model != showModel) {
        showingView.model.toNumber += showModel.toNumber;
        return;
    }

    if (self.addMode == LiveGiftAddModeQueue) {
        // 不存在旧视图
        if (!showingView) {
            NSUInteger showCount = 0;
            for (id object in self.showViewArr) {
                if ([object isKindOfClass:[LiveGiftShowView class]]) {
                    showCount ++;
                }
            }
            // 弹幕数量大于最大数量
            if (showCount >= self.maxRailwayCount) {
                [self addToQueue:showModel];
                return;
            }
        }
    }

    // 当前定时器源
    dispatch_source_t tt = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    // 任务执行开始时间
    dispatch_time_t start = dispatch_walltime(NULL, 0);
    // 任务执行间隔时间
    uint64_t interval = showModel.interval * NSEC_PER_SEC;
    // 给定时器源绑定开始时间、间隔时间以及容忍误差时间
    // 容差取间隔的 10%，允许系统合并定时器唤醒，降低多弹幕连击时的瞬时 CPU
    dispatch_source_set_timer(tt, start, interval, interval / 10);

    // 创建即持有，保证合并判断（animatedTimer != nil）在首个 tick 之前就生效
    showModel.animatedTimer = tt;

    __block NSInteger i = 0;
    __weak __typeof(self)weakSelf = self;
    // 给定时器源绑定任务
    dispatch_source_set_event_handler(tt, ^{
        if (!weakSelf.superview) {
            dispatch_cancel(tt);
            showModel.animatedTimer = nil;
            return;
        }
        if (i < showModel.toNumber) {
            i ++;
            [weakSelf addLiveGiftShowModel:showModel];
        } else {
            dispatch_cancel(tt);
            // 置 nil 让后续同 key 的连击能重新开定时器 / 队列合并逻辑能正确判断
            showModel.animatedTimer = nil;
        }
    });

    // 启动定时器源
    dispatch_resume(tt);
}

- (void)appearWith:(LiveGiftShowView *)showView {
    // 出现的动画
    if (self.appearMode == LiveGiftAppearModeLeft) {
        showView.isAppearAnimation = YES;
        [UIView animateWithDuration:self.kAppearAnimationTime animations:^{
            CGRect f = showView.frame;
            f.origin.x = 0;
            showView.frame = f;
        } completion:^(BOOL finished) {
            showView.isAppearAnimation = NO;
        }];
    }
}

- (void)resetY {
//    NSLog(@"重置 Y 轴了");
    for (int i = 0; i < self.showViewArr.count; i++) {
        LiveGiftShowView * show = self.showViewArr[i];
        if ([show isKindOfClass:[LiveGiftShowView class]]) {
            CGFloat showY = i * (kViewHeight+kGiftViewMargin);
            if (self.showMode == LiveGiftShowModeFromBottomToTop) {
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
    // 如果当前数组包含kGiftViewRemoved 则将kGiftViewRemoved替换到LiveGiftShowView之后
    for (int i = 0; i < self.showViewArr.count; i++) {
        id current = self.showViewArr[i];
        if ([current isKindOfClass:[NSString class]]){
            if (i+1 < self.showViewArr.count) {
                [self searchLiveShowViewFrom:i+1];
            }
        }
    }
    // 以当前 数字大小 比较，降序
    for (int i = 0; i < self.showViewArr.count; i++) {
        for (int j = i; j < self.showViewArr.count; j++) {
            LiveGiftShowView * showViewI = self.showViewArr[i];
            LiveGiftShowView * showViewJ = self.showViewArr[j];
            if ([showViewI isKindOfClass:[LiveGiftShowView class]] && [showViewJ isKindOfClass:[LiveGiftShowView class]]) {
                if ([showViewI.numberView currentNumber] < [showViewJ.numberView currentNumber]) {
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
//        WLog(@"排序后数组==>>> %@",self.showViewArr);
    }
}

- (void)searchLiveShowViewFrom:(int)i{
    for (int j = i; j < self.showViewArr.count; j++) {
        LiveGiftShowView * next = self.showViewArr[j];
        if ([next isKindOfClass:[LiveGiftShowView class]]) {
            // 正在飞出的视图不参与补位（原实现用 frame.origin.x == 屏幕宽度 的浮点相等判断，
            // 只覆盖右出场景且依赖动画结束时机，改用语义明确的状态位）
            if (next.isLeavingAnimation) {
                continue;
            }
            next.index = i-1;
            [self.showViewArr exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
            return;
        }
    }
}

#pragma mark - Deprecated（V2.0 起请直接使用同名属性）

- (void)enableInterfaceDebug:(BOOL)isDebug {
    self.interfaceDebugEnabled = isDebug;
}

- (void)setHiddenModel:(LiveGiftHiddenMode)model {
    self.hiddenMode = model;
}

- (void)setAppearModel:(LiveGiftAppearMode)model {
    self.appearMode = model;
}

- (BOOL)isDebug {
    return self.interfaceDebugEnabled;
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
        if ([oldKey isEqualToString:key] && oldModel.animatedTimer == nil) {
            oldNumber = oldModel.toNumber;
            showModel.toNumber += oldNumber;
            [self.waitQueueArr removeObject:oldModel];
            break;
        }
    }
    [self.waitQueueArr addObject:showModel];
}

/// 展示等待队列
- (void)showWaitView {
    NSUInteger showCount = 0;
    for (id object in self.showViewArr) {
        if ([object isKindOfClass:[LiveGiftShowView class]]) {
            showCount ++;
        }
    }
    if (showCount < self.maxRailwayCount) {
        LiveGiftShowModel * model = self.waitQueueArr.firstObject;
        if (model.currentNumber > 0) {
            [self addLiveGiftShowModel:model showNumber:model.currentNumber];
        } else {
            [self animatedWithGiftModel:model];
        }
        [self.waitQueueArr removeObject:model];
    }
}

- (void)resetView:(LiveGiftShowView *)view nowModel:(LiveGiftShowModel *)model isChangeNum:(BOOL)isChange number:(NSInteger)number{
    NSString * oldKey = [self getDictKey:view.model];
    NSString * dictKey = [self getDictKey:model];
    
    if (view.model.animatedTimer) {
        dispatch_cancel(view.model.animatedTimer);
        view.model.animatedTimer = nil;
    }
    //找到时间早的那个视图 替换模型 重置数字
    view.imageLoader = self.webImageLoader;
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
    // 优先以 userId+礼物类型 为 key，避免同名用户的弹幕被错误合并；未传 userId 时退化为用户名
    NSString * userKey = model.user.userId.length > 0 ? model.user.userId : model.user.name;
    NSString * key = [NSString stringWithFormat:@"%@%@",userKey,model.giftModel.type];
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
