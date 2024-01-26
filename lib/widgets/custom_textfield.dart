import 'package:flutter/material.dart';
import 'package:ivrapp/constants.dart';
class CustomTextFormField extends StatelessWidget {
  final hintText;
  final TextEditingController controller;
  final  maxLines;
  final TextInputType keyboardType;
  CustomTextFormField(
      {required this.hintText,
        required this.controller,
        this.maxLines=1,
        required this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextFormField(
        maxLines: maxLines,
        keyboardType: keyboardType,
        controller: controller,
        textInputAction: TextInputAction.next,
        validator: (val) {
          if (val == null || val.isEmpty) {
            return 'Enter your ${hintText}';
          }
          return null;
        },
        decoration: InputDecoration(
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(width: 1, color: redColor)),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(width: 1, color: redColor),
          ),
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 15),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(width: 1, color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            borderSide: BorderSide(width: 1, color: greenColor),
          ),
        ),
      ),
    );
  }
}