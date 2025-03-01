import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ButtonBack extends StatelessWidget {
  bool? isArrowLeft;

  VoidCallback? onTap;
  ButtonBack(this.onTap, {this.isArrowLeft});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: onTap,
      child: isArrowLeft == false
          ? Image.asset(
              "assets/icon/ic_back.png",
              fit: BoxFit.cover,
              width: 30,
              height: 30,
            )
          : Image.asset(
              "assets/icon/ic_back_left.png",
              fit: BoxFit.cover,
              width: 30,
              height: 30,
            ),
    );
  }
}
