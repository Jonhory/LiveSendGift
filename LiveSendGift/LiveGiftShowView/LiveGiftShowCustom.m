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
static NSInteger live_maxGiftShowCount = 3;

@interface LiveGiftShowCustom ()

@property (nonatomic ,strong) NSMutableDictionary * showViewDict;/**< key([self getDictKey]):value(LiveGiftShowView*) */
//用来记录模型的顺序
@property (nonatomic ,strong) NSMutableArray * showViewArr;/**< [LiveGiftShowView] */

@end

@implementation LiveGiftShowCustom

#pragma mark - Lazy
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

+ (void)setMaxGiftCount:(NSInteger)maxGiftCount{
    live_maxGiftShowCount = maxGiftCount;
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
            if (![self.showViewArr containsObject:kGiftViewRemoved]) {
                //排序 最小的时间在第一个
                NSArray * sortArr = [self.showViewArr sortedArrayUsingComparator:^NSComparisonResult(LiveGiftShowView * obj1, LiveGiftShowView * obj2) {
                    return [obj1.creatDate compare:obj2.creatDate];
                    
                }];
                LiveGiftShowView * oldestView = sortArr.firstObject;
                //重置模型
                [self resetView:oldestView nowModel:showModel isChangeNum:isResetNumber number:showNumber];
                return;
            }
        }
        
        //计算视图Y值
        CGFloat   showViewY = (kViewHeight + kGiftViewMargin) * [self.showViewDict allKeys].count;
        //获取已移除的key的index
        NSInteger kRemovedViewIndex = [self.showViewArr indexOfObject:kGiftViewRemoved];
        if ([self.showViewArr containsObject:kGiftViewRemoved]) {
            showViewY = kRemovedViewIndex * (kViewHeight+kGiftViewMargin);
        }
        //创建新模型
        LiveGiftShowView * newShowView = [[LiveGiftShowView alloc]initWithFrame:CGRectMake(0, showViewY, 0, 0)];
        //赋值
        newShowView.model = showModel;
        //改变礼物数量
        if (isResetNumber) {
            [newShowView resetTimeAndNumberFrom:showNumber];
        }else{
            [newShowView addGiftNumberFrom:1];
        }
        //超时移除
        __weak __typeof(self)weakSelf = self;
        newShowView.liveGiftShowViewTimeOut = ^(LiveGiftShowView * willReMoveShowView){
            //从数组移除
            [weakSelf.showViewArr replaceObjectAtIndex:willReMoveShowView.index withObject:kGiftViewRemoved];
            //从字典移除
            NSString * willReMoveShowViewKey = [NSString stringWithFormat:@"%@%@",willReMoveShowView.model.user.name,willReMoveShowView.model.giftModel.type];
            [weakSelf.showViewDict removeObjectForKey:willReMoveShowViewKey];
            
            //移除之后更新自身约束
            [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@((kViewHeight+kGiftViewMargin) * [weakSelf.showViewDict allKeys].count));
            }];
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
        //更新自身约束
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(showViewY+(kViewHeight+kGiftViewMargin)));
        }];
    }
    //如果存在旧模型
    else{
        //首先修改数量
        if (isResetNumber) {
            [oldShowView resetTimeAndNumberFrom:showNumber];
        }else{
            [oldShowView addGiftNumberFrom:1];
        }
        //然后 比较数量大小排序
    }
}

#pragma mark - Private
- (void)resetView:(LiveGiftShowView *)view nowModel:(LiveGiftShowModel *)model isChangeNum:(BOOL)isChange number:(NSInteger)number{
    NSString * oldKey = [NSString stringWithFormat:@"%@%@",view.model.user.name,view.model.giftModel.type];
    NSString * dictKey = [NSString stringWithFormat:@"%@%@",model.user.name,model.giftModel.type];
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


- (void)dealloc{
    NSLog(@"Delloc V1.5 !!  %@",self);
}


@end
