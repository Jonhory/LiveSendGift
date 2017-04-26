![](http://ww4.sinaimg.cn/large/c6a1cfeagw1f9ptsozcu5j20b206rt92.jpg)


按照惯例，先贴[GitHub源码地址](https://github.com/JonHory/LiveSendGift)

## 已知存在的BUG

### 如下图（在某种情况下，旧视图移除时它下方的视图会向上移动，导致出现视图重叠的效果，这是我不想看到的。）:

![](http://ww1.sinaimg.cn/large/c6a1cfeagy1fdp2kbbn1sj20af0hy407)

### 以下是动图效果：

![](http://ww1.sinaimg.cn/large/c6a1cfeagy1fdp2hb2mfpg20aa0ikdos)

### BUG分析:

* 当存储视图的数组`showViewArr`的第一个视图移除完毕后，触发`LiveGiftShowCustom.m L:123`的回调block`newShowView.liveGiftShowViewTimeOut`,执行`[weakSelf resetY];`产生下面的视图向上移动的效果。`resetY`的实现原理是`showF.origin.y = i * (kViewHeight+kGiftViewMargin);`，此时`i`是`1`,则第三个视图移动到第二个视图的位置，产生覆盖在移除中的第二个视图的重叠效果。这里贴出来，一个是希望使用该库的猿能了解到该情况，能否接受该BUG，第二个是有猿能帮助我解决这个问题，第三个是自己记下来，万一哪天想通了就解决了 :) 。


##导航
* [目标](#目标)
* [版本更新说明](#版本更新说明)
* [快速使用](#快速使用)
* [自定义配置](#自定义配置)

##<a id="目标"></a>目标:

* 弹幕过几秒自动消失
* 实现A用户弹幕出现时，B用户发送礼物，B用户弹幕在A用户弹幕下方,A/B用户弹幕存在时，A/B用户连续发送礼物，弹幕显示的礼物数量增加，谁的礼物数量较大，谁的弹幕在上方。
* A/B用户弹幕存在时，C用户发送礼物，A/B用户中较早出现的弹幕被替换成C用户的弹幕数据，并且C用户的弹幕处于下方


###<a id="版本更新说明"></a>版本更新:

#### V1.0
* 大致实现了不同用户增加弹幕的效果

![](http://ww4.sinaimg.cn/large/c6a1cfeagw1f9p4246hkgg208g0fdmyy.gif)


#### V1.1
* 实现了用户连续发送数字增加效果
* 实现了新增弹幕从空位出现的效果

![](http://ww4.sinaimg.cn/large/c6a1cfeagw1f9p48oumbkg208g0fd0wo.gif)

#### V1.2
* 实现了第二个用户之后送礼物替换较早的弹幕效果(完善)

![](http://ww3.sinaimg.cn/large/c6a1cfeagw1f9p51eh3ltg208g0fdwif.gif)

#### V1.3
* 实现了上面的视图移除后，正在连击的下面的视图移动到上面的效果

![](http://ww3.sinaimg.cn/large/c6a1cfeagw1f9p6jibv9gg208g0fdq3i.gif)

#### V1.4
* 实现了目标效果😊😊😊

![](http://ww2.sinaimg.cn/large/c6a1cfeagw1f9p7t0w9bng208g0fd0x3.gif)

#### V1.5
* 实现了自定义最大礼物数量的需求

![](http://ww2.sinaimg.cn/large/c6a1cfeagw1favehbqaz9g20b50jrnbh.gif)

#### V1.6
* 新增了自下而上的展现效果

![](http://ww1.sinaimg.cn/large/c6a1cfeagy1ff0axbjpy4g20a30i8whh.gif)

###<a id="快速使用"></a>快速使用
* 使用的第三方库:
  * [Masonry](https://github.com/SnapKit/Masonry)
  * [SDWebImage](https://github.com/rs/SDWebImage)

* 两个模型:`ZYGiftListModel`和`UserModel`
  * `ZYGiftListModel`是用来显示弹幕上右侧礼物图片`picUrl`和打赏的语句`rewardMsg`的，礼物有`type`字段
  * `UserModel`是用来显示送礼物的人的名称`name`和头像`iconUrl`
  
* V1.4只需要导入`#import "LiveGiftShow.h"`
* V1.5只需要导入`#import "LiveGiftShowCustom.h"`,具体使用可参考`V15TestVC.m`,不建议同时使用`LiveGiftShow.h`和`LiveGiftShowCustom.h`
* V1.6只需要导入`#import "LiveGiftShowCustom.h"`,具体使用可参考`V15TestVC.m`,向V1.5兼容。如有需要更新，只需要将`LiveGiftShowCustom.h`和`LiveGiftShowCustom.m`替换为V1.6版本的文件即可。

* `@property (nonatomic ,weak) LiveGiftShow * giftShow;`

```
 - (LiveGiftShow *)giftShow{
    if (!_giftShow) {
        LiveGiftShow * giftShow = [[LiveGiftShow alloc]init];
        [self.view addSubview:giftShow];
        _giftShow = giftShow;
        [giftShow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@244);
            make.height.equalTo(@50);
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.view.mas_top).offset(100);
        }];
    }
    return _giftShow;
}
```  

* 在开发中使用

```
LiveGiftShowModel * listModel = [LiveGiftShowModel giftModel:self.giftArr[3] 
                                                   userModel:[UserModel random]];
[self.giftShow addGiftListModel:listModel];
```
即可完成接入。每一次点击只需要`[self.giftShow addGiftListModel:listModel];`即可自动计数加一。最高支持显示9999。

### 特别说明
* 在V1.6版本中,`LiveGiftShowCustom.m`

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

###<a id="自定义配置"></a>自定义配置
* `LiveGiftShow` V1.4管理所有弹幕的视图
* `LiveGiftShowCustom` V1.5之后管理所有弹幕的视图

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

