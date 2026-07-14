Pod::Spec.new do |s|
  s.name             = 'LiveSendGiftSwift'
  s.version          = '2.1.0'
  s.summary          = '直播送礼物弹幕效果（Swift 版）：连击计数、轨道排序、队列/替换模式。'
  s.description      = <<-DESC
LiveSendGift 的 Swift 移植版，行为与 ObjC 版保持一致：
礼物连击数字累加、多用户弹幕按礼物数排序、替换/等待队列两种模式、
左右出入场动画、实例级配置、线程安全、userId 区分同名用户。
零三方依赖：内置 URLSession 图片加载器，可注入 Kingfisher/SDWebImage/自研加载器。
                       DESC

  s.homepage         = 'https://github.com/Jonhory/LiveSendGift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jonhory' => 'jonhory@qq.com' }
  s.source           = { :git => 'https://github.com/Jonhory/LiveSendGift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.swift_version    = '5.9'
  s.frameworks       = 'UIKit'

  s.source_files     = 'Sources/LiveSendGiftSwift/*.swift'
  s.resource_bundles = {
    'LiveSendGiftSwift' => [
      'Sources/LiveSendGiftSwift/LiveSendGiftAssets.xcassets',
      'Sources/LiveSendGiftSwift/PrivacyInfo.xcprivacy'
    ]
  }
end
