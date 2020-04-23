import Flutter
import UIKit
import goSellSDK

public class SwiftGoSellSdkFlutterPlugin: NSObject, FlutterPlugin {
    let session = Session()
    public var argsSessionParameters:[String:Any]?
    public var argsAppCredentials:[String:String]?
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
    
    let dict = call.arguments as? [String: Any]
    argsDataSource = dict
    GoSellSDK.reset()
    let secretKey = SecretKey(sandbox: sandBoxSecretKey, production: productionSecretKey)
    GoSellSDK.secretKey = secretKey
    GoSellSDK.mode = sdkMode
    GoSellSDK.language = sdkLang
    session.dataSource = self
    session.start()

    result(["key": "iOS  + sssssssssss "])
  }
}

extension SwiftGoSellSdkFlutterPlugin: SessionDataSource {

    public var customer: Customer?{
      return newCustomer
    }
    public var newCustomer: Customer {
      if let customerString:String = argsSessionParameters?["customer"] as? String {
        if let data = customerString.data(using: .utf8) {
          do {
            let customerDictionary:[String:String] = try JSONSerialization.jsonObject(with: data, options: []) as! [String : String]
            return try Customer.init(emailAddress: EmailAddress(emailAddressString: customerDictionary["email"] ?? ""), phoneNumber: PhoneNumber(isdNumber: customerDictionary["isdNumber"] ?? "", phoneNumber: customerDictionary["number"] ?? ""), firstName: customerDictionary["first_name"] ?? "", middleName: customerDictionary["middle_name"] ?? "", lastName: customerDictionary["last_name"] ?? "")
          } catch {
            print(error.localizedDescription)
          }
        }
      }
      let emailAddress = try! EmailAddress(emailAddressString: "customer@mail.com")
      let phoneNumber = try! PhoneNumber(isdNumber: "965", phoneNumber: "96512345")
      return try! Customer(emailAddress: emailAddress,
                 phoneNumber:  phoneNumber,
                 firstName:   "Steve",
                 middleName:  nil,
                 lastName:   "Jobs")
    }
    
    
    public var currency: Currency? {
      if let currencyString:String = argsSessionParameters?["transactionCurrency"] as? String {
        return .with(isoCode: currencyString)
      }
      return .with(isoCode: "KWD")
    }

    
    public var merchantID: String?
    {
      if let merchantIDString:String = argsSessionParameters?["merchantID"] as? String {
        //  return merchantIDString
      }
      return "599424"
    }
    public var sandBoxSecretKey: String{
      if let sandBoxSecretKeyString:String = argsAppCredentials?["secrete_key"] {
        return sandBoxSecretKeyString
      }
      return "sk_test_cvSHaplrPNkJO7dhoUxDYjqA"
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
      return "sk_test_cvSHaplrPNkJO7dhoUxDYjqA"
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
      return 100
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
      return "merchant.tap.gosell"
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
      return Receipt(email: true, sms: true)
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
      return .capture(after: 8)
    }
    public var destinations: [Destination]? {
      if let destinationsGroupString:String = argsSessionParameters?["destinations"] as? String {
        if let data = destinationsGroupString.data(using: .utf8) {
          do {
            if let destinationsGroupJson:[String:Any] = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String : Any],
              let destinationsJson:[[String:Any]] = destinationsGroupJson["destinations"] as? [[String:Any]] {
              let destinationData = try JSONSerialization.data(withJSONObject: destinationsJson, options: [.fragmentsAllowed])
              let decoder = JSONDecoder()
              let destinationsItems:[Destination] = try decoder.decode([Destination].self, from: destinationData)
              return destinationsItems
            }
          } catch {}
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
