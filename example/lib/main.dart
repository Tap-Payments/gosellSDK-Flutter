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
  String msg = "";

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
    // print("sdkresult: $sdkResult");
    setState(() {
      if (tapSDKResult.containsKey("sdk_result") &&
          tapSDKResult['sdk_result'] == "SUCCESS") {
        if (tapSDKResult.containsKey("sdk_result")) {
          print('result in example main class: ${tapSDKResult['charge_id']}');
          chargeId = tapSDKResult['charge_id'];
          msg = "Charge : ";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
       child: Text('$msg . $chargeId')
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            startSDK();
          },
          child:Text('Pay') ,
        ),
      ),
    );
  }
}
