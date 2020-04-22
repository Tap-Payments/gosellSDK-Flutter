package tap.company.go_sell_sdk_flutter;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Type;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import company.tap.gosellapi.GoSellSDK;
import company.tap.gosellapi.internal.api.callbacks.GoSellError;
import company.tap.gosellapi.internal.api.models.Authorize;
import company.tap.gosellapi.internal.api.models.Charge;
import company.tap.gosellapi.internal.api.models.PhoneNumber;
import company.tap.gosellapi.internal.api.models.SaveCard;
import company.tap.gosellapi.internal.api.models.SavedCard;
import company.tap.gosellapi.internal.api.models.Token;
import company.tap.gosellapi.open.controllers.SDKSession;
import company.tap.gosellapi.open.controllers.ThemeObject;
import company.tap.gosellapi.open.delegate.SessionDelegate;
import company.tap.gosellapi.open.enums.AppearanceMode;
import company.tap.gosellapi.open.enums.CardType;
import company.tap.gosellapi.open.enums.TransactionMode;
import company.tap.gosellapi.open.exception.CurrencyException;
import company.tap.gosellapi.open.models.CardsList;
import company.tap.gosellapi.open.models.Customer;
import company.tap.gosellapi.open.models.PaymentItem;
import company.tap.gosellapi.open.models.Receipt;
import company.tap.gosellapi.open.models.TapCurrency;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class GoSellSdKDelegate implements PluginRegistry.ActivityResultListener,
        PluginRegistry.RequestPermissionsResultListener, SessionDelegate {

    private SDKSession sdkSession;
    private Activity activity;
    private MethodChannel.Result pendingResult;
    private MethodCall methodCall;


    public GoSellSdKDelegate(Activity _activity) {
        this.activity = _activity;
    }


    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        return false;
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        return false;
    }


    public void startSDK(MethodCall methodCall, MethodChannel.Result result, HashMap<String, Object> sdkConfigurations) {

        if (!setPendingMethodCallAndResult(methodCall, result)) {
            finishWithAlreadyActiveError(result);
            return;
        }
        // start SDK
        showSDK(sdkConfigurations, result);
    }

    private void finishWithAlreadyActiveError(MethodChannel.Result result) {
        result.error("already_active", "SDK is already active", null);
    }

    private boolean setPendingMethodCallAndResult(
            MethodCall methodCall, MethodChannel.Result result) {
        if (pendingResult != null) {
            return false;
        }

        this.methodCall = methodCall;
        pendingResult = result;

        return true;
    }

    private void showSDK(HashMap<String, Object> sdkConfigurations, MethodChannel.Result result) {
        /**
         * Required step.
         * Configure SDK with your Secret API key and App Bundle name registered with tap company.
         */
        HashMap<String, String> appConfigurations = (HashMap<String, String>) sdkConfigurations.get("appCredentials");
        configureApp(appConfigurations.get("secrete_key"), appConfigurations.get("bundleID"), appConfigurations.get("language"));

//        configureSDKThemeObject();

        /**
         * Required step.
         * Configure SDK Session with all required data.
         */
        configureSDKSession(sdkConfigurations, result);
        sdkSession.start(activity);
    }


    private void configureApp(String secrete_key, String bundleID, String language) {
        GoSellSDK.init(activity, secrete_key, bundleID);  // to be replaced by merchant
        GoSellSDK.setLocale(language);  // to be replaced by merchant
    }

    private void configureSDKThemeObject() {

        ThemeObject.getInstance()
                .setAppearanceMode(AppearanceMode.WINDOWED_MODE)
//
//                .setHeaderFont(Typeface.createFromAsset(getAssets(), "fonts/roboto_light.ttf"))
//                .setHeaderTextColor(getResources().getColor(R.color.black1))
//                .setHeaderTextSize(17)
//                .setHeaderBackgroundColor(getResources().getColor(R.color.french_gray_new))
//
//
//                .setCardInputFont(Typeface.createFromAsset(getAssets(), "fonts/roboto_light.ttf"))
//                .setCardInputTextColor(getResources().getColor(R.color.black))
//                .setCardInputInvalidTextColor(getResources().getColor(R.color.red))
//                .setCardInputPlaceholderTextColor(getResources().getColor(R.color.gray))
//
//
//                .setSaveCardSwitchOffThumbTint(getResources().getColor(R.color.french_gray_new))
//                .setSaveCardSwitchOnThumbTint(getResources().getColor(R.color.vibrant_green))
//                .setSaveCardSwitchOffTrackTint(getResources().getColor(R.color.french_gray))
//                .setSaveCardSwitchOnTrackTint(getResources().getColor(R.color.vibrant_green_pressed))
//
//                .setScanIconDrawable(getResources().getDrawable(R.drawable.btn_card_scanner_normal))
//
//                .setPayButtonResourceId(R.drawable.btn_pay_selector)  //btn_pay_merchant_selector
//                .setPayButtonFont(Typeface.createFromAsset(getAssets(), "fonts/roboto_light.ttf"))
//
//                .setPayButtonDisabledTitleColor(getResources().getColor(R.color.white))
//                .setPayButtonEnabledTitleColor(getResources().getColor(R.color.white))
                .setPayButtonTextSize(14)
                .setPayButtonLoaderVisible(true)
                .setPayButtonSecurityIconVisible(true)
        ;

    }

    /**
     * Configure SDK Session
     *
     * @param sdkConfigurations
     * @param result
     */
    private void configureSDKSession(HashMap<String, Object> sdkConfigurations, MethodChannel.Result result) {
        HashMap<String, Object> sessionParameters = (HashMap<String, Object>) sdkConfigurations.get("sessionParameters");

        // Instantiate SDK Session
        if (sdkSession == null) sdkSession = new SDKSession();   //** Required **

        // pass your activity as a session delegate to listen to SDK internal payment process follow
        sdkSession.addSessionDelegate(this);    //** Required **

        // initiate PaymentDataSource
        sdkSession.instantiatePaymentDataSource();    //** Required **

        // sdk mode
        sdkSession.setTransactionMode(getTransactionMode(sessionParameters.get("trxMode")));

        // set transaction currency associated to your account
        TapCurrency transactionCurrency;
        try {
            transactionCurrency = new TapCurrency((String) Objects.requireNonNull(sessionParameters.get("transactionCurrency")));
        } catch (CurrencyException c) {
            Log.d("GoSellSDKDelegate : ", "Unknown currency exception thrown : " + (String) Objects.requireNonNull(sessionParameters.get("transactionCurrency")));
            transactionCurrency = new TapCurrency("KWD");
        } catch (Exception e) {
            Log.d("GoSellSDKDelegate : ", "Unknown currency: " + (String) Objects.requireNonNull(sessionParameters.get("transactionCurrency")));
            transactionCurrency = new TapCurrency("KWD");
        }

        sdkSession.setTransactionCurrency(transactionCurrency);    //** Required **

        // Using static CustomerBuilder method available inside TAP Customer Class you can populate TAP Customer object and pass it to SDK
        sdkSession.setCustomer(getCustomer(sessionParameters));    //** Required **

        // Set Total Amount. The Total amount will be recalculated according to provided Taxes and Shipping
        BigDecimal amount;
        try {
            amount = new BigDecimal(Double.parseDouble((String) Objects.requireNonNull(sessionParameters.get("amount"))));
        } catch (Exception e) {
            Log.d("GoSellSDKDelegate : ", "Invalid amount can't be parsed to double : " + (String) Objects.requireNonNull(sessionParameters.get("amount")));
            amount = BigDecimal.ZERO;
        }
        sdkSession.setAmount(amount);   //** Required **

//        // Set Payment Items array listfDouble
//        ArrayList<PaymentItem> paymentItems = (ArrayList<PaymentItem>) getPaymentItems(sessionParameters.get("paymentitems"));
//        for (PaymentItem p : paymentItems) {
//            System.out.println(">>> p :" + p.getQuantity());
//        }
        sdkSession.setPaymentItems(new ArrayList<>());// ** Optional ** you can pass empty array list

        // Set Taxes array list
        sdkSession.setTaxes(new ArrayList<>());// ** Optional ** you can pass empty array list

        // Set Shipping array list
        sdkSession.setShipping(new ArrayList<>());// ** Optional ** you can pass empty array list

        // Post URL
        sdkSession.setPostURL(""); // ** Optional **

        // Payment Description
        sdkSession.setPaymentDescription(""); //** Optional **

        // Payment Extra Info
        sdkSession.setPaymentMetadata(new HashMap<>());// ** Optional ** you can pass empty array hash map

        // Payment Reference
        sdkSession.setPaymentReference(null); // ** Optional ** you can pass null

        // Payment Statement Descriptor
        sdkSession.setPaymentStatementDescriptor(""); // ** Optional **

        // Enable or Disable Saving Card
        sdkSession.isUserAllowedToSaveCard(true); //  ** Required ** you can pass boolean

        // Enable or Disable 3DSecure
        sdkSession.isRequires3DSecure(true);

        //Set Receipt Settings [SMS - Email ]
        sdkSession.setReceiptSettings(new Receipt(false, false)); // ** Optional ** you can pass Receipt object or null

        // Set Authorize Action
        sdkSession.setAuthorizeAction(null); // ** Optional ** you can pass AuthorizeAction object or null

        sdkSession.setDestination(null); // ** Optional ** you can pass Destinations object or null

        sdkSession.setMerchantID(null); // ** Optional ** you can pass merchant id or null


        sdkSession.setCardType(CardType.CREDIT); // ** Optional ** you can pass [CREDIT/DEBIT] id

    }

    private List<PaymentItem> getPaymentItems(Object paymentitems) {
//        if (paymentitems == null) return null;
//        Gson gson = new Gson();
//        PaymentItemsList nameList = gson.fromJson(paymentitems.toString(), PaymentItemsList.class);
//
//        List<PaymentItem> list = nameList.getList();
//        return list;


        Gson gson = new Gson();


        Type type = new TypeToken<ArrayList<PaymentItem>>(){}.getType();

        ArrayList<PaymentItem> array = gson.fromJson(paymentitems.toString(), type);
        return array;

    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private TransactionMode getTransactionMode(Object trxMode) {
        if (trxMode == null) return TransactionMode.PURCHASE;
        System.out.println("trxMode >>>> " + trxMode);
        switch (trxMode.toString()) {
            case "TransactionMode.PURCHASE":
                return TransactionMode.PURCHASE;
            case "TransactionMode.AUTHORIZE_CAPTURE":
                return TransactionMode.AUTHORIZE_CAPTURE;
            case "TransactionMode.SAVE_CARD":
                return TransactionMode.SAVE_CARD;
            case "TransactionMode.TOKENIZE_CARD":
                return TransactionMode.TOKENIZE_CARD;
        }
        return TransactionMode.PURCHASE;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private Customer getCustomer(HashMap<String, Object> sessionParameters) {
        System.out.println("customer object >>>>> " + sessionParameters.get("customer"));
        if (sessionParameters.get("customer") == null || "null".equalsIgnoreCase(sessionParameters.get("customer").toString()))
            return null;
        String customerString = (String) sessionParameters.get("customer");
        JSONObject jsonObject;
        try {
            jsonObject = new JSONObject(customerString);
            PhoneNumber phoneNumber = new PhoneNumber(jsonObject.get("isdNumber").toString(), jsonObject.get("number").toString());
            return new Customer.CustomerBuilder(jsonObject.get("customerId").toString()).email(jsonObject.get("email").toString()).firstName(jsonObject.get("first_name").toString())
                    .lastName(jsonObject.get("last_name").toString()).phone(phoneNumber)
                    .middleName(jsonObject.get("middle_name").toString()).build();
        } catch (JSONException e) {
            e.printStackTrace();
        }

        return null;

    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    private void sendChargeResult(Charge charge, String paymentStatus, String trx_mode) {
        Map<String, Object> resultMap = new HashMap<>();
        if (charge.getStatus() != null)
            resultMap.put("status", charge.getStatus().name());
        resultMap.put("charge_id", charge.getId());
        resultMap.put("description", charge.getDescription());
        resultMap.put("message", charge.getResponse().getMessage());
        if (charge.getCard() != null) {
            resultMap.put("card_first_six", charge.getCard().getFirstSix());
            resultMap.put("card_last_four", charge.getCard().getLast4());
            resultMap.put("card_object", charge.getCard().getObject());
            resultMap.put("card_brand", charge.getCard().getBrand());
            resultMap.put("card_exp_month", charge.getCard().getExp_month());
            resultMap.put("card_exp_year", charge.getCard().getExp_year());
        }
        if (charge.getAcquirer() != null) {
            resultMap.put("acquirer_id", charge.getAcquirer().getId());
            resultMap.put("acquirer_response_code", charge.getAcquirer().getResponse().getCode());
            resultMap.put("acquirer_response_message", charge.getAcquirer().getResponse().getMessage());
        }
        if (charge.getSource() != null) {
            resultMap.put("source_id", charge.getSource().getId());
            if (charge.getSource().getChannel() != null)
                resultMap.put("source_channel", charge.getSource().getChannel().name());
            resultMap.put("source_object", charge.getSource().getObject());
            resultMap.put("source_payment_type", charge.getSource().getPaymentType());
        }
        resultMap.put("sdk_result", paymentStatus);
        resultMap.put("trx_mode", trx_mode);
        pendingResult.success(resultMap);
        pendingResult = null;
    }


    private void sendTokenResult(Token token, String paymentStatus) {
        Map<String, Object> resultMap = new HashMap<>();

        resultMap.put("token", token.getId());
        resultMap.put("token_currency", token.getCurrency());
        if (token.getCard() != null) {
            resultMap.put("card_first_six", token.getCard().getFirstSix());
            resultMap.put("card_last_four", token.getCard().getLastFour());
            resultMap.put("card_object", token.getCard().getObject());
            resultMap.put("card_exp_month", token.getCard().getExpirationYear());
            resultMap.put("card_exp_year", token.getCard().getExpirationMonth());
        }
        resultMap.put("sdk_result", paymentStatus);
        resultMap.put("trx_mode", "TOKENIZE");
        pendingResult.success(resultMap);
        pendingResult = null;
    }


    private void sendSDKError(int errorCode, String errorMessage, String errorBody) {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("sdk_result", "SDK_ERROR");
        resultMap.put("sdk_error_code", errorCode);
        resultMap.put("sdk_error_message", errorMessage);
        resultMap.put("sdk_error_description", errorBody);
        pendingResult.success(resultMap);
        pendingResult = null;
    }


    @Override
    public void paymentSucceed(@NonNull Charge charge) {
        sendChargeResult(charge, "SUCCESS", "CHARGE");
    }

    @Override
    public void paymentFailed(@Nullable Charge charge) {
        System.out.println("Payment Failed : " + charge.getStatus());
        System.out.println("Payment Failed : " + charge.getDescription());
        System.out.println("Payment Failed : " + charge.getResponse().getMessage());
        sendChargeResult(charge, "FAILED", "CHARGE");
    }

    @Override
    public void authorizationSucceed(@NonNull Authorize authorize) {
        sendChargeResult(authorize, "SUCCESS", "AUTHORIZE");
    }

    @Override
    public void authorizationFailed(Authorize authorize) {
        System.out.println("Authorize Failed : " + authorize.getStatus());
        System.out.println("Authorize Failed : " + authorize.getDescription());
        System.out.println("Authorize Failed : " + authorize.getResponse().getMessage());
        sendChargeResult(authorize, "FAILED", "AUTHORIZE");
    }


    @Override
    public void cardSaved(@NonNull Charge charge) {
        // Cast charge object to SaveCard first to get all the Card info.
        if (charge instanceof SaveCard) {
            System.out.println("Card Saved Succeeded : first six digits : " + ((SaveCard) charge).getCard().getFirstSix() + "  last four :" + ((SaveCard) charge).getCard().getLast4());
        }
        System.out.println("Card Saved Succeeded : " + charge.getStatus());
        System.out.println("Card Saved Succeeded : " + charge.getCard().getBrand());
        System.out.println("Card Saved Succeeded : " + charge.getDescription());
        System.out.println("Card Saved Succeeded : " + charge.getResponse().getMessage());
        sendChargeResult(charge, "SUCCESS", "SAVE_CARD");
    }

    @Override
    public void cardSavingFailed(@NonNull Charge charge) {
        System.out.println("Card Saved Failed : " + charge.getStatus());
        System.out.println("Card Saved Failed : " + charge.getDescription());
        System.out.println("Card Saved Failed : " + charge.getResponse().getMessage());
        sendChargeResult(charge, "FAILED", "SaveCard");
    }

    @Override
    public void cardTokenizedSuccessfully(@NonNull Token token) {
        System.out.println("Card Tokenized Succeeded : ");
        System.out.println("Token card : " + token.getCard().getFirstSix() + " **** " + token.getCard().getLastFour());
        System.out.println("Token card : " + token.getCard().getFingerprint() + " **** " + token.getCard().getFunding());
        System.out.println("Token card : " + token.getCard().getId() + " ****** " + token.getCard().getName());
        System.out.println("Token card : " + token.getCard().getAddress() + " ****** " + token.getCard().getObject());
        System.out.println("Token card : " + token.getCard().getExpirationMonth() + " ****** " + token.getCard().getExpirationYear());

        sendTokenResult(token, "SUCCESS");
    }

    @Override
    public void savedCardsList(@NonNull CardsList cardsList) {
        if (cardsList != null && cardsList.getCards() != null) {
            System.out.println(" Card List Response Code : " + cardsList.getResponseCode());
            System.out.println(" Card List Top 10 : " + cardsList.getCards().size());
            System.out.println(" Card List Has More : " + cardsList.isHas_more());
            System.out.println("----------------------------------------------");
            for (SavedCard sc : cardsList.getCards()) {
                System.out.println(sc.getBrandName());
            }
            System.out.println("----------------------------------------------");

//            showSavedCardsDialog(cardsList);
        }
    }


    @Override
    public void sdkError(@Nullable GoSellError goSellError) {
        if (goSellError != null) {
            System.out.println("SDK Process Error : " + goSellError.getErrorBody());
            System.out.println("SDK Process Error : " + goSellError.getErrorMessage());
            System.out.println("SDK Process Error : " + goSellError.getErrorCode());
        }

        sendSDKError(goSellError.getErrorCode(), goSellError.getErrorMessage(), goSellError.getErrorBody());
    }


    @Override
    public void sessionIsStarting() {
        System.out.println(" Session Is Starting.....");
    }

    @Override
    public void sessionHasStarted() {
        System.out.println(" Session Has Started .......");
    }


    @Override
    public void sessionCancelled() {
        Log.d("MainActivity", "Session Cancelled.........");
    }

    @Override
    public void sessionFailedToStart() {
        Log.d("MainActivity", "Session Failed to start.........");
    }


    @Override
    public void invalidCardDetails() {
        System.out.println(" Card details are invalid....");
    }

    @Override
    public void backendUnknownError(String message) {
        System.out.println("Backend Un-Known error.... : " + message);
        sendSDKError(Constants.ERROR_CODE_BACKEND_UNKNOWN_ERROR, message, message);
    }

    @Override
    public void invalidTransactionMode() {
        System.out.println(" invalidTransactionMode  ......");
        sendSDKError(Constants.ERROR_CODE_INVALID_TRX_MODE, "invalidTransactionMode", "invalidTransactionMode");

    }

    @Override
    public void invalidCustomerID() {
        System.out.println("Invalid Customer ID .......");
        sendSDKError(Constants.ERROR_CODE_INVALID_CUSTOMER_ID, "Invalid Customer ID ", "Invalid Customer ID ");
    }

    @Override
    public void userEnabledSaveCardOption(boolean saveCardEnabled) {
        System.out.println("userEnabledSaveCardOption :  " + saveCardEnabled);
    }


/////////////////////////////////////////////////////////  needed only for demo ////////////////////

    class PaymentItemsList {
        List<PaymentItem> list;

        public List<PaymentItem> getList() {
            return list;
        }

        public void setList(List<PaymentItem> list) {
            this.list = list;
        }
    }
}
