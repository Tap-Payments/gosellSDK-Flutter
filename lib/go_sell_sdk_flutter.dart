import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_sell_sdk_flutter/model/models.dart';

class GoSellSdkFlutter {
  static const MethodChannel _channel =
      const MethodChannel('go_sell_sdk_flutter');



  static Future<dynamic> get startPaymentSDK async {
  
    dynamic result = Map<dynamic, dynamic> () ;
    if(TargetPlatform.iOS==TargetPlatform.iOS) 
    {
      result['sdk_result']='NOT_IMPLEMENTED';
        return result;
    }
    
  
    // prepare sdk configurations
    sdkConfigurations = {
      "appCredentials": appCredentials,
      "sessionParameters": sessionParameters
    };

   // forward call to channel
   
     result =
        await _channel.invokeMethod('start_sdk', sdkConfigurations);
    
    print('result in dart : $result');
    return result;
  }

  static Map<String, dynamic> sdkConfigurations;
  static Map<String, dynamic> appCredentials;
  static Map<String, dynamic> sessionParameters;

// App configurations
  static void configureApp({String secreteKey, String bundleId, String lang}) {
    appCredentials = <String, dynamic>{
      "secrete_key": secreteKey,
      "bundleID": bundleId,
      "language": lang
    };
  }

  // session configurations
  static void sessionConfigurations(
      {String transactionCurrency,
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
      CardType cardType}) {
    sessionParameters = <String, dynamic>{
      'transactionCurrency': "kwd",
      'customer': jsonEncode(customer),
      "paymentitems": jsonEncode(paymentItems),
      "taxes": jsonEncode(taxes),
      "shipping": jsonEncode(shippings),
      "postURL": postURL,
      "paymentDescription": paymentDescription,
      "paymenMetaData": jsonEncode(paymentMetaData),
      "paymentReference": jsonEncode(paymentReference),
      "paymentStatementDescriptor": paymentStatementDescriptor,
      "isUserAllowedToSaveCard": isUserAllowedToSaveCard,
      "isRequires3DSecure": isRequires3DSecure,
      "receiptSettings": jsonEncode(receipt),
      "authorizeAction": jsonEncode(authorizeAction),
      "destinations": jsonEncode(destinations),
      "merchantID": merchantID,
      "cardType": cardType.toString(),
    };
  }
}
