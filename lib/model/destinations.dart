import 'package:go_sell_sdk_flutter/enum/destination.dart';

class Destinations {
  double amount;
  String currency;
  int count;
  List<Destination> destinations;

  Destinations(this.amount, this.currency, int count, this.destinations);
}
