extension StrinExt on String {
  String toProperCase() {
    final str = this;
    if (str.isEmpty) return '';
    final strBuffer = StringBuffer();
    final first = str[0].toUpperCase();
    final rest = str.substring(1);
    for (final txt in [first, rest]) {
      strBuffer.write(txt);
    }

    return strBuffer.toString();
  }
}
