import 'package:go_sell_sdk_flutter/model/amount_modificator.dart';

class Tax {
  String name;
  String description;
  AmountModificator amount;

  Tax(this.name, this.description, this.amount);
}
