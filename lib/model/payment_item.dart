import 'package:go_sell_sdk_flutter/enum/amount_modificator_type.dart';
import 'package:go_sell_sdk_flutter/model/tax.dart';

class PaymentItem {
  PaymentItem({this.name,this.amountPerUnit,this.discount,this.description,this.quantity,this.taxes,this.totalAmount});

  String name;
  String description;
  int quantity;
  double amountPerUnit;
  AmountModificatorType discount;
  List<Tax> taxes;
  double totalAmount;
}
