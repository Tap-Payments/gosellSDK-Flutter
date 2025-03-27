package tap.company.go_sell_sdk_flutter;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleOwner;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class GoSellSdkFlutterPlugin implements MethodChannel.MethodCallHandler, FlutterPlugin, ActivityAware {

    private class LifeCycleObserver
            implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {
        private final Activity thisActivity;

        LifeCycleObserver(Activity activity) {
            this.thisActivity = activity;
        }

        @Override
        public void onCreate(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onStart(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onResume(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onPause(@NonNull LifecycleOwner owner) {
        }

        @Override
        public void onStop(@NonNull LifecycleOwner owner) {
            onActivityStopped(thisActivity);
        }

        @Override
        public void onDestroy(@NonNull LifecycleOwner owner) {
            onActivityDestroyed(thisActivity);
        }

        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
        }

        @Override
        public void onActivityStarted(Activity activity) {
        }

        @Override
        public void onActivityResumed(Activity activity) {
        }

        @Override
        public void onActivityPaused(Activity activity) {
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            if (thisActivity == activity && activity.getApplicationContext() != null) {
                ((Application) activity.getApplicationContext())
                        .unregisterActivityLifecycleCallbacks(this);
            }
        }

        @Override
        public void onActivityStopped(Activity activity) {
            if (thisActivity == activity) {
            }
        }
    }

    private MethodChannel channel;
    private GoSellSdKDelegate delegate;
    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Application application;
    private Activity activity;
    private Lifecycle lifecycle;
    private LifeCycleObserver observer;
    private static final String CHANNEL = "tap.company.go_sell_sdk_flutter.GoSellSdkFlutterPlugin";

    @Override
    public void onAttachedToEngine(FlutterPluginBinding binding) {
        pluginBinding = binding;
    }

    @Override
    public void onDetachedFromEngine(FlutterPluginBinding binding) {
        pluginBinding = null;
    }

    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        activityBinding = binding;
        setup(
                pluginBinding.getBinaryMessenger(),
                (Application) pluginBinding.getApplicationContext(),
                binding.getActivity(),
                binding
        );
    }

    @Override
    public void onDetachedFromActivity() {
        tearDown();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    private void setup(
            final BinaryMessenger messenger,
            final Application application,
            final Activity activity,
            final ActivityPluginBinding activityBinding) {
        this.activity = activity;
        this.application = application;
        this.delegate = constructDelegate(activity);
        channel = new MethodChannel(messenger, "go_sell_sdk_flutter");
        channel.setMethodCallHandler(this);
        observer = new LifeCycleObserver(activity);

        if (activityBinding != null) {
            activityBinding.addActivityResultListener(delegate);
            activityBinding.addRequestPermissionsResultListener(delegate);
        }
    }

    private void tearDown() {
        if (activityBinding != null) {
            activityBinding.removeActivityResultListener(delegate);
            activityBinding.removeRequestPermissionsResultListener(delegate);
            activityBinding = null;
        }
        
        if (lifecycle != null) {
            lifecycle.removeObserver(observer);
            lifecycle = null;
        }
        
        delegate = null;
        
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
        
        if (application != null) {
            application.unregisterActivityLifecycleCallbacks(observer);
            application = null;
        }
    }

    private final GoSellSdKDelegate constructDelegate(final Activity setupActivity) {
        return new GoSellSdKDelegate(setupActivity);
    }

    private static class MethodResultWrapper implements MethodChannel.Result {
        private MethodChannel.Result methodResult;
        private Handler handler;

        MethodResultWrapper(MethodChannel.Result result) {
            methodResult = result;
            handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object result) {
            System.out.println("success coming from delegate : " + result);
            handler.post(() -> methodResult.success(result));
        }

        @Override
        public void error(
                final String errorCode, final String errorMessage, final Object errorDetails) {
            System.out.println("error encountered................." + errorCode);
            handler.post(() -> methodResult.error(errorCode, errorMessage, errorDetails));
        }

        @Override
        public void notImplemented() {
            handler.post(() -> methodResult.notImplemented());
        }
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result rawResult) {
        HashMap<String, Object> args = call.arguments();
        System.out.println("args : " + args);
        System.out.println("onMethodCall..... started");
        
        if (activity == null) {
            rawResult.error("no_activity", "SDK plugin requires a foreground activity.", null);
            return;
        }

        if (call.method.equals("terminate_session")) {
            System.out.println("terminate session!");
            delegate.terminateSDKSession();
            return;
        }
        
        MethodChannel.Result result = new MethodResultWrapper(rawResult);
        delegate.startSDK(call, result, args);
    }
}