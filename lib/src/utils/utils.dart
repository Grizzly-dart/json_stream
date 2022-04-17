extension HexString on String {
  bool get isHex {
    if (codeUnits.length != 1) {
      return false;
    }
    final code = codeUnitAt(0);
    if (code >= 48 && code <= 57) {
      return true;
    } else if (code >= 97 && code <= 102) {
      return true;
    } else if (code >= 65 && code <= 70) {
      return true;
    }
    return false;
  }
}
