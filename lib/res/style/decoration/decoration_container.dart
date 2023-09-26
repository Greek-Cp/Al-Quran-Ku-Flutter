import 'package:alquran_ku/res/colors/list_color.dart';
import 'package:flutter/material.dart';

class DecorationContainer {
  static BoxDecoration boxDecorationDefault = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        ListColor.gradientTopColor, // #08F4F9
        ListColor.gradientBottomColor
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
}
