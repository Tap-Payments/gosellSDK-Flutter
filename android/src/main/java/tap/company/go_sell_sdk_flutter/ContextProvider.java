package tap.company.go_sell_sdk_flutter;

import android.content.Context;

public class ContextProvider {

    private static Context context;

    public static void setContext(Context mainActivity) {
        context = mainActivity;
    }

    public static Context getContext() {
        return context;
    }


}
