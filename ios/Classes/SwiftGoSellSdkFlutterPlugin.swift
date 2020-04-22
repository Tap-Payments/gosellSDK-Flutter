import Flutter
import UIKit

public class SwiftGoSellSdkFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "go_sell_sdk_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftGoSellSdkFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    // print("sssssssssss....")//
    // call.arguments
    // NSNumber *maxWidth = [_arguments objectForKey:@"appCredentials"];
    // var appCredentials = [String : String]()
    // var secrete_key = call.arguments.flatMap { $0.AnyObject as [String : String]}.flatMap { $0 }
    // print("Flatmap: \(flatCars)") 

    result("iOS  + sssssssssss " )
  }
}
