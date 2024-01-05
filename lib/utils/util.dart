mixin Util {
  static bool isNumeric(String? s) {
    if (s == null || s.contains('-')) {
      return false;
    }
    String finalString = s.replaceAll('.', '').replaceAll('');
    if (finalString.isEmpty) {
      return false;
    }
    // return double.parse(s, (e) => null) != null;
    return (double.tryParse(s) ?? null) != null;
  }
}
