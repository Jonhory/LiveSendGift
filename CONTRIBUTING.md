# 贡献指南

感谢参与！提交 issue / PR 前请阅读以下约定。

## 开发环境

```bash
pod install
open LiveSendGift.xcworkspace   # scheme 选 LiveSendGiftDemo
```

Swift 库（`Sources/LiveSendGiftSwift/`）可用 Xcode 直接打开仓库根目录以 SPM 包模式开发（scheme `LiveSendGift-Package`）。

## 提交前检查

1. **格式化**（仓库根目录已提供配置）：

   ```bash
   xcrun clang-format -i <改动的 .h/.m>
   xcrun swift-format format -i --configuration .swift-format <改动的 .swift>
   ```

2. **测试全部通过**：

   ```bash
   # workspace（ObjC 单测 + UI 测试）
   xcodebuild test -workspace LiveSendGift.xcworkspace -scheme LiveSendGiftDemo \
     -destination 'platform=iOS Simulator,name=iPhone 16'

   # SPM 包（Swift 版单测）——需在不含 workspace 的干净目录执行
   rsync -a --exclude='*.xcodeproj' --exclude='*.xcworkspace' --exclude='Pods' . /tmp/spm-pkg
   cd /tmp/spm-pkg && xcodebuild test -scheme LiveSendGift-Package \
     -destination 'platform=iOS Simulator,name=iPhone 16'
   ```

3. 修 bug 请附带能复现问题的测试用例；改核心逻辑（队列/计数/排序）必须有对应单测。

## 约定

- ObjC 版处于维护模式，只接受 bug 修复；新功能请提到 Swift 版（`LiveSendGiftSwift`）。
- 公开 API 变更需在 `CHANGELOG.md` 的 Unreleased 段记录；破坏性变更需同时更新 `MIGRATION.md`。
- commit message 建议使用 `feat:` / `fix:` / `docs:` / `chore:` 前缀。
