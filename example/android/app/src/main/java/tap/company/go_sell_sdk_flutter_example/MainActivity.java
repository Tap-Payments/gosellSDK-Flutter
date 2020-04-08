package tap.company.go_sell_sdk_flutter_example;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import tap.company.go_sell_sdk_flutter.ContextProvider;

public class MainActivity extends FlutterActivity {
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    ContextProvider.setContext(this);
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }
}
