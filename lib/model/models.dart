class Charge {
  String object;
  bool liveMode;
  String apiVersion;
  String id;
  String status;
  int amount;
  String currency;
  bool threeDSecure;
  bool saveCard;
  String description;
  String statementDescriptor;
  Metadata metadata;
  Transaction transaction;
  Reference reference;
  Response response;
  Receipt receipt;
  Customer customer;
  Source source;
  Post post;
  Post redirect;

  Charge(
      {this.object,
      this.liveMode,
      this.apiVersion,
      this.id,
      this.status,
      this.amount,
      this.currency,
      this.threeDSecure,
      this.saveCard,
      this.description,
      this.statementDescriptor,
      this.metadata,
      this.transaction,
      this.reference,
      this.response,
      this.receipt,
      this.customer,
      this.source,
      this.post,
      this.redirect});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['object'] = this.object;
    data['live_mode'] = this.liveMode;
    data['api_version'] = this.apiVersion;
    data['id'] = this.id;
    data['status'] = this.status;
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['threeDSecure'] = this.threeDSecure;
    data['save_card'] = this.saveCard;
    data['description'] = this.description;
    data['statement_descriptor'] = this.statementDescriptor;
    if (this.metadata != null) {
      data['metadata'] = this.metadata.toJson();
    }
    if (this.transaction != null) {
      data['transaction'] = this.transaction.toJson();
    }
    if (this.reference != null) {
      data['reference'] = this.reference.toJson();
    }
    if (this.response != null) {
      data['response'] = this.response.toJson();
    }
    if (this.receipt != null) {
      data['receipt'] = this.receipt.toJson();
    }
    if (this.customer != null) {
      data['customer'] = this.customer.toJson();
    }
    if (this.source != null) {
      data['source'] = this.source.toJson();
    }
    if (this.post != null) {
      data['post'] = this.post.toJson();
    }
    if (this.redirect != null) {
      data['redirect'] = this.redirect.toJson();
    }
    return data;
  }
}

class Metadata {
  String udf1;

  Metadata({this.udf1});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['udf1'] = this.udf1;
    return data;
  }
}

class Transaction {
  String authorizationId;
  String timezone;
  String created;
  String url;

  Transaction({this.authorizationId, this.timezone, this.created, this.url});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['authorization_id'] = this.authorizationId;
    data['timezone'] = this.timezone;
    data['created'] = this.created;
    data['url'] = this.url;
    return data;
  }
}

class Reference {
  String acquirer;
  String gateway;
  String payment;
  String track;
  String transaction;
  String order;
  String gosellID;

  Reference(
      {this.acquirer,
      this.gateway,
      this.order,
      this.payment,
      this.track,
      this.transaction,
      this.gosellID});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['track'] = this.track;
    data['payment'] = this.payment;
    data['gateway'] = this.gateway;
    data['acquirer'] = this.acquirer;
    data['transaction'] = this.transaction;
    data['order'] = this.order;
    data['gosellID'] = this.gosellID;
    return data;
  }
}

class Response {
  String code;
  String message;

  Response({this.code, this.message});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['message'] = this.message;
    return data;
  }
}

class Receipt {
  bool sms;
  bool email;
  String id;
  Receipt(this.sms, this.email, {this.id});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['sms'] = this.sms;
    return data;
  }
}

class Customer {
  String firstName;
  String middleName;
  String lastName;
  String email;
  // Phone phone;

  String isdNumber;
  String number;
  String customerId;
  String metaData;

  Customer(
      {this.isdNumber,
      this.number,
      this.customerId,
      this.email,
      this.firstName,
      this.middleName,
      this.lastName,
      this.metaData});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isdNumber'] = this.isdNumber;
    data['number'] = this.number;
    data['customerId'] = this.customerId;
    data['first_name'] = this.firstName;
    data['middle_name'] = this.middleName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    // if (this.phone != null) {
    //   data['phone'] = this.phone.toJson();
    // }
    return data;
  }
}

// class Phone {
//   String countryCode;
//   String number;

//   Phone({this.countryCode, this.number});

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['country_code'] = this.countryCode;
//     data['number'] = this.number;
//     return data;
//   }
// }

class Source {
  String object;
  String id;

  Source({this.object, this.id});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['object'] = this.object;
    data['id'] = this.id;
    return data;
  }
}

class Post {
  String url;

  Post({this.url});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    return data;
  }
}

class Destinations {
  double amount;
  String currency;
  int count;
  List<Destination> destinations;

  Destinations({this.amount, this.currency, this.count, this.destinations});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['count'] = this.count;

    if (this.destinations != null) {
      data['destinations'] = this.destinations.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Destination {
  String id;
  double amount;
  String currency;
  String description;
  String reference;

  Destination(
      {this.id, this.amount, this.currency, this.description, this.reference});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['id'] = this.id;
    data['currency'] = this.currency;
    data['description'] = this.description;
    data["reference"] = this.reference;
    return data;
  }
}

class PaymentItem {
  int amountPerUnit;
  String description;
  Map<String,Object> discount;
  String name;
  Quantity quantity;
  List<Tax> taxes;
  int totalAmount;

  PaymentItem(
      {this.amountPerUnit,
      this.description,
      this.discount,
      this.name,
      this.quantity,
      this.taxes,
      this.totalAmount});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount_per_unit'] = this.amountPerUnit;
    data['description'] = this.description;

      data['discount'] = this.discount;
    data['name'] = this.name;

    if (this.quantity != null) {
      data['quantity'] = this.quantity.toJson();
    }

    if (this.taxes != null) {
      data['taxes'] = this.taxes.map((v) => v.toJson()).toList();
    }

    data['total_amount'] = this.totalAmount;

    return data;
  }
}

class Amount {
  String type;
  double value;
  double maximum_fee;
  double minimum_fee;
  Amount({this.type, this.value,this.maximum_fee,this.minimum_fee});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    data['maximum_fee'] = this.maximum_fee;
    data['minimum_fee'] = this.minimum_fee;
    return data;
  }
}

class Quantity {
  String measurementGroup;
  String measurementUnit;
  int value;

  Quantity({this.measurementGroup, this.measurementUnit, this.value});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['measurement_group'] = this.measurementGroup;
    data['measurement_unit'] = this.measurementUnit;
    data['value'] = this.value;
    return data;
  }
}

class Tax {
  String name;
  String description;
  Amount amount;
  

  Tax({this.amount,this.name,this.description});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
     if (this.amount != null) {
      data['amount'] = this.amount.toJson();
    }
    return data;
  }
}

class Shipping {
  String name;
  String description;
  double amount;

  Shipping({this.name, this.description, this.amount});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['amount'] = this.amount;
    return data;
  }
}

class AuthorizeAction {

  AuthorizeActionType type;
  int timeInHours;

  AuthorizeAction({this.type, this.timeInHours});

  Map<String,dynamic> toJson(){
     final Map<String, dynamic> data = new Map<String, dynamic>();
      data['timeInHours'] = this.timeInHours;
      data['time'] = this.timeInHours;
     switch (this.type) {
       case AuthorizeActionType.CAPTURE:
         data['type'] = "CAPTURE";
         break;
       case AuthorizeActionType.VOID:
         data['type'] = "VOID";
         break;  
       default:
     }
    return data;
  }
}

enum AuthorizeActionType { CAPTURE, VOID }

enum CardType { DEBIT, CREDIT }

