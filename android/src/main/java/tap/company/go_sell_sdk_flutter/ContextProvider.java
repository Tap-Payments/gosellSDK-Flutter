package tap.company.go_sell_sdk_flutter;

import android.app.Activity;

public class ContextProvider {

    private static Activity context;

    public static void setContext(Activity mainActivity) {
        context = mainActivity;
    }

    public static Activity getContext() {
        return context;
    }


}
