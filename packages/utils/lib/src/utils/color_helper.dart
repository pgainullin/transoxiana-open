part of all_utils;

Color colorFromJson(String value) => Color(int.parse(value));
String colorToJson(Color color) => color.toJson();

extension ColorExt on Color {
  String toJson() => value.toString();
}
