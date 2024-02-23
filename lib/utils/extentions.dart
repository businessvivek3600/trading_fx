extension stringExtention on String? {
  double toDouble([double defaultValue = 0.0]) {
    return double.tryParse(this ?? '') ?? defaultValue;
  }

  //to int
  int toInt([int defaultValue = 0]) {
    return int.tryParse(this ?? '') ?? defaultValue;
  }
}

extension intExtention on int? {
  double toDouble([double defaultValue = 0.0]) {
    return double.tryParse(this?.toString() ?? '') ?? defaultValue;
  }
}

extension doubleExtention on double? {
  double toDouble([double defaultValue = 0.0]) {
    return double.tryParse(this?.toString() ?? '0.0') ?? defaultValue;
  }
}
