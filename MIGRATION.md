# V1.x → V2.x 迁移指南

V2.0 为破坏性升级，最低支持 iOS 12.0。以下为旧 API → 新 API 对照。

## LiveGiftShowCustom

配置由全局 static 改为**实例属性**（多实例互不影响），方法名基本不变：

| V1.x | V2.x | 说明 |
|---|---|---|
| `[v setMaxRailwayCount:3]` | `v.maxRailwayCount = 3` | 同名属性 |
| `[v setRailwayCanExchange:YES]` | `v.railwayCanExchange = YES` | 同名属性 |
| `[v setShowMode:...]` | `v.showMode = ...` | 同名属性 |
| `[v setHiddenModel:...]` | `v.hiddenMode = ...` | 旧方法保留至 3.0，已标 deprecated |
| `[v setAppearModel:...]` | `v.appearMode = ...` | 旧方法保留至 3.0，已标 deprecated |
| `[v enableInterfaceDebug:YES]` | `v.interfaceDebugEnabled = YES` | 旧方法保留至 3.0，已标 deprecated |

行为变化：

- **线程安全**：`addLiveGiftShowModel:` / `animatedWithGiftModel:` 可从任意线程调用，内部自动转主队列（V1.x 必须自行保证主线程）。
- **连击合并**：同 key（userId+礼物类型）已有连击定时器时，新连击合并进已有定时器（修复 #17），不再叠加定时器。
- 新增 `webImageLoader` 属性可注入自定义图片加载器；不注入且集成了 SDWebImage 时行为与 V1.x 相同。

## LiveUserModel

- 新增 `userId`（推荐必传）：V1.x 以 `name+礼物类型` 区分弹幕，同名用户会被合并；V2.x 优先用 `userId`，不传时退化为 V1.x 行为。

## LiveGiftShowView

| V1.x | V2.x |
|---|---|
| `creatDate` | `createDate` |
| `hiddenModel`（属性） | `hiddenMode` |

## LiveGiftShowNumberView

带自增副作用的 `number` getter 被移除：

| V1.x | V2.x |
|---|---|
| `nv.number = 5`（设置起点） | `[nv resetNumber:5]` |
| `NSInteger n = nv.number`（读取并 +1） | `NSInteger n = [nv increaseNumber]` |
| `[nv getLastNumber]` | `[nv currentNumber]` |

## 依赖与集成

- **Masonry 不再需要**（V2.0 起布局使用系统 NSLayoutAnchor），可从 Podfile 移除。
- CocoaPods：`pod 'LiveSendGift'`（含 SDWebImage）或 `pod 'LiveSendGift/Core'`（零三方依赖，配合 `webImageLoader`）。
- 手动集成者注意：库图片资源已移至 `LiveGiftShowView/LiveSendGiftAssets.xcassets`，随目录一起拷贝即可。

## 新项目建议

直接使用 Swift 版 `LiveSendGiftSwift`（V2.1+，零三方依赖），API 见 [README](README.md#Swift)。
