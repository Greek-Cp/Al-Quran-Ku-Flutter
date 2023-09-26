import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ComponentTextDescription extends StatelessWidget {
  String? textContent;
  TextAlign textAlign;
  Color teksColor = Colors.black;
  double fontSize;
  FontWeight? fontWeight;
  int? maxLines;
  bool? isWrappedText;
  ComponentTextDescription(this.textContent,
      {this.textAlign = TextAlign.start,
      this.teksColor = Colors.black,
      required this.fontSize,
      this.fontWeight = FontWeight.normal,
      this.maxLines,
      this.isWrappedText});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _textDesc(
        textDesc: textContent.toString(),
        textAlign: textAlign,
        teksColor: this.teksColor);
  }

  Widget _textDesc(
      {String textDesc = "",
      textAlign = TextAlign.center,
      Color teksColor = Colors.black}) {
    return Text(
      "$textDesc",
      style: GoogleFonts.poppins(
          fontSize: fontSize.sp, fontWeight: fontWeight, color: teksColor),
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      strutStyle: StrutStyle(forceStrutHeight: isWrappedText),
    );
  }
}
