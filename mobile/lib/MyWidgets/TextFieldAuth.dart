import 'package:flutter/material.dart';

class TextFieldAuth extends StatelessWidget {
  TextEditingController textController = TextEditingController();
  String hintText = "";
  TextFieldAuth({
  Key? key,
  required this.textController,
  required this.hintText,
  }) : super(
    key: key
);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.purple),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hintText,
          fillColor: Colors.grey[200],
          filled: true,
        ),
      ),
    );
  }
}
