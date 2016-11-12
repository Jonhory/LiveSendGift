![](http://ww4.sinaimg.cn/large/c6a1cfeagw1f9ptsozcu5j20b206rt92.jpg)


按照惯例，先贴[GitHub源码地址](https://github.com/JonHory/LiveSendGift)

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

###<a id="快速使用"></a>快速使用
* 使用的第三方库:
  * [Masonry](https://github.com/SnapKit/Masonry)
  * [SDWebImage](https://github.com/rs/SDWebImage)

* 两个模型:`ZYGiftListModel`和`UserModel`
  * `ZYGiftListModel`是用来显示弹幕上右侧礼物图片`picUrl`和打赏的语句`rewardMsg`的，礼物有`type`字段
  * `UserModel`是用来显示送礼物的人的名称`name`和头像`iconUrl`
  
* 只需要导入即可`#import "LiveGiftShow.h"`
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

###<a id="自定义配置"></a>自定义配置
* `LiveGiftShow` 管理所有弹幕的视图

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