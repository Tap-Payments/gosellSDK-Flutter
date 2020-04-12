package tap.company.go_sell_sdk_flutter;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;

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
import company.tap.gosellapi.open.models.CardsList;
import company.tap.gosellapi.open.models.Customer;
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


    public GoSellSdKDelegate(Activity _activity){
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



    public void startSDK(MethodCall methodCall, MethodChannel.Result result) {

        if (!setPendingMethodCallAndResult(methodCall, result)) {
            finishWithAlreadyActiveError(result);
            return;
        }
        showSDK();
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

    private void showSDK() {
        /**
         * Required step.
         * Configure SDK with your Secret API key and App Bundle name registered with tap company.
         */
        configureApp();

        /**
         * Optional step
         * Here you can configure your app theme (Look and Feel).
         */
        configureSDKThemeObject();


        /**
         * Required step.
         * Configure SDK Session with all required data.
         */
        configureSDKSession();

        /**
         * Required step.
         * Choose between different SDK modes
         */
        sdkSession.setTransactionMode(TransactionMode.PURCHASE);

        TransactionMode trx_mode = sdkSession.getTransactionMode();

        sdkSession.start(activity);
    }


    private void configureApp() {
        GoSellSDK.init(activity, "sk_test_kovrMB0mupFJXfNZWx6Etg5y", "company.tap.goSellSDKExample");  // to be replaced by merchant
        GoSellSDK.setLocale("en");  // to be replaced by merchant
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
     */
    private void configureSDKSession() {

        // Instantiate SDK Session
        if (sdkSession == null) sdkSession = new SDKSession();   //** Required **

        // pass your activity as a session delegate to listen to SDK internal payment process follow
        sdkSession.addSessionDelegate(this);    //** Required **

        // initiate PaymentDataSource
        sdkSession.instantiatePaymentDataSource();    //** Required **

        // set transaction currency associated to your account
        sdkSession.setTransactionCurrency(new TapCurrency("KWD"));    //** Required **

        // Using static CustomerBuilder method available inside TAP Customer Class you can populate TAP Customer object and pass it to SDK
        sdkSession.setCustomer(getCustomer());    //** Required **

        // Set Total Amount. The Total amount will be recalculated according to provided Taxes and Shipping
        sdkSession.setAmount(new BigDecimal(1));  //** Required **

        // Set Payment Items array list
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

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    private Customer getCustomer() { // test customer id cus_Kh1b4220191939i1KP2506448
        PhoneNumber phoneNumber =  new PhoneNumber("965","69045932");
        return new Customer.CustomerBuilder(null).email("abc@abc.com").firstName("firstname")
                .lastName("lastname").metadata("").phone(new PhoneNumber(phoneNumber.getCountryCode(),phoneNumber.getNumber()))
                .middleName("middlename").build();
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    @Override
    public void paymentSucceed(@NonNull Charge charge) {

        System.out.println("Payment Succeeded : charge status : "+ charge.getStatus());
        System.out.println("Payment Succeeded : description : "+ charge.getDescription());
        System.out.println("Payment Succeeded : message : "+ charge.getResponse().getMessage());
        System.out.println("##############################################################################");
        if(charge.getCard()!=null){
            System.out.println("Payment Succeeded : first six : "+ charge.getCard().getFirstSix());
            System.out.println("Payment Succeeded : last four: "+ charge.getCard().getLast4());
            System.out.println("Payment Succeeded : card object : "+ charge.getCard().getObject());
            System.out.println("Payment Succeeded : brand : "+ charge.getCard().getBrand());
        }

        System.out.println("##############################################################################");
        if(charge.getAcquirer()!=null){
            System.out.println("Payment Succeeded : acquirer id : "+ charge.getAcquirer().getId());
            System.out.println("Payment Succeeded : acquirer response code : "+ charge.getAcquirer().getResponse().getCode());
            System.out.println("Payment Succeeded : acquirer response message: "+ charge.getAcquirer().getResponse().getMessage());
        }
        System.out.println("##############################################################################");
        if(charge.getSource()!=null){
            System.out.println("Payment Succeeded : source id: "+ charge.getSource().getId());
            System.out.println("Payment Succeeded : source channel: "+ charge.getSource().getChannel());
            System.out.println("Payment Succeeded : source object: "+ charge.getSource().getObject());
            System.out.println("Payment Succeeded : source payment method: "+ charge.getSource().getPaymentMethodStringValue());
            System.out.println("Payment Succeeded : source payment type: "+ charge.getSource().getPaymentType());
            System.out.println("Payment Succeeded : source type: "+ charge.getSource().getType());
        }

        System.out.println("##############################################################################");
        if(charge.getExpiry()!=null){
            System.out.println("Payment Succeeded : expiry type :"+ charge.getExpiry().getType());
            System.out.println("Payment Succeeded : expiry period :"+ charge.getExpiry().getPeriod());
        }
        System.out.println(" before ..");

        pendingResult.success(charge);
        System.out.println(" after ..");
    }

    @Override
    public void paymentFailed(@Nullable Charge charge) {
        System.out.println("Payment Failed : "+ charge.getStatus());
        System.out.println("Payment Failed : "+ charge.getDescription());
        System.out.println("Payment Failed : "+ charge.getResponse().getMessage());
//        result.setText(charge.getStatus() + "  [ " + charge.getId()+ " ] " );


//        showDialog(charge.getId(),charge.getResponse().getMessage(),company.tap.gosellapi.R.drawable.icon_failed);
    }

    @Override
    public void authorizationSucceed(@NonNull Authorize authorize) {
        System.out.println("Authorize Succeeded : "+ authorize.getStatus());
        System.out.println("Authorize Succeeded : "+ authorize.getResponse().getMessage());

        if(authorize.getCard()!=null){
            System.out.println("Payment Authorized Succeeded : first six : "+ authorize.getCard().getFirstSix());
            System.out.println("Payment Authorized Succeeded : last four: "+ authorize.getCard().getLast4());
            System.out.println("Payment Authorized Succeeded : card object : "+ authorize.getCard().getObject());
        }

        System.out.println("##############################################################################");
        if(authorize.getAcquirer()!=null){
            System.out.println("Payment Authorized Succeeded : acquirer id : "+ authorize.getAcquirer().getId());
            System.out.println("Payment Authorized Succeeded : acquirer response code : "+ authorize.getAcquirer().getResponse().getCode());
            System.out.println("Payment Authorized Succeeded : acquirer response message: "+ authorize.getAcquirer().getResponse().getMessage());
        }
        System.out.println("##############################################################################");
        if(authorize.getSource()!=null){
            System.out.println("Payment Authorized Succeeded : source id: "+ authorize.getSource().getId());
            System.out.println("Payment Authorized Succeeded : source channel: "+ authorize.getSource().getChannel());
            System.out.println("Payment Authorized Succeeded : source object: "+ authorize.getSource().getObject());
            System.out.println("Payment Authorized Succeeded : source payment method: "+ authorize.getSource().getPaymentMethodStringValue());
            System.out.println("Payment Authorized Succeeded : source payment type: "+ authorize.getSource().getPaymentType());
            System.out.println("Payment Authorized Succeeded : source type: "+ authorize.getSource().getType());
        }

        System.out.println("##############################################################################");
        if(authorize.getExpiry()!=null){
            System.out.println("Payment Authorized Succeeded : expiry type :"+ authorize.getExpiry().getType());
            System.out.println("Payment Authorized Succeeded : expiry period :"+ authorize.getExpiry().getPeriod());
        }


//        saveCustomerRefInSession(authorize);
//        configureSDKSession();
//        showDialog(authorize.getId(),authorize.getResponse().getMessage(),company.tap.gosellapi.R.drawable.ic_checkmark_normal);
    }

    @Override
    public void authorizationFailed(Authorize authorize) {
        System.out.println("Authorize Failed : "+ authorize.getStatus());
        System.out.println("Authorize Failed : "+ authorize.getDescription());
        System.out.println("Authorize Failed : "+ authorize.getResponse().getMessage());
//        showDialog(authorize.getId(),authorize.getResponse().getMessage(),company.tap.gosellapi.R.drawable.icon_failed);
    }


    @Override
    public void cardSaved(@NonNull Charge charge) {
        // Cast charge object to SaveCard first to get all the Card info.
        if(charge instanceof SaveCard){
            System.out.println("Card Saved Succeeded : first six digits : "+ ((SaveCard)charge).getCard().getFirstSix() + "  last four :"+ ((SaveCard)charge).getCard().getLast4());
        }
        System.out.println("Card Saved Succeeded : "+ charge.getStatus());
        System.out.println("Card Saved Succeeded : "+ charge.getCard().getBrand());
        System.out.println("Card Saved Succeeded : "+ charge.getDescription());
        System.out.println("Card Saved Succeeded : "+ charge.getResponse(). getMessage());
//        saveCustomerRefInSession(charge);
//        showDialog(charge.getId(),charge.getStatus().toString(),company.tap.gosellapi.R.drawable.ic_checkmark_normal);
    }

    @Override
    public void cardSavingFailed(@NonNull Charge charge) {
        System.out.println("Card Saved Failed : "+ charge.getStatus());
        System.out.println("Card Saved Failed : "+ charge.getDescription());
        System.out.println("Card Saved Failed : "+ charge.getResponse().getMessage());
//        showDialog(charge.getId(),charge.getStatus().toString(),company.tap.gosellapi.R.drawable.icon_failed);
    }

    @Override
    public void cardTokenizedSuccessfully(@NonNull Token token) {
        System.out.println("Card Tokenized Succeeded : ");
        System.out.println("Token card : "+token.getCard().getFirstSix() + " **** "+ token.getCard().getLastFour() );
        System.out.println("Token card : "+token.getCard().getFingerprint() +  " **** "+ token.getCard().getFunding() );
        System.out.println("Token card : "+token.getCard().getId() +" ****** "+ token.getCard().getName());
        System.out.println("Token card : "+token.getCard().getAddress() +" ****** "+ token.getCard().getObject());
        System.out.println("Token card : "+token.getCard().getExpirationMonth() +" ****** "+ token.getCard().getExpirationYear());

//        showDialog(token. getId(),"Token",company.tap.gosellapi.R.drawable.ic_checkmark_normal);
    }

    @Override
    public void savedCardsList(@NonNull CardsList cardsList) {
        if(cardsList!=null && cardsList.getCards()!=null){
            System.out.println(" Card List Response Code : "+cardsList.getResponseCode());
            System.out.println(" Card List Top 10 : "+cardsList.getCards().size());
            System.out.println(" Card List Has More : "+cardsList.isHas_more());
            System.out.println("----------------------------------------------");
            for(SavedCard sc: cardsList.getCards()){
                System.out.println(sc.getBrandName());
            }
            System.out.println("----------------------------------------------");

//            showSavedCardsDialog(cardsList);
        }
    }


    @Override
    public void sdkError(@Nullable GoSellError goSellError) {
//        if(progress!=null)
//            progress.dismiss();
        if(goSellError!=null) {
            System.out.println("SDK Process Error : " + goSellError.getErrorBody());
            System.out.println("SDK Process Error : " + goSellError.getErrorMessage());
            System.out.println("SDK Process Error : " + goSellError.getErrorCode());
//            showDialog(goSellError.getErrorCode() + "", goSellError.getErrorMessage(), company.tap.gosellapi.R.drawable.icon_failed);
        }
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
        Log.d("MainActivity","Session Cancelled.........");
    }

    @Override
    public void sessionFailedToStart() {
        Log.d("MainActivity","Session Failed to start.........");
    }


    @Override
    public void invalidCardDetails() {
        System.out.println(" Card details are invalid....");
    }

    @Override
    public void backendUnknownError(String message) {
        System.out.println("Backend Un-Known error.... : "+ message);
    }

    @Override
    public void invalidTransactionMode() {
        System.out.println(" invalidTransactionMode  ......");
    }

    @Override
    public void invalidCustomerID() {
//        if(progress!=null)
//            progress.dismiss();
        System.out.println("Invalid Customer ID .......");

    }

    @Override
    public void userEnabledSaveCardOption(boolean saveCardEnabled) {
        System.out.println("userEnabledSaveCardOption :  "+saveCardEnabled);
    }


/////////////////////////////////////////////////////////  needed only for demo ////////////////////


}
