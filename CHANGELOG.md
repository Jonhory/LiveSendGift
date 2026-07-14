# Changelog

本项目版本历史。V2.0 起遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [Unreleased]

### 新增
- demo 新增 Swift 版演示页（首页「Swift 版演示 队列模式」入口）
- 轨道排序/补位单元测试（ObjC 与 Swift 各 2 个）
- `.clang-format` / `.swift-format` 统一代码风格
- GitHub Actions 供应链加固（最小权限、SHA pin、Dependabot）、CI 版本一致性检查
- Swift 版开启 StrictConcurrency 检查，为 Swift 6 做准备

### 修复 / 安全
- demo 图床链接切换 https，移除 `NSAllowsArbitraryLoads`（ATS 恢复默认）
- Swift 版默认图片加载器增加内存缓存上限与单图响应体上限
- podspec 的 SDWebImage 依赖收紧为 `~> 5.0`

### 变更
- 弹幕超时移除由每秒轮询定时器改为可重置的延时任务（两版同步，更省电）

## [2.1.0] - 2026-07-14

### 新增
- **Swift 版 `LiveSendGiftSwift`**：按 ObjC 版逻辑完整移植、行为一致、零三方依赖（内置 URLSession 图片加载器，可注入 Kingfisher/SDWebImage/自研），推荐新项目使用
- `LiveSendGiftSwift.podspec` 与 SPM `LiveSendGiftSwift` product

### 变更
- ObjC 版进入维护模式，只修 bug 不加新功能

## [2.0.0] - 2026-07-14

> 破坏性升级。本版本由 AI（Claude）协助推进。迁移指南见 [MIGRATION.md](MIGRATION.md)。

### 修复
- 修复挂起多年的 [#17](https://github.com/Jonhory/LiveSendGift/issues/17)：同 key 并发连击合并进已有定时器，数字不再失控
- 弹幕移除回调增加越界防护
- 左移出弹幕不参与轨道补位判断的问题
- 固定轨道 demo「同时添加多条」按钮无响应

### 变更（破坏性）
- 全部配置由全局 static 改为实例属性，多实例互不影响
- 公开 API 线程安全：非主线程调用自动转主队列
- `LiveUserModel` 新增 `userId`，同名用户不再被错误合并
- `LiveGiftShowNumberView`：`number`（副作用 getter）→ `resetNumber:` / `increaseNumber` / `currentNumber`
- 命名修正：`creatDate`→`createDate`，`hiddenModel`（属性）→`hiddenMode`
- 移除 Masonry 依赖，布局改用系统 `NSLayoutAnchor`
- 最低部署目标升至 iOS 12.0

### 新增
- CocoaPods（`Core` / `SDWebImage` subspec）与 Swift Package Manager 支持
- `webImageLoader` 图片加载器注入点
- `PrivacyInfo.xcprivacy` 隐私清单
- 核心逻辑单元测试与 GitHub Actions CI
- 全部头文件 nullability 标注

## 1.x（2016-11 ~ 2022-11）

早期版本历史见 [README 版本更新说明](README.md#版本更新说明)。
