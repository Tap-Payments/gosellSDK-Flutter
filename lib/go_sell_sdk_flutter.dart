import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_sell_sdk_flutter/enum/card_type.dart';
import 'package:go_sell_sdk_flutter/model/authorize_action.dart';
import 'package:go_sell_sdk_flutter/model/customer.dart';
import 'package:go_sell_sdk_flutter/model/destinations.dart';
import 'package:go_sell_sdk_flutter/model/payment_item.dart';
import 'package:go_sell_sdk_flutter/model/payment_reference.dart';
import 'package:go_sell_sdk_flutter/model/receipt.dart';
import 'package:go_sell_sdk_flutter/model/shipping.dart';
import 'package:go_sell_sdk_flutter/model/tax.dart';

class GoSellSdkFlutter {
  static const MethodChannel _channel =
      const MethodChannel('go_sell_sdk_flutter');

  // static Future<String> get platformVersion async {
  //   // final String version = await _channel.invokeMethod('getPlatformVersion');
  //   final String version = await _channel.invokeMethod('start_sdk');
  //   return version;
  // }

   static Future<dynamic> get startPaymentSDK async{

     final String result = await _channel.invokeMethod('start_sdk', sessionParameters);
     return result;

   }

  static Map<String, dynamic> sessionParameters;

  static void sessionConfigurations(
      String transactionCurrency,
      Customer customer,
      List<PaymentItem> paymentItems,
      List<Tax> taxes,
      List<Shipping> shippings,
      String postURL,
      String paymentDescription,
      Map<String, String> paymentMetaData,
      Reference paymentReference,
      String paymentStatementDescriptor,
      bool isUserAllowedToSaveCard,
      bool isRequires3DSecure,
      Receipt receipt,
      AuthorizeAction authorizeAction,
      Destinations destinations,
      String merchantID,
      CardType cardType) {

    sessionParameters = <String, dynamic>{
      'transactionCurrency': "",
      'customer': {
        "ISDNumber": customer.isdNumber,
        "number": customer.number,
        "customerId": customer.customerId,
        "email": customer.email,
        "firstName": customer.firstName,
        "firstName": customer.firstName,
        "lastName": customer.lastName,
        "metaData": customer.metaData,
      },
      "paymentitems": paymentItems,
      "taxes": taxes,
      "shipping": shippings,
      "postURL": postURL,
      "paymentDescription": paymentDescription,
      "paymenMetaData": paymentMetaData,
      "paymentReference": paymentReference,
      "paymentStatementDescriptor": paymentStatementDescriptor,
      "isUserAllowedToSaveCard": isUserAllowedToSaveCard,
      "isRequires3DSecure": isRequires3DSecure,
      "receiptSettings": receipt,
      "authorizeAction": authorizeAction,
      "destinations": destinations,
      //   "amount": destinations.amount,
      //   "currency": destinations.currency,
      //   "count": destinations.count,
      //   "destination": destinations.destinations
      // },
      "merchantID": merchantID,
      "cardType": cardType,
    };
  }
}
