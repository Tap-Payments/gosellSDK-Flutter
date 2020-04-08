#import "GoSellSdkFlutterPlugin.h"
#if __has_include(<go_sell_sdk_flutter/go_sell_sdk_flutter-Swift.h>)
#import <go_sell_sdk_flutter/go_sell_sdk_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "go_sell_sdk_flutter-Swift.h"
#endif

@implementation GoSellSdkFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGoSellSdkFlutterPlugin registerWithRegistrar:registrar];
}
@end
