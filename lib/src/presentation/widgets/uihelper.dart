import 'package:flutter/material.dart';

class Uihelper {
  // ignore: non_constant_identifier_names
  static CustomImage({required String img}) {
    return Image.asset("assets/images/$img");
  }

  // ignore: non_constant_identifier_names
  static CustomText({
    required String text,
    required Color color,
    required FontWeight fontweight,
    String? fontfamily,
    required double fontsize,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontsize,
        fontFamily: fontfamily ?? "regular",
        fontWeight: fontweight,
        color: color,
      ),
    );
  }
}
