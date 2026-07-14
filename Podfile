# Uncomment this line to define a global platform for your project
 platform :ios, '12.0'

target 'LiveSendGift' do
  # Uncomment this line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!
  pod 'MJExtension'
  pod 'Masonry'
  pod 'SDWebImage'

  # Pods for LiveSendGift

end

# 统一 Pods 的部署目标，消除旧 target 警告
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
