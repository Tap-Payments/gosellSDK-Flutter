package tap.company.go_sell_sdk_flutter;

import android.app.Activity;
import android.content.Intent;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * GoSellSdkFlutterPlugin
 */
public class GoSellSdkFlutterPlugin  implements FlutterPlugin, MethodCallHandler{

    Activity activity;


    public GoSellSdkFlutterPlugin() {
        activity =ContextProvider.getContext();
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "go_sell_sdk_flutter");
        channel.setMethodCallHandler(new GoSellSdkFlutterPlugin());
    }

    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "go_sell_sdk_flutter");
        channel.setMethodCallHandler(new GoSellSdkFlutterPlugin());
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("start_sdk")) {
//      result.success("Android " + android.os.Build.VERSION.RELEASE);

            activity.startActivity(new Intent(activity,SDKStarterActivity.class));
            
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    }


}
