# go_sell_sdk_flutter

Flutter plugin compatible version of goSellSDK library for both Android and iOS that fully covers payment/authorization/card saving/card tokenization process inside your Android application.
Original SDKS

- Android (https://github.com/Tap-Payments/goSellSDK-Android)
- AndroidX (https://github.com/Tap-Payments/goSellSDK-AndroidX)
- iOS (https://github.com/Tap-Payments/goSellSDK-ios)

## Getting Started

# Table of Contents

---

1. [Requirements](#requirements)
2. [Installation](#installation)
   1. [Installation with pubspec.yaml](#installation_with_pubspec)
3. [Usage](#usage)
   1. [Configure Your App](#configure_your_app)
   2. [Configure SDK Session](#configure_sdk_session)
   3. [Use Tap Pay Button](#tap_pay_button)
   4. [Handle SDK Result](#handle_sdk_result)

<a href="requirements"></a>

# Requirements

---

To use the SDK the following requirements must be met:

1. **Visual Studio - InteliJ Idea**
2. **Dart 2.7.1** or newer
3. **Flutter: >=1.10.0** or newer
4. **iOS 11** or later
5. **XCode 12** or later

<a name="installation"></a>

# Installation

---

<a name="installation_with_pubspec"></a>

### Include goSellSDK plugin as a dependency in your pubspec.yaml

```dart
 dependencies:
     go_sell_sdk_flutter: ^2.0.3
```

---

<a name="configure_your_app"></a>

## Configure your app

`goSellSDK` should be set up. To set it up, add the following lines of code somewhere in your project and make sure they will be called before any usage of `goSellSDK`.

```dart
/**
 * Configure App. (You must get those keys from tap)
 */
GoSellSdkFlutter.configureApp(
  bundleId: "ANDROIID-PACKAGE-NAME",
  productionSecreteKey: Platform.isAndroid? "Android-Live-KEY" : "iOS-Live-KEY",
  sandBoxsecretKey: Platform.isAndroid?"Android-SANDBOX-KEY" : "iOS-SANDBOX-KEY",
  lang: "en");
```

---

<a name="configure_your_app"></a>
**Configure SDK Session Example**

```dart
Future<void> setupSDKSession() async {
    try {
    GoSellSdkFlutter.sessionConfigurations(
        trxMode: TransactionMode.TOKENIZE_CARD,
        transactionCurrency: "kwd",
        amount: '100',
        customer: Customer(
            customerId: "",
            email: "h@tap.company",
            isdNumber: "965",
            number: "000000",
            firstName: "Haitham",
            middleName: "Mohammad",
            lastName: "Elsheshtawy",
            metaData: null),
        paymentItems: <PaymentItem>[
            PaymentItem(
                name: "item1",
                amountPerUnit: 1,
                quantity: Quantity(value: 1),
                discount: {
                "type": "F",
                "value": 10,
                "maximum_fee": 10,
                "minimum_fee": 1
                },
                description: "Item 1 Apple",
                taxes: [
                Tax(
                    amount: Amount(
                        type: "F",
                        value: 10,
                        minimum_fee: 1,
                        maximum_fee: 10),
                    name: "tax1",
                    description: "tax describtion")
                ],
                totalAmount: 100),
        ],
        // List of taxes
        taxes: [
            Tax(
                amount: Amount(
                    type: "F", value: 10, minimum_fee: 1, maximum_fee: 10),
                name: "tax1",
                description: "tax describtion"),
            Tax(
                amount: Amount(
                    type: "F", value: 10, minimum_fee: 1, maximum_fee: 10),
                name: "tax1",
                description: "tax describtion")
        ],
        // List of shippnig
        shippings: [
            Shipping(
                name: "shipping 1",
                amount: 100,
                description: "shiping description 1"),
            Shipping(
                name: "shipping 2",
                amount: 150,
                description: "shiping description 2")
        ],
        // Post URL
        postURL: "https://tap.company",
        // Payment description
        paymentDescription: "paymentDescription",
        // Payment Metadata
        paymentMetaData: {
            "a": "a meta",
            "b": "b meta",
        },
        // Payment Reference
        paymentReference: Reference(
            acquirer: "acquirer",
            gateway: "gateway",
            payment: "payment",
            track: "track",
            transaction: "trans_910101",
            order: "order_262625"),
        // payment Descriptor
        paymentStatementDescriptor: "paymentStatementDescriptor",
        // Save Card Switch
        isUserAllowedToSaveCard: true,
        // Enable/Disable 3DSecure
        isRequires3DSecure: false,
        // Receipt SMS/Email
        receipt: Receipt(true, false),
        // Authorize Action [Capture - Void]
        authorizeAction: AuthorizeAction(
            type: AuthorizeActionType.CAPTURE, timeInHours: 10),
        // Destinations
        destinations:Destinations(
            amount: 100,
            currency: 'kwd',
            count: 2,
            destinationlist: [
                Destination(
                    id: "",
                    amount: 100,
                    currency: "kwd",
                    description: "des",
                    reference: "ref_121299"),
                Destination(
                    id: "",
                    amount: 100,
                    currency: "kwd",
                    description: "des",
                   reference: "ref_22444444")
            ])
        ,
        // merchant id
        merchantID: "",
        // Allowed cards
        allowedCadTypes: CardType.CREDIT,
        applePayMerchantID: "applePayMerchantID",
        allowsToSaveSameCardMoreThanOnce: false,
        // pass the card holder name to the SDK
        cardHolderName: "Card Holder NAME",
        // disable changing the card holder name by the user
        allowsToEditCardHolderName: false,
        paymentType: PaymentType.ALL,
        sdkMode: SDKMode.Sandbox);
    } on PlatformException {
    }
```

---

<a name="tap_pay_button"></a>
**Use Tap Pay Button**

```dart
Positioned(
    bottom: Platform.isIOS ? 0 : 10,
    left: 18,
    right: 18,
    child: SizedBox(
        height: 45,
        child: RaisedButton(
          color: _buttonColor,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.all(
                  Radius.circular(30))),
          onPressed: startSDK,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 25,
                  height: 25,
                  child: AwesomeLoader(
                    outerColor: Colors.white,
                    innerColor: Colors.white,
                    strokeWidth: 3.0,
                    controller: loaderController,
                  ),
                ),
                Spacer(),
                Text('PAY',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16.0)),
                Spacer(),
                Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                ),
              ]),
        )),
          ),
```

---

<a name="handle_sdk_result"></a>
**Handle SDK Result**

- Start SDK

```dart
   tapSDKResult = await GoSellSdkFlutter.startPaymentSDK;
```

- Hnadle SDK result

```dart
setState(() {
  switch (tapSDKResult['sdk_result']) {
    case "SUCCESS":
      sdkStatus = "SUCCESS";
      handleSDKResult();
      break;
    case "FAILED":
      sdkStatus = "FAILED";
      handleSDKResult();
      break;
    case "SDK_ERROR":
      sdkErrorCode                  = tapSDKResult['sdk_error_code'].toString();
      sdkErrorMessage               = tapSDKResult['sdk_error_message'];
      sdkErrorDescription           = tapSDKResult['sdk_error_description'];
      break;
    case "NOT_IMPLEMENTED":
      sdkStatus = "NOT_IMPLEMENTED";
      break;
  }
});
void handleSDKResult() {
  switch (tapSDKResult['trx_mode']) {
    case "CHARGE":
    case "AUTHORIZE":
    case "SAVE_CARD":
        extractSDKResultKeysAndValues();
        break;
    case "TOKENIZE":
        token :                          =tapSDKResult['token'];
        token_currency                   =tapSDKResult['token_currency'];
        card_first_six                   =tapSDKResult['card_first_six'];
        card_last_four                   =tapSDKResult['card_last_four'];
        card_object                      =tapSDKResult['card_object'];
        card_exp_month                   =tapSDKResult['card_exp_month'];
        card_exp_year                    =tapSDKResult['card_exp_year'];
        break;
  }
}
void extractSDKResultKeysAndValues() {
    id                             = tapSDKResult['charge_id'];
    description                    = tapSDKResult['description'];
    message                        = tapSDKResult['message'];
    card_first_six                 = tapSDKResult['card_first_six'];
    card_last_four                 = tapSDKResult['card_last_four'];
    card_object                    = tapSDKResult['card_object'];
    card_brand                     = tapSDKResult['card_brand'];
    card_exp_month                 = tapSDKResult['card_exp_month'];
    card_exp_year                  = tapSDKResult['card_exp_year'];
    acquirer_id                    = tapSDKResult['acquirer_id'];
    acquirer_response_code         = tapSDKResult['acquirer_response_code'];
    acquirer_response_message      = tapSDKResult['acquirer_response_message'];
    source_id                      = tapSDKResult['source_id'];
    source_channel                 = tapSDKResult['source_channel'];
    source_object                  = tapSDKResult['source_object'];
    source_payment_type            = tapSDKResult['source_payment_type'];
    responseID                     = tapSDKResult['charge_id'];
}
```

---
