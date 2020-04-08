import 'package:go_sell_sdk_flutter/enum/authorize_action_type.dart';

class AuthorizeAction {
  AuthorizeActionType type;
  int timeInHours;

  AuthorizeAction(this.type, this.timeInHours);
}
