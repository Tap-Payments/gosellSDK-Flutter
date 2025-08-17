class Reference {
  String? acquirer;
  String? gateway;
  String? payment;
  String? track;
  String? transaction;
  String? order;
  String? gosellID;

  Reference({
    this.acquirer,
    this.gateway,
    this.order,
    this.payment,
    this.track,
    this.transaction,
    this.gosellID,
  });

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

/// Represents configurable UI theme/appearance options that can be applied on
/// both Android and iOS SDKs. Not all platforms will use all fields.
enum ThemeAppearanceMode { windowed, fullscreen }

enum ThemeLightDarkMode { light, dark }

enum ThemeBlurStyle { none, light, extraLight, dark, regular, prominent }

class ThemeOptions {
  // Common appearance
  final ThemeAppearanceMode? appearanceMode; // maps to SDKAppearanceMode
  final ThemeLightDarkMode? darkLightMode; // iOS only

  // Background
  final String? backgroundColor; // Hex color string like #RRGGBB or #AARRGGBB
  final String? contentBackgroundColor; // Hex
  final ThemeBlurStyle? backgroundBlurStyle; // iOS only
  final double? backgroundBlurProgress; // 0..1 (iOS only)

  // Header
  final String? headerFontFamily;
  final String? headerTextColor; // Hex
  final double? headerTextSize; // Android specific
  final String? headerBackgroundColor; // Hex
  final String? headerCancelButtonFontFamily;
  final String? headerCancelButtonTextColorNormal; // Hex (iOS)
  final String? headerCancelButtonTextColorHighlighted; // Hex (iOS)
  final String? cardInputDescriptionFontFamily; // iOS description font
  final String? cardInputDescriptionTextColor; // iOS description color

  // Card input fields
  final String? cardInputFontFamily;
  final String? cardInputTextColor; // Hex
  final String? cardInputInvalidTextColor; // Hex
  final String? cardInputPlaceholderTextColor; // Hex

  // Save card switch colors (Android)
  final String? saveCardSwitchOffThumbTint; // Hex
  final String? saveCardSwitchOnThumbTint; // Hex
  final String? saveCardSwitchOffTrackTint; // Hex
  final String? saveCardSwitchOnTrackTint; // Hex

  // Card scanner
  final bool? cardScannerIconVisible; // show/hide
  final String?
  scanIconResource; // Android resource name (e.g. "drawable/btn_card_scanner_normal")
  final String? scanIconFrameTintColor; // Hex (iOS)
  final String? scanIconTintColor; // Hex (iOS)

  // Pay/Save button
  final String? payButtonBackgroundResource; // Android selector resource
  final String? payButtonFontFamily;
  final String? payButtonDisabledTitleColor; // Hex
  final String? payButtonEnabledTitleColor; // Hex
  final double? payButtonTextSize; // Android specific
  final bool? payButtonLoaderVisible;
  final bool? payButtonSecurityIconVisible;
  final String? payButtonText; // Android custom text
  final bool? showAmountOnButton; // Android
  final double? payButtonCornerRadius; // iOS
  final EdgeInsetsSpec? payButtonInsets; // iOS insets from screen edges
  final double? payButtonHeight; // iOS

  // Dialog (Android)
  final String? dialogTextColor; // Hex
  final double? dialogTextSize;

  // iOS status popup
  final bool? showStatusPopup; // sessionShouldShowStatusPopup

  ThemeOptions({
    this.appearanceMode,
    this.darkLightMode,
    this.backgroundColor,
    this.contentBackgroundColor,
    this.backgroundBlurStyle,
    this.backgroundBlurProgress,
    this.headerFontFamily,
    this.headerTextColor,
    this.headerTextSize,
    this.headerBackgroundColor,
    this.headerCancelButtonFontFamily,
    this.headerCancelButtonTextColorNormal,
    this.headerCancelButtonTextColorHighlighted,
    this.cardInputDescriptionFontFamily,
    this.cardInputDescriptionTextColor,
    this.cardInputFontFamily,
    this.cardInputTextColor,
    this.cardInputInvalidTextColor,
    this.cardInputPlaceholderTextColor,
    this.saveCardSwitchOffThumbTint,
    this.saveCardSwitchOnThumbTint,
    this.saveCardSwitchOffTrackTint,
    this.saveCardSwitchOnTrackTint,
    this.cardScannerIconVisible,
    this.scanIconResource,
    this.scanIconFrameTintColor,
    this.scanIconTintColor,
    this.payButtonBackgroundResource,
    this.payButtonFontFamily,
    this.payButtonDisabledTitleColor,
    this.payButtonEnabledTitleColor,
    this.payButtonTextSize,
    this.payButtonLoaderVisible,
    this.payButtonSecurityIconVisible,
    this.payButtonText,
    this.showAmountOnButton,
    this.payButtonCornerRadius,
    this.payButtonInsets,
    this.payButtonHeight,
    this.dialogTextColor,
    this.dialogTextSize,
    this.showStatusPopup,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appearanceMode'] = appearanceMode == null
        ? null
        : (appearanceMode == ThemeAppearanceMode.windowed
              ? 'windowed'
              : 'fullscreen');
    data['darkLightMode'] = darkLightMode == null
        ? null
        : (darkLightMode == ThemeLightDarkMode.dark ? 'dark' : 'light');
    data['backgroundColor'] = backgroundColor;
    data['contentBackgroundColor'] = contentBackgroundColor;
    if (backgroundBlurStyle != null) {
      switch (backgroundBlurStyle!) {
        case ThemeBlurStyle.none:
          data['backgroundBlurStyle'] = 'none';
          break;
        case ThemeBlurStyle.light:
          data['backgroundBlurStyle'] = 'light';
          break;
        case ThemeBlurStyle.extraLight:
          data['backgroundBlurStyle'] = 'extraLight';
          break;
        case ThemeBlurStyle.dark:
          data['backgroundBlurStyle'] = 'dark';
          break;
        case ThemeBlurStyle.regular:
          data['backgroundBlurStyle'] = 'regular';
          break;
        case ThemeBlurStyle.prominent:
          data['backgroundBlurStyle'] = 'prominent';
          break;
      }
    }
    data['backgroundBlurProgress'] = backgroundBlurProgress;
    data['headerFontFamily'] = headerFontFamily;
    data['headerTextColor'] = headerTextColor;
    data['headerTextSize'] = headerTextSize;
    data['headerBackgroundColor'] = headerBackgroundColor;
    data['headerCancelButtonFontFamily'] = headerCancelButtonFontFamily;
    data['headerCancelButtonTextColorNormal'] =
        headerCancelButtonTextColorNormal;
    data['headerCancelButtonTextColorHighlighted'] =
        headerCancelButtonTextColorHighlighted;
    data['cardInputDescriptionFontFamily'] = cardInputDescriptionFontFamily;
    data['cardInputDescriptionTextColor'] = cardInputDescriptionTextColor;
    data['cardInputFontFamily'] = cardInputFontFamily;
    data['cardInputTextColor'] = cardInputTextColor;
    data['cardInputInvalidTextColor'] = cardInputInvalidTextColor;
    data['cardInputPlaceholderTextColor'] = cardInputPlaceholderTextColor;
    data['saveCardSwitchOffThumbTint'] = saveCardSwitchOffThumbTint;
    data['saveCardSwitchOnThumbTint'] = saveCardSwitchOnThumbTint;
    data['saveCardSwitchOffTrackTint'] = saveCardSwitchOffTrackTint;
    data['saveCardSwitchOnTrackTint'] = saveCardSwitchOnTrackTint;
    data['cardScannerIconVisible'] = cardScannerIconVisible;
    data['scanIconResource'] = scanIconResource;
    data['scanIconFrameTintColor'] = scanIconFrameTintColor;
    data['scanIconTintColor'] = scanIconTintColor;
    data['payButtonBackgroundResource'] = payButtonBackgroundResource;
    data['payButtonFontFamily'] = payButtonFontFamily;
    data['payButtonDisabledTitleColor'] = payButtonDisabledTitleColor;
    data['payButtonEnabledTitleColor'] = payButtonEnabledTitleColor;
    data['payButtonTextSize'] = payButtonTextSize;
    data['payButtonLoaderVisible'] = payButtonLoaderVisible;
    data['payButtonSecurityIconVisible'] = payButtonSecurityIconVisible;
    data['payButtonText'] = payButtonText;
    data['showAmountOnButton'] = showAmountOnButton;
    data['payButtonCornerRadius'] = payButtonCornerRadius;
    data['payButtonInsets'] = payButtonInsets?.toJson();
    data['payButtonHeight'] = payButtonHeight;
    data['dialogTextColor'] = dialogTextColor;
    data['dialogTextSize'] = dialogTextSize;
    data['sessionShouldShowStatusPopup'] = showStatusPopup;
    return data;
  }
}

class EdgeInsetsSpec {
  final double left;
  final double top;
  final double right;
  final double bottom;

  EdgeInsetsSpec({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['left'] = left;
    data['top'] = top;
    data['right'] = right;
    data['bottom'] = bottom;
    return data;
  }
}

class Receipt {
  bool sms;
  bool email;
  String? id;

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
  String? metaData;

  Customer({
    required this.isdNumber,
    required this.number,
    required this.customerId,
    required this.email,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    this.metaData,
  });

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
  double? amount;
  String currency;
  int? count;
  List<Destination>? destinationlist;

  Destinations({
    this.amount,
    required this.currency,
    this.count,
    this.destinationlist,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['currency'] = this.currency;
    data['count'] = this.count;

    if (this.destinationlist != null) {
      data['destination'] = this.destinationlist!
          .map((v) => v.toJson())
          .toList();
    }

    return data;
  }
}

class Destination {
  String id;
  double amount;
  String currency;
  String? description;
  String? reference;

  Destination({
    required this.id,
    required this.amount,
    required this.currency,
    this.description,
    this.reference,
  });

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
  double amountPerUnit;
  String? description;
  Map<String, Object>? discount;
  String name;
  Quantity quantity;
  List<Tax>? taxes;
  int totalAmount;

  PaymentItem({
    required this.amountPerUnit,
    this.description,
    this.discount,
    required this.name,
    required this.quantity,
    this.taxes,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount_per_unit'] = this.amountPerUnit;
    data['description'] = this.description;

    data['discount'] = this.discount;
    data['name'] = this.name;

    data['quantity'] = this.quantity.toJson();

    if (this.taxes != null) {
      data['taxes'] = this.taxes!.map((v) => v.toJson()).toList();
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

  Amount({
    required this.type,
    required this.value,
    required this.maximumFee,
    required this.minimumFee,
  });

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

  Quantity({required this.value});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    return data;
  }
}

class Tax {
  String name;
  String? description;
  Amount amount;

  Tax({required this.amount, required this.name, this.description});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['amount'] = this.amount.toJson();
    return data;
  }
}

class Shipping {
  String name;
  String? description;
  double amount;

  Shipping({required this.name, this.description, required this.amount});

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

  AuthorizeAction({required this.type, required this.timeInHours});

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

enum CardType { DEBIT, CREDIT, ALL }
