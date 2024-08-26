package tap.company.go_sell_sdk_flutter;

import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

import company.tap.gosellapi.GoSellSDK;
import company.tap.gosellapi.internal.api.callbacks.GoSellError;
import company.tap.gosellapi.internal.api.models.Authorize;
import company.tap.gosellapi.internal.api.models.Charge;
import company.tap.gosellapi.internal.api.models.Contract;
import company.tap.gosellapi.internal.api.models.PaymentAgreement;
import company.tap.gosellapi.internal.api.models.SaveCard;
import company.tap.gosellapi.internal.api.models.Token;
import company.tap.gosellapi.open.controllers.SDKSession;
import company.tap.gosellapi.open.controllers.ThemeObject;
import company.tap.gosellapi.open.delegate.SessionDelegate;
import company.tap.gosellapi.open.enums.AppearanceMode;
import company.tap.gosellapi.open.exception.CurrencyException;
import company.tap.gosellapi.open.models.CardsList;
import company.tap.gosellapi.open.models.TapCurrency;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import tap.company.go_sell_sdk_flutter.deserializers.DeserializationUtil;

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

    public void startSDK(MethodCall methodCall, MethodChannel.Result result,
                         HashMap<String, Object> sdkConfigurations) {

        if (!setPendingMethodCallAndResult(methodCall, result)) {
            finishWithAlreadyActiveError(result);
            return;
        }
        // start SDK
        showSDK(sdkConfigurations, result);
    }

    public void terminateSDKSession() {
        if (activity != null) {
            sdkSession.cancelSession(activity);
        }
    }

    private void finishWithAlreadyActiveError(MethodChannel.Result result) {
        result.error("already_active", "SDK is already active", null);
    }

    private boolean setPendingMethodCallAndResult(MethodCall methodCall, MethodChannel.Result result) {
        if (pendingResult != null) {
            return false;
        }

        this.methodCall = methodCall;
        pendingResult = result;

        return true;
    }

    private void showSDK(HashMap<String, Object> sdkConfigurations, MethodChannel.Result result) {
        HashMap<String, Object> sessionParameters = (HashMap<String, Object>) sdkConfigurations
                .get("sessionParameters");
        /**
         * Required step. Configure SDK with your Secret API key and App Bundle name
         * registered with tap company.
         */
        HashMap<String, String> appConfigurations = (HashMap<String, String>) sdkConfigurations.get("appCredentials");
        String sandboxKey = appConfigurations.get("sandbox_secrete_key");
        String productionKey = appConfigurations.get("production_secrete_key");
        String activeKey = sandboxKey;
        if ("SDKMode.Production".equalsIgnoreCase(sessionParameters.get("SDKMode").toString()))
            activeKey = productionKey;
        // System.out.println("activeKey : " + activeKey);
        configureApp(activeKey, appConfigurations.get("bundleID"), appConfigurations.get("language"));

        // configureSDKThemeObject();

        /**
         * Required step. Configure SDK Session with all required data.
         */
        configureSDKSession(sessionParameters, result);
        sdkSession.start(activity);
    }


    private void configureApp(String secrete_key, String bundleID, String language) {
        GoSellSDK.init(activity, secrete_key, bundleID); // to be replaced by merchant
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            GoSellSDK.setLocale(language); // to be replaced by merchant
        }
    }

    /**
     * Configure SDK Session
     *
     * @param sessionParameters
     * @param result
     */
    private void configureSDKSession(HashMap<String, Object> sessionParameters, MethodChannel.Result result) {

        // Instantiate SDK Session
        if (sdkSession == null)
            sdkSession = new SDKSession(); // ** Required **

        // pass your activity as a session delegate to listen to SDK internal payment
        // process follow
        sdkSession.addSessionDelegate(this); // ** Required **

        // initiate PaymentDataSource
        sdkSession.instantiatePaymentDataSource(); // ** Required **

        sdkSession.setGooglePayWalletMode(DeserializationUtil.getGPayWalletMode(sessionParameters.get("googlePayWalletMode").toString()));//** Required ** For setting GooglePAY Environment

        // sdk mode
        sdkSession.setTransactionMode(
                DeserializationUtil.getTransactionMode(sessionParameters.get("trxMode").toString()));

        // set transaction currency associated to your account
        TapCurrency transactionCurrency;
        try {
            transactionCurrency = new TapCurrency(
                    (String) Objects.requireNonNull(sessionParameters.get("transactionCurrency")));
        } catch (CurrencyException c) {
            Log.d("GoSellSDKDelegate : ", "Unknown currency exception thrown : "
                    + (String) Objects.requireNonNull(sessionParameters.get("transactionCurrency")));
            transactionCurrency = new TapCurrency("KWD");
        } catch (Exception e) {
            Log.d("GoSellSDKDelegate : ", "Unknown currency: "
                    + (String) Objects.requireNonNull(sessionParameters.get("transactionCurrency")));
            transactionCurrency = new TapCurrency("KWD");
        }

        sdkSession.setTransactionCurrency(transactionCurrency); // ** Required **

        if (sessionParameters.get("appearanceMode") != null) {
            ThemeObject.getInstance()
                    .setAppearanceMode(DeserializationUtil.getAppearanceMode(sessionParameters.get("appearanceMode").toString()));
        } else {
            if (sessionParameters.get("trxMode").toString().equals("TransactionMode.SAVE_CARD") ||
                    sessionParameters.get("trxMode").toString().equals("TransactionMode.TOKENIZE_CARD")) {
                ThemeObject.getInstance()
                        .setAppearanceMode(AppearanceMode.WINDOWED_MODE);
            } else {
                ThemeObject.getInstance()
                        .setAppearanceMode(AppearanceMode.FULLSCREEN_MODE);
            }
        }


        // Using static CustomerBuilder method available inside TAP Customer Class you
        // can populate TAP Customer object and pass it to SDK
        sdkSession.setCustomer(DeserializationUtil.getCustomer(sessionParameters)); // ** Required **

        // Set Total Amount. The Total amount will be recalculated according to provided
        // Taxes and Shipping
        BigDecimal amount;
        try {
            amount = new BigDecimal(
                    Double.parseDouble((String) Objects.requireNonNull(sessionParameters.get("amount"))));
        } catch (Exception e) {
            Log.d("GoSellSDKDelegate : ", "Invalid amount can't be parsed to double : "
                    + (String) Objects.requireNonNull(sessionParameters.get("amount")));
            amount = BigDecimal.ZERO;
        }
        sdkSession.setAmount(amount); // ** Required **

        sdkSession.setPaymentItems(DeserializationUtil.getPaymentItems(sessionParameters.get("paymentitems")));// **
        // Optional
        // ** you
        // can
        // pass
        // empty
        // array
        // list

        // Set Taxes array list
        sdkSession.setTaxes(DeserializationUtil.getTaxes(sessionParameters.get("taxes")));// ** Optional ** you can pass
        // empty array list

        // Set Shipping array list
        sdkSession.setShipping(DeserializationUtil.getShipping(sessionParameters.get("shipping")));// ** Optional ** you
        // can pass empty
        // array list

        // Post URL
        sdkSession.setPostURL(sessionParameters.get("postURL").toString());// ** Optional **

        /// Supported payment methods
        sdkSession.setSupportedPaymentMethods((ArrayList<String>) sessionParameters.get("supportedPaymentMethods"));

        // Payment Description
        sdkSession.setPaymentDescription(sessionParameters.get("paymentDescription").toString()); // ** Optional **

        // Payment Extra Info
        sdkSession.setPaymentMetadata(DeserializationUtil.getMetaData(sessionParameters.get("paymentMetaData")));// **
        // Optional
        // **
        // you
        // can
        // pass
        // empty
        // array
        // hash
        // map

        // Payment Reference
        sdkSession.setPaymentReference(DeserializationUtil.getReference(sessionParameters.get("paymentReference"))); // **
        // Optional
        // **
        // you
        // can
        // pass
        // null

        // Payment Statement Descriptor
        sdkSession.setPaymentStatementDescriptor(sessionParameters.get("paymentStatementDescriptor").toString()); // **
        // Optional
        // **

        // Enable or Disable Saving Card
        sdkSession.isUserAllowedToSaveCard((boolean) sessionParameters.get("isUserAllowedToSaveCard")); // ** Required
        // ** you can
        // pass boolean

        // Enable or Disable 3DSecure
        sdkSession.isRequires3DSecure((boolean) sessionParameters.get("isRequires3DSecure"));

        // Set Receipt Settings [SMS - Email ]
        sdkSession.setReceiptSettings(DeserializationUtil.getReceipt(sessionParameters.get("receiptSettings"))); // **
        // Optional
        // **
        // you
        // can
        // pass
        // Receipt
        // object
        // or
        // null

        // Set Authorize Action
        sdkSession.setAuthorizeAction(DeserializationUtil.getAuthorizeAction(sessionParameters.get("authorizeAction"))); // **
        // Optional
        // **
        // you
        // can
        // pass
        // AuthorizeAction
        // object
        // or
        // null

        sdkSession.setDestination(DeserializationUtil.getDestinations(sessionParameters.get("destinations"))); // **
        // Optional
        // ** you
        // can
        // pass
        // Destinations
        // object
        // or
        // null

        sdkSession.setMerchantID(sessionParameters.get("merchantID").toString()); // ** Optional ** you can pass
        // merchant id or null

        sdkSession.setCardType(DeserializationUtil.getCardType(sessionParameters.get("allowedCadTypes").toString())); // **
        // Optional
        // **
        // you
        // can
        // pass
        // [CREDIT/DEBIT]
        // id

        sdkSession.setPaymentType(DeserializationUtil.getPaymentType(sessionParameters.get("paymentType").toString()));

        sdkSession.setDefaultCardHolderName(sessionParameters.get("cardHolderName").toString()); // ** Optional ** you
        // can pass default
        // CardHolderName of
        // the
        // user .So you don't need to type it.
        sdkSession.isUserAllowedToEnableCardHolderName((boolean) sessionParameters.get("editCardHolderName")); // **
        // Optional
        // **
        // you
        // can enable/ disable
        // default
        // CardHolderName .

    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    private void sendChargeResult(Charge charge, String paymentStatus, String trx_mode) {
        System.out.println("TRX_MODE :> " + trx_mode);
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
            resultMap.put("card_id", charge.getCard().getId());
            resultMap.put("card_brand", charge.getCard().getBrand());
            if (charge.getCard().getExpiry() != null) {
                resultMap.put("card_exp_month", charge.getCard().getExpiry().getMonth());
                resultMap.put("card_exp_year", charge.getCard().getExpiry().getYear());
            } else {
                resultMap.put("card_exp_month", charge.getCard().getExp_month());
                resultMap.put("card_exp_year", charge.getCard().getExp_year());
            }
        }

        if (trx_mode.equals("SAVE_CARD")) {
            if (((SaveCard) charge).getPaymentAgreement() != null) {

                PaymentAgreement paymentAgreement = ((SaveCard) charge).getPaymentAgreement();
                HashMap<String, Object> paymentAgreementMap = new HashMap<>();

                paymentAgreementMap.put("id", paymentAgreement.getId());
                paymentAgreementMap.put("type", paymentAgreement.getType());
                paymentAgreementMap.put("total_payments_count", paymentAgreement.getTotalPaymentCount());
                paymentAgreementMap.put("trace_id", paymentAgreement.getTraceId());
                if (paymentAgreement.getContract() != null) {
                    Contract contract = paymentAgreement.getContract();
                    HashMap<String, Object> contractMap = new HashMap<>();
                    contractMap.put("id", contract.getId());
                    contractMap.put("customer_id", contract.getCustomerId());
                    contractMap.put("type", contract.getType());
                    paymentAgreementMap.put("contract", contractMap);
                }
                resultMap.put("payment_agreement", paymentAgreementMap);
            }


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

        if (charge.getCustomer() != null) {
            resultMap.put("customer_id", charge.getCustomer().getIdentifier());
            resultMap.put("customer_first_name", charge.getCustomer().getFirstName());
            resultMap.put("customer_middle_name", charge.getCustomer().getMiddleName());
            resultMap.put("customer_last_name", charge.getCustomer().getLastName());
            resultMap.put("customer_email", charge.getCustomer().getEmail());
        }
        resultMap.put("sdk_result", paymentStatus);
        resultMap.put("trx_mode", trx_mode);

        pendingResult.success(resultMap);
        pendingResult = null;
    }

    private void sendTokenResult(Token token, String paymentStatus, boolean saveCard) {
        Map<String, Object> resultMap = new HashMap<>();

        resultMap.put("token", token.getId());
        System.out.println("Token id: " + token.getId());
        resultMap.put("token_currency", token.getCurrency());
        if (token.getCard() != null) {
            if (token.getCard().getIssuer() != null) {
                System.out.println("Issuer: " + token.getCard().getIssuer());
                System.out.println("Issuer ID: " + token.getCard().getIssuer().getId());
                System.out.println("Issuer Bank:" + token.getCard().getIssuer().getBank());
                System.out.println("Issuer Country: " + token.getCard().getIssuer().getCountry());

                resultMap.put("issuer_id", token.getCard().getIssuer().getId());
                resultMap.put("issuer_bank", token.getCard().getIssuer().getBank());
                resultMap.put("issuer_country", token.getCard().getIssuer().getCountry());

            }
            resultMap.put("card_first_six", token.getCard().getFirstSix());
            resultMap.put("card_last_four", token.getCard().getLastFour());
            resultMap.put("card_object", token.getCard().getObject());
            resultMap.put("card_exp_month", token.getCard().getExpirationYear());
            resultMap.put("card_exp_year", token.getCard().getExpirationMonth());
            resultMap.put("card_holder_name", token.getCard().getName());
            resultMap.put("save_card", saveCard);


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

    private void sendGooglePayError(String errorMessage) {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("sdk_result", "SDK_ERROR");
        resultMap.put("sdk_error_message", errorMessage);
        pendingResult.success(resultMap);
        pendingResult = null;
    }

    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @Override
    public void paymentSucceed(@NonNull Charge charge) {
        sendChargeResult(charge, "SUCCESS", "CHARGE");
    }

    @Override
    public void paymentFailed(@Nullable Charge charge) {
        sendChargeResult(charge, "FAILED", "CHARGE");
    }

    @Override
    public void authorizationSucceed(@NonNull Authorize authorize) {
        sendChargeResult(authorize, "SUCCESS", "AUTHORIZE");
    }

    @Override
    public void authorizationFailed(Authorize authorize) {
        sendChargeResult(authorize, "FAILED", "AUTHORIZE");
    }

    @Override
    public void cardSaved(@NonNull Charge charge) {
        sendChargeResult(charge, "SUCCESS", "SAVE_CARD");
    }

    @Override
    public void cardSavingFailed(@NonNull Charge charge) {
        sendChargeResult(charge, "FAILED", "SAVE_CARD");
    }

    @Override
    public void cardTokenizedSuccessfully(@NonNull Token token) {
        sendTokenResult(token, "SUCCESS", false);
    }

    @Override
    public void cardTokenizedSuccessfully(@NonNull Token token, boolean saveCardEnabled) {
        sendTokenResult(token, "SUCCESS", saveCardEnabled);
    }

    @Override
    public void asyncPaymentStarted(@NonNull Charge charge) {

    }

    @Override
    public void savedCardsList(@NonNull CardsList cardsList) {
    }

    @Override
    public void sdkError(@Nullable GoSellError goSellError) {
        if (goSellError != null) {
            System.out.println("SDK Process Error : " + goSellError.getErrorBody());
            System.out.println("SDK Process Error : " + goSellError.getErrorMessage());
            System.out.println("SDK Process Error : " + goSellError.getErrorCode());
            sendSDKError(goSellError.getErrorCode(), goSellError.getErrorMessage(), goSellError.getErrorBody());
        }else{
            System.out.println("SESSION CANCELLED HERE ");
        }
    }

    @Override
    public void paymentInitiated(@Nullable Charge charge) {
        System.out.println("paymentInitiated CallBack :  ");
        if (charge != null) {
            System.out.println("Charge id:" + charge.getId());
            System.out.println("charge status:" + charge.getStatus());
        }
    }

    @Override
    public void googlePayFailed(String error) {
        sendGooglePayError(error);
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
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("sdk_result", "CANCELLED");
        pendingResult.success(resultMap);
        pendingResult = null;
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
}
