import 'package:flutter/material.dart';

class FormatWidgets {
  Color colorBackGroundInputs = const Color.fromARGB(211, 255, 255, 255);

  Color textColor = const Color.fromARGB(174, 25, 17, 68);

  TextStyle textStyleBase(
      {FontWeight fontWeight = FontWeight.normal, double fontSizeValue = 21}) {
    return TextStyle(
        fontWeight: fontWeight, color: textColor, fontSize: fontSizeValue);
  }

  SizedBox spaceBetween() {
    return const SizedBox(height: 20);
  }

  TextField inputTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: textStyleBase(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
          border: InputBorder.none, hintStyle: textStyleBase(), hintText: hint),
    );
  }

  Container inputContainer(dynamic childContainer,
      {double paddingValue = 2, double widhtValue = double.infinity}) {
    return Container(
        width: widhtValue,
        padding: EdgeInsets.all(paddingValue),
        decoration: BoxDecoration(
            color: colorBackGroundInputs,
            borderRadius: BorderRadius.circular(10)),
        child: childContainer);
  }
}
