import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:go_sell_sdk_flutter/model/models.dart';
import 'package:go_sell_sdk_flutter/utils/util.dart';

class GoSellSdkFlutter {
  static const String ERROR_CODE_INVALID_SESSION_CONFIGURATION = "500";
  static const String ERROR_CODE_INVALID_APP_CONFIGURATION = "501";
  static Map<dynamic, dynamic> _tapSDKResult = Map<dynamic, dynamic>();

  static const MethodChannel _channel =
      const MethodChannel('go_sell_sdk_flutter');

  static Future<dynamic> get startPaymentSDK async {
    if (!_validateSessionArge() || _validateAppConfig()) return _tapSDKResult;

    /// prepare sdk configurations
    sdkConfigurations = {
      "appCredentials": appCredentials,
      "sessionParameters": sessionParameters
    };

    // /forward call to channel
    dynamic result =
        await _channel.invokeMethod('start_sdk', sdkConfigurations);
    print('result in dart : $result');
    return result;
  }

  static Future<Null> terminateSession() async {
    _channel.invokeMethod('terminate_session');
  }

  static late Map<String, dynamic> sdkConfigurations;
  static late Map<String, dynamic> appCredentials;
  static late Map<String, dynamic> sessionParameters;

  /// App configurations
  static void configureApp({
    required String productionSecreteKey,
    required String sandBoxsecretKey,
    required String bundleId,
    required String lang,
  }) {
    appCredentials = <String, dynamic>{
      "production_secrete_key": productionSecreteKey,
      "sandbox_secrete_key": sandBoxsecretKey,
      "bundleID": bundleId,
      "language": lang
    };
  }

  /// session configurations
  static void sessionConfigurations({
    required TransactionMode trxMode,
    required String transactionCurrency,
    required String amount,
    required Customer customer,
    required List<PaymentItem> paymentItems,
    List<Tax>? taxes,
    List<Shipping>? shippings,
    required String postURL,
    required String paymentDescription,
    required Map<String, String> paymentMetaData,
    required Reference paymentReference,
    required String paymentStatementDescriptor,
    required bool isUserAllowedToSaveCard,
    required bool isRequires3DSecure,
    required Receipt receipt,
    required AuthorizeAction authorizeAction,
    Destinations? destinations,
    required String merchantID,
    CardType? allowedCadTypes,
    required String applePayMerchantID,
    required SDKMode sdkMode,
    required PaymentType paymentType,
    required bool allowsToSaveSameCardMoreThanOnce,
    String? cardHolderName,
    bool? allowsToEditCardHolderName,
  }) {
    sessionParameters = <String, dynamic>{
      'trxMode': trxMode.toString(),
      'transactionCurrency': transactionCurrency,
      'amount': amount,
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
      "allowedCadTypes": allowedCadTypes.toString(),
      "applePayMerchantID": applePayMerchantID,
      "SDKMode": sdkMode.toString(),
      "paymentType": paymentType.toString(),
      "allowsToSaveSameCardMoreThanOnce": allowsToSaveSameCardMoreThanOnce,
      "cardHolderName": cardHolderName,
      "editCardHolderName": allowsToEditCardHolderName,
    };
  }

  /// validate app configurations
  static bool _validateAppConfig() {
    if (appCredentials["bundleId"] == "" ||
        appCredentials["bundleId"] == "null" ||
        appCredentials["bundleId"] == null) {
      _prepareConfigurationsErrorMap(
          errorCode: ERROR_CODE_INVALID_APP_CONFIGURATION,
          errorMsg: 'Invalid Bundle ID',
          errorDescription: 'Bundle ID can not be empty or null');
      return false;
    }

    if (appCredentials["production_secrete_key"] == "" ||
        appCredentials["production_secrete_key"] == "null" ||
        appCredentials["production_secrete_key"] == null) {
      _prepareConfigurationsErrorMap(
          errorCode: ERROR_CODE_INVALID_APP_CONFIGURATION,
          errorMsg: 'Invalid secrete Key',
          errorDescription: 'Production Secrete key can not empty or null');
      return false;
    }

    if (appCredentials["sandbox_secrete_key"] == "" ||
        appCredentials["sandbox_secrete_key"] == "null" ||
        appCredentials["sandbox_secrete_key"] == null) {
      _prepareConfigurationsErrorMap(
          errorCode: ERROR_CODE_INVALID_APP_CONFIGURATION,
          errorMsg: 'Invalid secrete Key',
          errorDescription: 'Sandbox Secrete key can not empty or null');
      return false;
    }

    if (appCredentials["lang"] == "" ||
        appCredentials["lang"] == "null" ||
        appCredentials["lang"] == null) {
      _prepareConfigurationsErrorMap(
          errorCode: ERROR_CODE_INVALID_SESSION_CONFIGURATION,
          errorMsg: 'Invalid language',
          errorDescription: 'Language can not empty or null');
      return false;
    }
    return true;
  }

  static bool _validateSessionArge() {
    // validate trx mode
    if (sessionParameters["trxMode"] == "" ||
        sessionParameters["trxMode"] == "null" ||
        sessionParameters["trxMode"] == null) {
      _prepareConfigurationsErrorMap(
          errorCode: ERROR_CODE_INVALID_SESSION_CONFIGURATION,
          errorMsg: 'Invalid Transaction Mode',
          errorDescription: 'Transaction Mode can not empty or null');
      return false;
    }

    // validate transaction currency
    if (sessionParameters["transactionCurrency"] == "" ||
        sessionParameters["transactionCurrency"] == "null" ||
        sessionParameters["transactionCurrency"].length == 0) {
      _prepareConfigurationsErrorMap(
          errorCode: ERROR_CODE_INVALID_SESSION_CONFIGURATION,
          errorMsg: 'Invalid Transaction Currency',
          errorDescription: 'Transaction Currency can not be empty or null');
      return false;
    }

    // validate customer
    if (sessionParameters["customer"] == "null" ||
        sessionParameters["customer"] == null) {
      _prepareConfigurationsErrorMap(
          errorCode: ERROR_CODE_INVALID_SESSION_CONFIGURATION,
          errorMsg: 'Invalid Customer',
          errorDescription: 'Customer can not be empty or null');
      return false;
    }

    // validate amount
    if (sessionParameters["amount"] == "null" ||
        !Util.isNumeric(sessionParameters["amount"]) ||
        sessionParameters["amount"] == "") {
      _prepareConfigurationsErrorMap(
          errorCode: ERROR_CODE_INVALID_SESSION_CONFIGURATION,
          errorMsg: 'Invalid Amount',
          errorDescription:
              'Amount can not be empty or null or zero and must be numeric value');
      return false;
    }

    // validate 3dsecure
    _validateBooleanValues("isRequires3DSecure");
    // validate saveCard
    _validateBooleanValues("isUserAllowedToSaveCard");
    // validate save multiple
    _validateBooleanValues("allowsToSaveSameCardMoreThanOnce");

    return true;
  }

  static void _validateBooleanValues(String param) {
    if (sessionParameters[param] == "null" ||
        sessionParameters[param] == null ||
        sessionParameters[param] == "") {
      sessionParameters[param] = false;
    }
  }

  static void _prepareConfigurationsErrorMap(
      {required String errorCode,
      required String errorMsg,
      String? errorDescription}) {
    _tapSDKResult.putIfAbsent('sdk_result', () => 'SDK_ERROR');
    _tapSDKResult.putIfAbsent('sdk_error_code', () => errorCode);
    _tapSDKResult.putIfAbsent('sdk_error_message', () => errorMsg);
    _tapSDKResult.putIfAbsent('sdk_error_description', () => errorDescription);
  }
}

enum TransactionMode { PURCHASE, AUTHORIZE_CAPTURE, SAVE_CARD, TOKENIZE_CARD }
enum SDKMode { Sandbox, Production }
enum PaymentType { ALL, CARD, WEB, APPLE_PAY, DEVICE }
