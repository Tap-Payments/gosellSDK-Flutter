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

    private MethodChannel channel;
    private GoSellSdKDelegate delegate;
    private FlutterPluginBinding pluginBinding;
    private ActivityPluginBinding activityBinding;
    private Application application;
    private Activity activity;
    private Lifecycle lifecycle;
    private LifeCycleObserver observer;
    private static final String CHANNEL = "go_sell_sdk_flutter";

    private class LifeCycleObserver 
            implements Application.ActivityLifecycleCallbacks, DefaultLifecycleObserver {
        private final Activity thisActivity;

        LifeCycleObserver(Activity activity) {
            this.thisActivity = activity;
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            if (thisActivity == activity && activity.getApplicationContext() != null) {
                ((Application) activity.getApplicationContext())
                        .unregisterActivityLifecycleCallbacks(this);
            }
        }

        // Other required method stubs... (keep the previous implementation)
        @Override
        public void onCreate(@NonNull LifecycleOwner owner) {}
        @Override
        public void onStart(@NonNull LifecycleOwner owner) {}
        @Override
        public void onResume(@NonNull LifecycleOwner owner) {}
        @Override
        public void onPause(@NonNull LifecycleOwner owner) {}
        @Override
        public void onStop(@NonNull LifecycleOwner owner) {}
        @Override
        public void onDestroy(@NonNull LifecycleOwner owner) {}
        @Override
        public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}
        @Override
        public void onActivityStarted(Activity activity) {}
        @Override
        public void onActivityResumed(Activity activity) {}
        @Override
        public void onActivityPaused(Activity activity) {}
        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}
        @Override
        public void onActivityStopped(Activity activity) {}
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        pluginBinding = flutterPluginBinding;
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (channel != null) {
            channel.setMethodCallHandler(null);
            channel = null;
        }
        pluginBinding = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activityBinding = binding;
        activity = binding.getActivity();
        application = (Application) activity.getApplicationContext();
        
        delegate = new GoSellSdKDelegate(activity);
        
        binding.addActivityResultListener(delegate);
        binding.addRequestPermissionsResultListener(delegate);
        
        observer = new LifeCycleObserver(activity);
        application.registerActivityLifecycleCallbacks(observer);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        if (activityBinding != null) {
            activityBinding.removeActivityResultListener(delegate);
            activityBinding.removeRequestPermissionsResultListener(delegate);
            activityBinding = null;
        }
        
        if (application != null && observer != null) {
            application.unregisterActivityLifecycleCallbacks(observer);
        }
        
        activity = null;
        delegate = null;
        observer = null;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result rawResult) {
        MethodChannel.Result result = new MethodResultWrapper(rawResult);
        
        if (activity == null) {
            rawResult.error("no_activity", "SDK plugin requires a foreground activity.", null);
            return;
        }

        HashMap<String, Object> args = call.arguments();
        
        if ("terminate_session".equals(call.method)) {
            delegate.terminateSDKSession();
            return;
        }
        
        delegate.startSDK(call, result, args);
    }

    private static class MethodResultWrapper implements MethodChannel.Result {
        private final MethodChannel.Result methodResult;
        private final Handler handler;

        MethodResultWrapper(MethodChannel.Result result) {
            this.methodResult = result;
            this.handler = new Handler(Looper.getMainLooper());
        }

        @Override
        public void success(final Object result) {
            handler.post(() -> methodResult.success(result));
        }

        @Override
        public void error(String errorCode, String errorMessage, Object errorDetails) {
            handler.post(() -> methodResult.error(errorCode, errorMessage, errorDetails));
        }

        @Override
        public void notImplemented() {
            handler.post(methodResult::notImplemented);
        }
    }
}