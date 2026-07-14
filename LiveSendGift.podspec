Pod::Spec.new do |s|
  s.name             = 'LiveSendGift'
  s.version          = '2.0.0'
  s.summary          = '直播送礼物弹幕效果：连击计数、轨道排序、队列/替换模式。'
  s.description      = <<-DESC
直播间送礼物弹幕横幅效果：礼物连击数字累加、多用户弹幕按礼物数排序、
旧弹幕替换/等待队列两种模式、左右出入场动画、固定轨道等。
V2.0 起支持多实例独立配置、线程安全调用、userId 区分同名用户。
                       DESC

  s.homepage         = 'https://github.com/Jonhory/LiveSendGift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jonhory' => 'jonhory@qq.com' }
  s.source           = { :git => 'https://github.com/Jonhory/LiveSendGift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.requires_arc     = true
  s.frameworks       = 'UIKit'

  # 默认集成 SDWebImage 加载网络图片；
  # 使用自研/Kingfisher 等加载器的宿主可只引 'LiveSendGift/Core'（零三方依赖），
  # 并注入 webImageLoader。
  s.default_subspec  = 'SDWebImage'

  s.subspec 'Core' do |core|
    core.source_files     = 'LiveSendGift/LiveGiftShowView/*.{h,m}'
    core.resource_bundles = {
      'LiveSendGift' => [
        'LiveSendGift/LiveGiftShowView/LiveSendGiftAssets.xcassets',
        'LiveSendGift/LiveGiftShowView/PrivacyInfo.xcprivacy'
      ]
    }
  end

  s.subspec 'SDWebImage' do |sd|
    sd.dependency 'LiveSendGift/Core'
    sd.dependency 'SDWebImage'
  end
end
