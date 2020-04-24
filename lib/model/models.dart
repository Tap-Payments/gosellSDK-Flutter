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

class Destinations {
  double amount;
  String currency;
  int count;
  List<Destination> destinationlist;

  Destinations({this.amount, this.currency, this.count, this.destinationlist});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['count'] = this.count;

    if (this.destinationlist != null) {
      data['destination'] =
          this.destinationlist.map((v) => v.toJson()).toList();
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
  Map<String, Object> discount;
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
  double maximumFee;
  double minimumFee;
  Amount({this.type, this.value, this.maximumFee, this.minimumFee});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    data['maximum_fee'] = this.maximumFee;
    data['minimum_fee'] = this.minimumFee;
    return data;
  }
}

class Quantity {
  int value;

  Quantity({this.value});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    return data;
  }
}

class Tax {
  String name;
  String description;
  Amount amount;

  Tax({this.amount, this.name, this.description});

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

  Map<String, dynamic> toJson() {
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
