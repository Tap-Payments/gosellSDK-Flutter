import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_sell_sdk_flutter/go_sell_sdk_flutter.dart';
import 'package:go_sell_sdk_flutter/model/models.dart';
import 'package:go_sell_sdk_flutter_example/tap_loader/awesome_loader.dart';

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
  bool _showLoader;

  Color _buttonColor;
  double _bottom;

  @override
  void initState() {
    super.initState();
    _buttonColor = Color(0xff2ace00);
    _showLoader = false;
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
        productionSecreteKey: "sk_live_kovrMB0mupFJXfNZWx6Etg5y",
        sandBoxsecretKey: "sk_test_kovrMB0mupFJXfNZWx6Etg5y",
        lang: "en");
  }

  // Platform messages are asynchronous, so we initialize in an async method.
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
              number: "65562630",
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
          destinations: null
          //Destinations(
          //     amount: 100,
          //     currency: 'kwd',
          //     count: 2,
          //     destinationlist: [
          //       Destination(
          //           id: "",
          //           amount: 100,
          //           currency: "kwd",
          //           description: "des",
          //           reference: "ref_121299"),
          //       // Destination(
          //       //     id: "",
          //       //     amount: 100,
          //       //     currency: "kwd",
          //       //     description: "des",
          //       //     reference: "ref_22444444")
          //     ])
          ,
          // merchant id
          merchantID: "",
          // Allowed cards
          allowedCadTypes: CardType.CREDIT,
          applePayMerchantID: "applePayMerchantID",
          allowsToSaveSameCardMoreThanOnce: false,
          paymentType: PaymentType.ALL,
          sdkMode: SDKMode.Sandbox);
    } on PlatformException {
      // platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      tapSDKResult = {};
    });
  }

  Future<void> startSDK() async {
    setState(() {
      _showLoader = true;
    });

    tapSDKResult = await GoSellSdkFlutter.startPaymentSDK;
    _showLoader = false;
    print('>>>> ${tapSDKResult['sdk_result']}');
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
          print('sdk error............');
          print(tapSDKResult['sdk_error_code']);
          print(tapSDKResult['sdk_error_message']);
          print(tapSDKResult['sdk_error_description']);
          print('sdk error............');
          sdkErrorCode = tapSDKResult['sdk_error_code'].toString();
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
              backgroundColor: Colors.grey,
            ),
            body: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    top: 300,
                    left: 18,
                    right: 18,
                    child: Text("Status: [$sdkStatus $responseID ]",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Roboto",
                            fontStyle: FontStyle.normal,
                            fontSize: 15.0),
                        textAlign: TextAlign.center),
                  ),
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
                                  child: !_showLoader
                                      ? Container()
                                      : AwesomeLoader(
                                          outerColor: Colors.white,
                                          innerColor: Colors.white,
                                          // duration: 2,
                                          strokeWidth: 3.0,
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
                ],
              ),
            )));
  }
}
