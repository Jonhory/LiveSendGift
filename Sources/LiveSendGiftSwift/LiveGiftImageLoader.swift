//
//  LiveGiftImageLoader.swift
//  LiveSendGiftSwift
//
//  库内图片与网络图片的统一加载。
//

import UIKit

/// 网络图片加载器。宿主可注入自己的实现（Kingfisher/SDWebImage/自研均可）。
/// - Parameters:
///   - imageView: 目标视图（头像 / 礼物图）
///   - urlString: 图片地址，可能为 nil
///   - placeholder: 占位图，可能为 nil
public typealias LiveGiftWebImageLoader = (UIImageView, String?, UIImage?) -> Void

/// 库内资源图片（数字/背景/默认头像）加载，
/// 兼容 SPM（Bundle.module）、CocoaPods resource_bundles、手动拷贝三种集成方式。
func liveGiftImage(_ name: String) -> UIImage? {
    // 手动拷贝集成 / demo：资源编译进主 bundle
    if let image = UIImage(named: name) { return image }
    #if SWIFT_PACKAGE
    if let image = UIImage(named: name, in: .module, compatibleWith: nil) { return image }
    #endif
    // CocoaPods resource_bundles 集成：资源在 LiveSendGiftSwift.bundle 内
    let classBundle = Bundle(for: LiveGiftShowCustom.self)
    if let url = classBundle.url(forResource: "LiveSendGiftSwift", withExtension: "bundle"),
       let bundle = Bundle(url: url),
       let image = UIImage(named: name, in: bundle, compatibleWith: nil) {
        return image
    }
    return UIImage(named: name, in: classBundle, compatibleWith: nil)
}

/// 默认网络图片加载器：URLSession + NSCache。
/// ponytail: 无磁盘缓存与请求合并，重度场景请注入 Kingfisher/SDWebImage 等专业加载器。
enum LiveGiftDefaultWebImageLoader {

    private static let cache = NSCache<NSString, UIImage>()

    static func load(_ imageView: UIImageView, _ urlString: String?, _ placeholder: UIImage?) {
        imageView.image = placeholder
        guard let urlString, let url = URL(string: urlString) else { return }
        if let cached = cache.object(forKey: urlString as NSString) {
            imageView.image = cached
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            cache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
}
