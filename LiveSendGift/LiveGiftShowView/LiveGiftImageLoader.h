//
//  LiveGiftImageLoader.h
//  LiveSendGift
//
//  V2.0 新增：库内图片统一加载入口。
//  兼容三种集成方式：手动拷贝（主 bundle）、CocoaPods resource_bundles（LiveSendGift.bundle）、
//  以及作为动态框架集成（框架 bundle）。
//

#import <UIKit/UIKit.h>

static inline UIImage * _Nullable LiveGiftImage(NSString * _Nonnull name) {
    // 手动拷贝集成 / demo：资源编译进主 bundle
    UIImage *image = [UIImage imageNamed:name];
    if (image) {
        return image;
    }
    // CocoaPods resource_bundles 集成：资源在 LiveSendGift.bundle 内
    NSBundle *classBundle = [NSBundle bundleForClass:NSClassFromString(@"LiveGiftShowCustom")];
    NSURL *bundleURL = [classBundle URLForResource:@"LiveSendGift" withExtension:@"bundle"];
    // Swift Package Manager 集成：资源在 LiveSendGift_LiveSendGift.bundle 内
    if (!bundleURL) {
        bundleURL = [[NSBundle mainBundle] URLForResource:@"LiveSendGift_LiveSendGift" withExtension:@"bundle"];
    }
    NSBundle *resourceBundle = bundleURL ? [NSBundle bundleWithURL:bundleURL] : classBundle;
    return [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
}
