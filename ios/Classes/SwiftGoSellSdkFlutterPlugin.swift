import Flutter
import UIKit
import goSellSDK
import TapCardValidator

public class SwiftGoSellSdkFlutterPlugin: NSObject, FlutterPlugin {
    let session = Session()
    public var argsSessionParameters:[String:Any]?
    public var argsAppCredentials:[String:String]?
    var flutterResult: FlutterResult?
    var argsDataSource:[String:Any]?{
      didSet{
        argsSessionParameters = argsDataSource?["sessionParameters"] as? [String : Any]
        argsAppCredentials = argsDataSource?["appCredentials"] as? [String : String]
      }
    }
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "go_sell_sdk_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftGoSellSdkFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    // print("sssssssssss....")//
    // call.arguments
    // NSNumber *maxWidth = [_arguments objectForKey:@"appCredentials"];
    // var appCredentials = [String : String]()
    // var secrete_key = call.arguments.flatMap { $0.AnyObject as [String : String]}.flatMap { $0 }
    // print("Flatmap: \(flatCars)")
    
    print("method is: \(call.method)")
    if call.method == "terminate_session" {
        print("terminate function!!")
        terminateSession()
        return
    }
    
    let dict = call.arguments as? [String: Any]
    argsDataSource = dict
    GoSellSDK.reset()
    let secretKey = SecretKey(sandbox: sandBoxSecretKey, production: productionSecretKey)
    GoSellSDK.secretKey = secretKey
    GoSellSDK.mode = sdkMode
    GoSellSDK.language = sdkLang
    session.delegate = self
    session.dataSource = self
    session.appearance = self
    session.start()
    flutterResult = result
//    result(["key": "iOS  + sssssssssss "])
    
  }
    
    func terminateSession() {
        session.stop()
        print("inside terminate session swift")
    }
}

extension SwiftGoSellSdkFlutterPlugin: SessionDataSource {

    public var customer: Customer?{
      if let customerString:String = argsSessionParameters?["customer"] as? String {
        if let data = customerString.data(using: .utf8) {
          do {
            let customerDictionary:[String:Any] = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
            if let customerIdentifier = customerDictionary["customerId"] as? String, !customerIdentifier.isEmpty,
                customerIdentifier.lowercased() != "null",customerIdentifier.lowercased() != "nil" {
              return try Customer.init(identifier: customerIdentifier)
            } else {
                if let customerDictionary = customerDictionary as? [String: String] {
                    
                    var email: EmailAddress?
                    var phoneNumber: PhoneNumber?
                    
                    if let emailString = customerDictionary["email"], !emailString.isEmpty {
                        email = try EmailAddress(emailAddressString: emailString)
                    }
                    
                    if let isdNumberString = customerDictionary["isdNumber"], let phoneString = customerDictionary["number"], !isdNumberString.isEmpty, !phoneString.isEmpty {
                        phoneNumber = try PhoneNumber(isdNumber: isdNumberString, phoneNumber: phoneString)
                    }
                    
                    return try Customer.init(emailAddress: email, phoneNumber: phoneNumber, firstName: customerDictionary["first_name"] ?? "", middleName: customerDictionary["middle_name"] ?? "", lastName: customerDictionary["last_name"] ?? "")
                } else {
                    throw NSError()
                }
            }
          } catch {
            print(error.localizedDescription)
          }
        }
      }
      return nil
    }

    public var cardHolderName: String?{
       if let cardHolderNameValue:String = argsSessionParameters?["cardHolderName"] as? String {
        return cardHolderNameValue
      }
      return ""
    }

  public var cardHolderNameIsEditable: Bool{
       if let cardHolderNameIsEditableValue:Bool = argsSessionParameters?["editCardHolderName"] as? Bool {
        return cardHolderNameIsEditableValue
      }
      return true
    }


    
    public var currency: Currency? {
      if let currencyString:String = argsSessionParameters?["transactionCurrency"] as? String {
        return .with(isoCode: currencyString)
      }
      return .with(isoCode: "KWD")
    }

    
    public var merchantID: String?
    {
      guard let merchantIDString:String = argsSessionParameters?["merchantID"] as? String else {
          return ""
      }
      return merchantIDString
    }
    public var sandBoxSecretKey: String{
      if let sandBoxSecretKeyString:String = argsAppCredentials?["sandbox_secrete_key"] {
        return sandBoxSecretKeyString
      }
      return ""
    }
    public var sdkLang: String{
      if let sdkLangString:String = argsAppCredentials?["language"] {
        return sdkLangString
      }
      return "en"
    }
    public var productionSecretKey: String{
      if let productionSecretKeyString:String = argsAppCredentials?["production_secrete_key"] {
        return productionSecretKeyString
      }
      return ""
    }
    public var isSaveCardSwitchOnByDefault: Bool{
      if let isUserAllowedToSaveCard:Bool = argsSessionParameters?["isUserAllowedToSaveCard"] as? Bool {
        return isUserAllowedToSaveCard
      }
      return false
    }
    public var items: [PaymentItem]? {
      if let paymentItemsString:String = argsSessionParameters?["paymentitems"] as? String {
        if let data = paymentItemsString.data(using: .utf8) {
          do {
            var paymentItemsArray:[[String:Any]] = try JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]] ?? []
            for (index, var item) in paymentItemsArray.enumerated() {
              guard var quantityDict:[String:Any] = item["quantity"] as? [String:Any] else {
                return nil
              }
              quantityDict["measurement_group"] = "mass"
              quantityDict["measurement_unit"] = "kilograms"
              item["quantity"] = quantityDict
              paymentItemsArray[index] = item
            }
            let decoder = JSONDecoder()
            let paymentItemsData = try JSONSerialization.data(withJSONObject: paymentItemsArray, options: [.fragmentsAllowed])
            let paymentItems:[PaymentItem] = try decoder.decode([PaymentItem].self, from: paymentItemsData)
            return paymentItems
          } catch {
            print(error.localizedDescription)
          }
        }
      }
      return nil
    }
    public var amount: Decimal {
      if let amountString:String = argsSessionParameters?["amount"] as? String,
        let amountDecimal: Decimal = Decimal(string:amountString) {
        return amountDecimal
      }
      return 0
    }
    public var mode: TransactionMode{
      if let modeString:String = argsSessionParameters?["trxMode"] as? String {
        let modeComponents: [String] = modeString.components(separatedBy: ".")
        if modeComponents.count == 2 {
          do {
            let data = try JSONEncoder().encode(modeComponents[1])
            let decoder = JSONDecoder()
            let transactionMode:TransactionMode = try decoder.decode(TransactionMode.self, from: data)
            return transactionMode
          } catch {
            print(error.localizedDescription)
          }
        }
      }
      return TransactionMode.purchase
    }
    public var applePayMerchantID: String
    {
      if let applePayMerchantIDString:String = argsSessionParameters?["applePayMerchantID"] as? String {
        return applePayMerchantIDString
      }
      return ""
    }
    public var sdkMode: SDKMode {
      if let sdkModeString:String = argsSessionParameters?["SDKMode"] as? String {
        let modeComponents: [String] = sdkModeString.components(separatedBy: ".")
        if modeComponents.count == 2 {
          return (modeComponents[1].lowercased() == "sandbox") ? .sandbox : .production
        }
      }
      return .sandbox
    }
    public var postURL: URL? {
      if let postUrlString:String = argsSessionParameters?["postURL"] as? String,
        let postURL:URL = URL(string: postUrlString) {
        return postURL
      }
      return nil
    }
    public var require3DSecure: Bool {
      if let require3DS:Bool = argsSessionParameters?["isRequires3DSecure"] as? Bool {
        return require3DS
      }
      return false
    }
    public var paymentDescription: String? {
      if let paymentDescriptionString:String = argsSessionParameters?["paymentDescription"] as? String {
        return paymentDescriptionString
      }
      return nil
    }
    public var taxes: [Tax]? {
      if let taxesString:String = argsSessionParameters?["taxes"] as? String {
        if let data = taxesString.data(using: .utf8) {
          do {
            let decoder = JSONDecoder()
            let taxesItems:[Tax] = try decoder.decode([Tax].self, from: data)
            return taxesItems
          } catch {
            print(error.localizedDescription)
          }
        }
      }
      return nil
    }
    public var paymentReference: Reference? {
      if let paymentReferenceString:String = argsSessionParameters?["paymentReference"] as? String {
        if let data = paymentReferenceString.data(using: .utf8) {
          do {
            let decoder = JSONDecoder()
            let paymentReferenceObject:Reference = try decoder.decode(Reference.self, from: data)
            return paymentReferenceObject
          } catch {
            print(error.localizedDescription)
          }
        }
      }
      return nil
    }
    public var receiptSettings: Receipt? {
      if let receiptSettingsString:String = argsSessionParameters?["receiptSettings"] as? String {
        if let data = receiptSettingsString.data(using: .utf8) {
          do {
            let decoder = JSONDecoder()
            let receiptSettingsObject:Receipt = try decoder.decode(Receipt.self, from: data)
            return receiptSettingsObject
          } catch {
            print(error.localizedDescription)
          }
        }
      }
      return Receipt(email: false, sms: false)
    }
    public var authorizeAction: AuthorizeAction {
      if let authorizeActionString:String = argsSessionParameters?["authorizeAction"] as? String {
        if let data = authorizeActionString.data(using: .utf8) {
          do {
            let decoder = JSONDecoder()
            let authorizeActionObject:AuthorizeAction = try decoder.decode(AuthorizeAction.self, from: data)
            return authorizeActionObject
          } catch {
            print(error.localizedDescription)
          }
        }
      }
        return .void(after: 0)
    }
    public var destinations: [Destination]? {
      if let destinationsGroupString:String = argsSessionParameters?["destinations"] as? String {
        if let data = destinationsGroupString.data(using: .utf8) {
          do {
            if let destinationsGroupJson:[String:Any] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String : Any],
              let destinationsJson:[[String:Any]] = destinationsGroupJson["destination"] as? [[String:Any]] {
              let destinationData = try JSONSerialization.data(withJSONObject: destinationsJson, options: [.fragmentsAllowed])
              let decoder = JSONDecoder()
              let destinationsItems:[Destination] = try decoder.decode([Destination].self, from: destinationData)
              return destinationsItems
            }
          } catch {
            print("error: \(error.localizedDescription)")
          }
        }
      }
      return nil
    }
    public var shipping: [Shipping]? {
      if let shippingString:String = argsSessionParameters?["shipping"] as? String {
        if let data = shippingString.data(using: .utf8) {
          do {
            let decoder = JSONDecoder()
            let shippingItems:[Shipping] = try decoder.decode([Shipping].self, from: data)
            return shippingItems
          } catch {
            print(error.localizedDescription)
          }
        }
      }
      return nil
    }
    
    public var paymentType: PaymentType {
      if let paymentTypeString:String = argsSessionParameters?["paymentType"] as? String {
        let paymentTypeComponents: [String] = paymentTypeString.components(separatedBy: ".")
        if paymentTypeComponents.count == 2 {
        do {
            let data = try JSONEncoder().encode(paymentTypeComponents[1])
            let decoder = JSONDecoder()
            let paymentTypeMode:PaymentType = try decoder.decode(PaymentType.self, from: data)
            return paymentTypeMode
          } catch {
            print(error.localizedDescription)
          }
        }
      }
      return PaymentType.all
    }
    
    public var allowedCadTypes: [CardType]? {
      if let cardTypeString:String = argsSessionParameters?["allowedCadTypes"] as? String {
        let cardTypeComponents: [String] = cardTypeString.components(separatedBy: ".")
        if cardTypeComponents.count == 2 {
          var cardType:cardTypes = .All
          cardTypes.allCases.forEach{
            if $0.description.lowercased() == cardTypeComponents[1].lowercased() {
              cardType = $0
            }
          }
          if cardType == .All {
            return [CardType(cardType: .Debit), CardType(cardType: .Credit)]
          }else
          {
            return [CardType(cardType: cardType)]
          }
        }
      }
      return [CardType(cardType: .Debit), CardType(cardType: .Credit)]
    }
}

extension SwiftGoSellSdkFlutterPlugin: SessionDelegate {
    public func paymentSucceed(_ charge: Charge, on session: SessionProtocol) {
      print(charge)
        
        var resultMap = [String: Any]()
        resultMap["status"] = charge.status.textValue
        resultMap["charge_id"] = charge.identifier
        resultMap["description"] = charge.description
        resultMap["message"] = charge.response?.message
        
        if let card = charge.card {
            resultMap["card_first_six"] = card.firstSixDigits
            resultMap["card_last_four"] = card.lastFourDigits
            resultMap["card_object"] = card.object
//            let cardBrand = CardBrand(rawValue: card.brand.rawValue)
            resultMap["card_brand"] = card.brand.textValue
            resultMap["card_exp_month"] = card.expirationMonth
            resultMap["card_exp_year"] = card.expirationYear
        }
        
        if let acquirer = charge.acquirer {
            if let response = acquirer.response {
                resultMap["acquirer_id"] = ""
                resultMap["acquirer_response_code"] = response.code
                resultMap["acquirer_response_message"] = response.message
            }
            
        }
        
        resultMap["source_id"] = charge.source.identifier
        resultMap["source_channel"] = charge.source.channel.textValue
        resultMap["source_object"] = charge.source.object.textValue
        resultMap["source_payment_type"] = charge.source.paymentType.textValue
        
        resultMap["sdk_result"] = "SUCCESS"
        resultMap["trx_mode"] = "CHARGE"
        
        //pendingResult.success(resultMap);
        if let flutterResult = flutterResult {
            flutterResult(resultMap)
        }
    }
    
    public func paymentFailed(with charge: Charge?, error: TapSDKError?, on session: SessionProtocol) {
                
        var resultMap = [String: Any]()
        if let charge = charge {
            resultMap["status"] = charge.status.textValue
            resultMap["charge_id"] = charge.identifier
            resultMap["description"] = charge.description
            resultMap["message"] = charge.response?.message
            
            if let card = charge.card {
                resultMap["card_first_six"] = card.firstSixDigits
                resultMap["card_last_four"] = card.lastFourDigits
                resultMap["card_object"] = card.object
                resultMap["card_brand"] = card.brand.textValue
                resultMap["card_exp_month"] = card.expirationMonth
                resultMap["card_exp_year"] = card.expirationYear
            }
            
            if let acquirer = charge.acquirer {
                if let response = acquirer.response {
                    resultMap["acquirer_id"] = ""
                    resultMap["acquirer_response_code"] = response.code
                    resultMap["acquirer_response_message"] = response.message
                }
                
            }
            
            resultMap["source_id"] = charge.source.identifier
            resultMap["source_channel"] = charge.source.channel.textValue
            resultMap["source_object"] = charge.source.object.textValue
            resultMap["source_payment_type"] = charge.source.paymentType.textValue
        }
                
        resultMap["sdk_result"] = "FAILED"
        resultMap["trx_mode"] = "CHARGE"
         
        if let flutterResult = flutterResult {
            flutterResult(resultMap)
        }
    }
      public func sessionCancelled(_ session: SessionProtocol) {
        var resultMap:[String:Any] = [:]
        resultMap["sdk_result"] = "CANCELLED"
        if let flutterResult = flutterResult {
            flutterResult(resultMap)
        }
    }
    
    
    public func cardTokenized(_ token: Token, on session: SessionProtocol, customerRequestedToSaveTheCard saveCard: Bool) {
       var resultMap:[String:Any] = [:]
          resultMap["token"] = token.identifier
          if let tokenDataSource = session.dataSource,
            let tokenCurrency:Currency = tokenDataSource.currency as? Currency {
            resultMap["token_currency"] = tokenCurrency.isoCode
          }
          resultMap["card_first_six"] = token.card.binNumber
          resultMap["card_last_four"] = token.card.lastFourDigits
          resultMap["card_object"] = token.card.object
          resultMap["card_exp_month"] = token.card.expirationMonth
          resultMap["card_exp_year"] = token.card.expirationYear
          resultMap["sdk_result"] = "SUCCESS"
          resultMap["trx_mode"] = "TOKENIZE"
//          result.success(resultMap)
        if let flutterResult = flutterResult {
            flutterResult(resultMap)
        }
        
    }
    public func cardTokenizationFailed(with error: TapSDKError, on session: SessionProtocol) {
      var resultMap:[String:Any] = [:]
      resultMap["sdk_result"] = "SDK_ERROR"
      resultMap["sdk_error_code"] = ""//error.type
      resultMap["sdk_error_message"] = error.description
      resultMap["sdk_error_description"] = error.description
//      result.success(resultMap)
        if let flutterResult = flutterResult {
            flutterResult(resultMap)
        }
    }
}

extension SwiftGoSellSdkFlutterPlugin: SessionAppearance {
    public func sessionShouldShowStatusPopup(_ session: SessionProtocol) -> Bool {
    return false
  }
}


extension ChargeStatus {
    var textValue: String {
        switch self {
        case .initiated:    return "INITIATED"
        case .inProgress:   return "IN_PROGRESS"
        case .abandoned:    return "ABANDONED"
        case .cancelled:    return "CANCELLED"
        case .failed:       return "FAILED"
        case .declined:     return "DECLINED"
        case .restricted:   return "RESTRICTED"
        case .captured:     return "CAPTURED"
        case .authorized:   return "AUTHORIZED"
        case .unknown:        return "UNKNOWN"
        case .void:         return "VOID"
        }
    }
}

extension SourceChannel {
    var textValue: String {
        switch self {
        case .callCentre:       return "CALL_CENTRE"
        case .internet:         return "INTERNET"
        case .mailOrder:        return "MAIL_ORDER"
        case .moto:             return "MOTO"
        case .telephoneOrder:   return "TELEPHONE_ORDER"
        case .voiceResponse:    return "VOICE_RESPONSE"
        case .null:             return "null"
        }
    }
}

extension SourceObject {
    var textValue: String {
        switch self {
            
        case .token:    return "TOKEN"
        case .source:   return "SOURCE"
            
        }
    }
}

extension SourcePaymentType {
    fileprivate struct RawValues {
        
        fileprivate static let table: [SourcePaymentType: [String]] = [
        
            .debitCard:        RawValues.debitCard,
            .creditCard:    RawValues.creditCard,
            .prepaidCard:    RawValues.prepaidCard,
            .prepaidWallet:    RawValues.prepaidWallet,
            .null:            RawValues.null
        ]
        
        private static let debitCard        = ["DEBIT_CARD",        "DEBIT"]
        private static let creditCard        = ["CREDIT_CARD",        "CREDIT"]
        private static let prepaidCard        = ["PREPAID_CARD",        "PREPAID"]
        private static let prepaidWallet    = ["PREPAID_WALLET",    "WALLET"]
        private static let null                = ["null"]
        
        @available(*, unavailable) private init() {}
    }
    
    var textValue: String {
        return RawValues.table[self]!.first!
    }
}

extension CardBrand {
    var textValue: String {
        return RawValues.table[self]?.first ?? ""
    }
    
    fileprivate struct RawValues {

        fileprivate static let table: [CardBrand: [String]] = [

            .aiywaLoyalty       : RawValues.aiywaLoyalty,
            .americanExpress    : RawValues.americanExpress,
            .benefit            : RawValues.benefit,
            .cardGuard          : RawValues.cardGuard,
            .cbk                : RawValues.cbk,
            .dankort            : RawValues.dankort,
            .discover           : RawValues.discover,
            .dinersClub         : RawValues.dinersClub,
            .fawry              : RawValues.fawry,
            .instaPayment       : RawValues.instaPayment,
            .interPayment       : RawValues.interPayment,
            .jcb                : RawValues.jcb,
            .knet               : RawValues.knet,
            .mada               : RawValues.mada,
            .maestro            : RawValues.maestro,
            .masterCard         : RawValues.masterCard,
            .naps               : RawValues.naps,
            .nspkMir            : RawValues.nspkMir,
            .omanNet            : RawValues.omanNet,
            .sadad              : RawValues.sadad,
            .tap                : RawValues.tap,
            .uatp               : RawValues.uatp,
            .unionPay           : RawValues.unionPay,
            .verve              : RawValues.verve,
            .visa               : RawValues.visa,
            .visaElectron        : RawValues.visaElectron,
            .viva               : RawValues.viva,
            .wataniya           : RawValues.wataniya,
            .zain               : RawValues.zain
        ]

        private static let aiywaLoyalty     = ["Aiywa Loyalty"]
        private static let americanExpress  = ["AMERICAN_EXPRESS", "AMEX"]
        private static let benefit          = ["BENEFIT"]
        private static let cardGuard        = ["CARDGUARD"]
        private static let cbk              = ["CBK"]
        private static let dankort          = ["DANKORT"]
        private static let discover         = ["DISCOVER"]
        private static let dinersClub       = ["DINERS_CLUB", "DINERS"]
        private static let fawry            = ["FAWRY"]
        private static let instaPayment     = ["INSTAPAY"]
        private static let interPayment     = ["INTERPAY"]
        private static let jcb              = ["JCB"]
        private static let knet             = ["KNET"]
        private static let mada             = ["MADA"]
        private static let maestro          = ["MAESTRO"]
        private static let masterCard       = ["MASTERCARD"]
        private static let naps             = ["NAPS"]
        private static let nspkMir          = ["NSPK"]
        private static let omanNet          = ["OMAN_NET"]
        private static let sadad            = ["SADAD_ACCOUNT"]
        private static let tap              = ["TAP"]
        private static let uatp             = ["UATP"]
        private static let unionPay         = ["UNION_PAY", "UNIONPAY"]
        private static let verve            = ["VERVE"]
        private static let visa             = ["VISA"]
        private static let visaElectron        = ["VISA_ELECTRON"]
        private static let viva             = ["Viva PAY"]
        private static let wataniya         = ["Wataniya PAY"]
        private static let zain             = ["Zain PAY"]

        @available(*, unavailable) private init() {}
    }
}
