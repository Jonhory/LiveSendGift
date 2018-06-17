![](http://ww1.sinaimg.cn/large/c6a1cfeagy1ffbh46t93nj20ky0dsq3x.jpg)

## 感谢
* 得益于某位不愿留名的同学的帮助，队列模式已经较好的实现了。

## 重要信息
* 2017年09月25日18:42:00 修复了在iOS11下必现`EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)`的崩溃BUG。
* 已知bug提示：在替换模式`LiveGiftAddModeReplace`下使用`animatedWithGiftModel`方法将导致UI效果不理想的bug。建议是`animatedWithGiftModel`方法使用于`LiveGiftAddModeAdd`模式。
* 2017年12月25日11:39:39 修复在iOS11下可能出现的`.cxx destruct`崩溃问题。

## 导航
* [目标](#目标)
* [版本更新说明](#版本更新说明)
* [最新版本](#最新版本)
* [快速使用](#快速使用)
* [自定义配置](#自定义配置)

## <a id="目标"></a>目标:

* 弹幕过几秒自动消失
* 实现A用户弹幕出现时，B用户发送礼物，B用户弹幕在A用户弹幕下方,A/B用户弹幕存在时，A/B用户连续发送礼物，弹幕显示的礼物数量增加，谁的礼物数量较大，谁的弹幕在上方。
* A/B用户弹幕存在时，C用户发送礼物，A/B用户中较早出现的弹幕被替换成C用户的弹幕数据，并且C用户的弹幕处于下方

### <a id="版本更新说明"></a>版本更新:

#### V1.0
* 大致实现了不同用户增加弹幕的效果

#### V1.1
* 实现了用户连续发送数字增加效果
* 实现了新增弹幕从空位出现的效果

#### V1.2
* 实现了第二个用户之后送礼物替换较早的弹幕效果(完善)

#### V1.3
* 实现了上面的视图移除后，正在连击的下面的视图移动到上面的效果

#### V1.4
* 实现了目标效果😊😊😊

#### V1.5
* 实现了自定义最大礼物数量的需求

#### V1.6
* 新增了自下而上的展现效果

#### V1.7
* 解决了一个视图显示BUG，现在几乎不会出现该BUG。

#### V1.8
* 支持向左移除弹幕，支持左边出现动画效果，增加弹幕移除后的回调代理。

#### <a id="最新版本"></a> V1.901测试版
* 支持从1增加到某个数字的动画（在替换模式`LiveGiftAddModeReplace`下存在小bug，如果有某猿能提供帮助将不胜感激）
* 支持队列模式（如下GIF图，注意看鼠标～）
* 移除的模式增加无动画移除
* 修改了部分枚举名称更符合OC语法
* 暴露了动画时长属性，方便开发者依据不同情况自行修改

![](https://ws1.sinaimg.cn/large/c6a1cfeagy1fjq279e03tg20a30iek2l.gif)

### <a id="快速使用"></a>快速使用
* 使用的第三方库:
  * [Masonry](https://github.com/SnapKit/Masonry)
  * [SDWebImage](https://github.com/rs/SDWebImage)

* 两个模型:`LiveGiftListModel`和`LiveUserModel`
  * `LiveGiftListModel `是用来显示弹幕上右侧礼物图片`picUrl`和打赏的语句`rewardMsg`的，礼物有`type`字段
  * `LiveUserModel `是用来显示送礼物的人的名称`name`和头像`iconUrl`
  
* 导入`#import "LiveGiftShowCustom.h"`

* `@property (nonatomic ,weak) LiveGiftShowCustom * customGiftShow;
`

```
/*
 礼物视图支持很多配置属性，开发者按需选择。
 */
- (LiveGiftShowCustom *)customGiftShow{
    if (!_customGiftShow) {
        _customGiftShow = [LiveGiftShowCustom addToView:self.view];
        _customGiftShow.addMode = LiveGiftAddModeAdd;
        [_customGiftShow setMaxGiftCount:3];
        [_customGiftShow setShowMode:LiveGiftShowModeFromTopToBottom];
        [_customGiftShow setAppearModel:LiveGiftAppearModeLeft];
        [_customGiftShow setHiddenModel:LiveGiftHiddenModeNone];
        [_customGiftShow enableInterfaceDebug:YES];
        _customGiftShow.delegate = self;
    }
    return _customGiftShow;
}
```  

* 在开发中使用

```
LiveGiftShowModel * listModel = [LiveGiftShowModel giftModel:self.giftArr[3] 
                                                   userModel:self.firstUser];
[self.giftShow addGiftListModel:listModel];
```
即可完成接入。每一次点击只需要`[self.giftShow addGiftListModel:listModel];`即可自动计数加一。最高支持显示9999。

### 特别说明
* `LiveGiftShowCustom.m`中

```
#pragma mark - 初始化
+ (instancetype)addToView:(UIView *)superView{
    LiveGiftShowCustom * v = [[LiveGiftShowCustom alloc]init];
    [superView addSubview:v];
    //布局
    [v mas_makeConstraints:^(MASConstraintMaker *make) {
        //这个改动之后要注意修改LiveGiftShowView.h的kViewWidth
        make.width.equalTo(@244);
        //将主视图的高度设置0.01，保证弹幕后面的视图能响应点击事件。
        make.height.equalTo(@0.01);
        //这个可以任意修改
        make.left.equalTo(superView.mas_left);
        //这个参数在的设定应该注意最大礼物数量时不要超出屏幕边界。
        make.top.equalTo(superView.mas_top).offset(400);
    }];
    v.backgroundColor = [UIColor clearColor];
    return v;
}
```

### <a id="自定义配置"></a>自定义配置
* `LiveGiftShowCustom` 管理所有弹幕的视图

|两个弹幕之间的高度差|两个交换动画时长|
|:----------------:|:------------:|
|kGiftViewMargin  |kExchangeAnimationTime|
|50.0               |0.25         |

* `LiveGiftShowView`一个弹幕的视图

|弹幕背景宽|弹幕背景高|送礼者名称字号|送礼者名称文字颜色|礼物寄语字号|礼物寄语文字颜色|
|:------:|:------:|:------:|:------:|:------:|:------:|
|kViewWidth|kViewHeight|kNameLabelFont|kNameLabelTextColor|kGiftLabelFont|kGiftLabelTextColor|
|240.0|44.0|12.0|whiteColor|10.0|orangeColor|

|每个数字图片宽度|弹幕几秒后消失|数字改变动画时长|弹幕消失动画时长|
|:------:|:------:|:------:|:------:|
|kGiftNumberWidth|kTimeOut|kNumberAnimationTime|kRemoveAnimationTime|
|15.0|3|0.25|0.5|

## <a id="关于我"></a>关于我
 * 如果在使用过程中遇到问题，或者想要与我分享／吐槽／建议／意见<jonhory@163.com>

