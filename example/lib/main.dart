import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_sell_sdk_flutter/go_sell_sdk_flutter.dart';
import 'package:go_sell_sdk_flutter/model/models.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<dynamic, dynamic> tapSDKResult;
  String responseID = "";
  String sdkStatus = "";
  String sdkErrorCode;
  String sdkErrorMessage;
  String sdkErrorDescription;

  @override
  void initState() {
    super.initState();
    configureSDK();
  }

  // configure SDK
  Future<void> configureSDK() async {
    // configure app
    configureApp();
    // sdk session configurations
    setupSDKSession();
  }

  // configure app key and bundle-id
  Future<void> configureApp() async {
    GoSellSdkFlutter.configureApp(
        bundleId: "company.tap.goSellSDKExample",
        secreteKey: "sk_test_kovrMB0mupFJXfNZWx6Etg5y",
        lang: "en");
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> setupSDKSession() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      GoSellSdkFlutter.sessionConfigurations(
          // transaction currency
          transactionCurrency: "kwd",
          // customer information
          customer: Customer(
              customerId: "",
              email: "h@tap.company",
              isdNumber: "965",
              number: "65562630",
              firstName: "Haitham",
              middleName: "Mohammad",
              lastName: "Elsheshtawy",
              metaData: null),
          // List of payment items
          paymentItems: <PaymentItem>[
            PaymentItem(
                name: "item1",
                amountPerUnit: 1,
                quantity: Quantity(
                    measurementGroup: "mass",
                    measurementUnit: "kilograms",
                    value: 1),
                discount: AmountModificator(type: "F", value: 10),
                description: "Item 1 Apple",
                taxes: [
                  Tax(
                      amount: AmountModificator(type: "F", value: 10),
                      description: "discount",
                      name: "tax1")
                ],
                totalAmount: 100),
          ],
          // List of taxes
          taxes: [
            Tax(
                amount: AmountModificator(type: "F", value: 10),
                description: "discount",
                name: "tax1"),
            Tax(
                amount: AmountModificator(type: "F", value: 10),
                description: "discount",
                name: "tax2")
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
            "c": "c meta",
            "d": "d meta",
            "e": "e meta",
            "f": "f meta",
            "g": "g meta",
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
              type: AuthorizeActionType.CAPTURE, timeInHours: 1000),
          // Destinations
          destinations: Destinations(
              amount: 200,
              currency: 'kwd',
              count: 2,
              destinations: [
                Destination(
                    id: "dest_1212",
                    amount: 10,
                    currency: "kwd",
                    description: "des",
                    reference: "ref_121299"),
                Destination(
                    id: "dest_22222",
                    amount: 20,
                    currency: "kwd",
                    description: "des",
                    reference: "ref_22444444")
              ]),
          // merchant id
          merchantID: "merchantID",
          // Allowed cards
          cardType: CardType.CREDIT);
    } on PlatformException {
      // platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      tapSDKResult = {};
    });
  }

  Future<void> startSDK() async {
    tapSDKResult = await GoSellSdkFlutter.startPaymentSDK;
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
          sdkErrorCode = tapSDKResult['sdk_error_code'];
          sdkErrorMessage = tapSDKResult['sdk_error_message'];
          sdkErrorDescription = tapSDKResult['sdk_error_description'];
          break;

         case "NOT_IMPLEMENTED":
             sdkStatus = "NOT_IMPLEMENTED";
         break; 
      }
    });
  }

  void handleSDKResult() {
    switch (tapSDKResult['trx_mode']) {
      case "CHARGE":
        printSDKResult('Charge');
        break;

      case "AUTHORIZE":
        printSDKResult('Authorize');
        break;

      case "SAVE_CARD":
        printSDKResult('Save Card');
        break;

      case "TOKENIZE":
        print('TOKENIZE token : ${tapSDKResult['token']}');
        print('TOKENIZE token_currency  : ${tapSDKResult['token_currency']}');
        print('TOKENIZE card_first_six : ${tapSDKResult['card_first_six']}');
        print('TOKENIZE card_last_four : ${tapSDKResult['card_last_four']}');
        print('TOKENIZE card_object  : ${tapSDKResult['card_object']}');
        print('TOKENIZE card_exp_month : ${tapSDKResult['card_exp_month']}');
        print('TOKENIZE card_exp_year    : ${tapSDKResult['card_exp_year']}');

        responseID = tapSDKResult['token'];
        break;
    }
  }

  void printSDKResult(String trx_mode) {
    print('$trx_mode status                : ${tapSDKResult['status']}');
    print('$trx_mode id               : ${tapSDKResult['charge_id']}');
    print('$trx_mode  description        : ${tapSDKResult['description']}');
    print('$trx_mode  message           : ${tapSDKResult['message']}');
    print('$trx_mode  card_first_six : ${tapSDKResult['card_first_six']}');
    print('$trx_mode  card_last_four   : ${tapSDKResult['card_last_four']}');
    print('$trx_mode  card_object         : ${tapSDKResult['card_object']}');
    print('$trx_mode  card_brand          : ${tapSDKResult['card_brand']}');
    print('$trx_mode  card_exp_month  : ${tapSDKResult['card_exp_month']}');
    print('$trx_mode  card_exp_year: ${tapSDKResult['card_exp_year']}');
    print('$trx_mode  acquirer_id  : ${tapSDKResult['acquirer_id']}');
    print(
        '$trx_mode  acquirer_response_code : ${tapSDKResult['acquirer_response_code']}');
    print(
        '$trx_mode  acquirer_response_message: ${tapSDKResult['acquirer_response_message']}');
    print('$trx_mode  source_id: ${tapSDKResult['source_id']}');
    print('$trx_mode  source_channel     : ${tapSDKResult['source_channel']}');
    print('$trx_mode  source_object      : ${tapSDKResult['source_object']}');
    print(
        '$trx_mode source_payment_type : ${tapSDKResult['source_payment_type']}');
    responseID = tapSDKResult['charge_id'];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(child: Text('$sdkStatus  $responseID ')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            startSDK();
          },
          child: Text('Pay'),
        ),
      ),
    );
  }
}
