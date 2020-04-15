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
  String chargeId = "";
  String sdkStatus = "";

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
      if (tapSDKResult.containsKey("trx_mode")) {
        switch (tapSDKResult['trx_mode']) {
          case "CHARGE":
            print('Charge status                         : ${tapSDKResult['status']}');
            print('Charge id                             : ${tapSDKResult['charge_id']}');
            print('Charge  description                   : ${tapSDKResult['description']}');
            print('Charge  message                       : ${tapSDKResult['message']}');
            print('Charge  card_first_six                : ${tapSDKResult['card_first_six']}');
            print('Charge  card_last_four                : ${tapSDKResult['card_last_four']}');
            print('Charge  card_object                   : ${tapSDKResult['card_object']}');
            print('Charge  card_brand                    : ${tapSDKResult['card_brand']}');
            print('Charge  card_exp_month                : ${tapSDKResult['card_exp_month']}');
            print('Charge  card_exp_year                 : ${tapSDKResult['card_exp_year']}');
            print('Charge  acquirer_id                   : ${tapSDKResult['acquirer_id']}');
            print('Charge  acquirer_response_code        : ${tapSDKResult['acquirer_response_code']}');
            print('Charge  acquirer_response_message     : ${tapSDKResult['acquirer_response_message']}');
            print('Charge  source_id                     : ${tapSDKResult['source_id']}');
            print('Charge  source_channel                : ${tapSDKResult['source_channel']}');
            print('Charge  source_object                 : ${tapSDKResult['source_object']}');
            print('Charge  source_payment_type           : ${tapSDKResult['source_payment_type']}');

            chargeId = tapSDKResult['charge_id'];
            break;

          case "AUTHORIZE":
            print('AUTHORIZE status                         : ${tapSDKResult['status']}');
            print('AUTHORIZE id                             : ${tapSDKResult['charge_id']}');
            print('AUTHORIZE  description                   : ${tapSDKResult['description']}');
            print('AUTHORIZE  message                       : ${tapSDKResult['message']}');
            print('AUTHORIZE  card_first_six                : ${tapSDKResult['card_first_six']}');
            print('AUTHORIZE  card_last_four                : ${tapSDKResult['card_last_four']}');
            print('AUTHORIZE  card_object                   : ${tapSDKResult['card_object']}');
            print('AUTHORIZE  card_brand                    : ${tapSDKResult['card_brand']}');
            print('AUTHORIZE  card_exp_month                : ${tapSDKResult['card_exp_month']}');
            print('AUTHORIZE  card_exp_year                 : ${tapSDKResult['card_exp_year']}');
            print('AUTHORIZE  acquirer_id                   : ${tapSDKResult['acquirer_id']}');
            print('AUTHORIZE  acquirer_response_code        : ${tapSDKResult['acquirer_response_code']}');
            print('AUTHORIZE  acquirer_response_message     : ${tapSDKResult['acquirer_response_message']}');
            print('AUTHORIZE  source_id                     : ${tapSDKResult['source_id']}');
            print('AUTHORIZE  source_channel                : ${tapSDKResult['source_channel']}');
            print('AUTHORIZE  source_object                 : ${tapSDKResult['source_object']}');
            print('AUTHORIZE  source_payment_type           : ${tapSDKResult['source_payment_type']}');
            break;

          case "SAVE_CARD":
            print('SAVE_CARD status                         : ${tapSDKResult['status']}');
            print('SAVE_CARD id                             : ${tapSDKResult['charge_id']}');
            print('SAVE_CARD  description                   : ${tapSDKResult['description']}');
            print('SAVE_CARD  message                       : ${tapSDKResult['message']}');
            print('SAVE_CARD  card_first_six                : ${tapSDKResult['card_first_six']}');
            print('SAVE_CARD  card_last_four                : ${tapSDKResult['card_last_four']}');
            print('SAVE_CARD  card_object                   : ${tapSDKResult['card_object']}');
            print('SAVE_CARD  card_brand                    : ${tapSDKResult['card_brand']}');
            print('SAVE_CARD  card_exp_month                : ${tapSDKResult['card_exp_month']}');
            print('SAVE_CARD  card_exp_year                 : ${tapSDKResult['card_exp_year']}');
            print('SAVE_CARD  acquirer_id                   : ${tapSDKResult['acquirer_id']}');
            print('SAVE_CARD  acquirer_response_code        : ${tapSDKResult['acquirer_response_code']}');
            print('SAVE_CARD  acquirer_response_message     : ${tapSDKResult['acquirer_response_message']}');
            print('SAVE_CARD  source_id                     : ${tapSDKResult['source_id']}');
            print('SAVE_CARD  source_channel                : ${tapSDKResult['source_channel']}');
            print('SAVE_CARD  source_object                 : ${tapSDKResult['source_object']}');
            print('SAVE_CARD  source_payment_type           : ${tapSDKResult['source_payment_type']}');
            break;

          case "TOKENIZE":
            print('TOKENIZE token                           : ${tapSDKResult['token']}');
            print('TOKENIZE token_currency                  : ${tapSDKResult['token_currency']}');
            print('TOKENIZE card_first_six                  : ${tapSDKResult['card_first_six']}');
            print('TOKENIZE card_last_four                  : ${tapSDKResult['card_last_four']}');
            print('TOKENIZE card_object                     : ${tapSDKResult['card_object']}');
            print('TOKENIZE card_exp_month                  : ${tapSDKResult['card_exp_month']}');
            print('TOKENIZE card_exp_year                   : ${tapSDKResult['card_exp_year']}');
            break;
        }
        handleSDKResult();
      }
    });
  }

  handleSDKResult() {
    if (tapSDKResult.containsKey("sdk_result")) {
      switch (tapSDKResult['sdk_result']) {
        case "SUCCESS":
          sdkStatus = "SUCCESS";
          break;
        case "FAILED":
          sdkStatus = "FAILED";
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(child: Text('$sdkStatus  $chargeId ')),
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
