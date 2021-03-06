import 'package:flutter/material.dart';

class TextPasswordInput extends StatefulWidget {
  final String? hintText;
  final String? initialValue;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const TextPasswordInput(
      {Key? key,
      this.hintText,
      this.initialValue,
      this.onChanged,
      this.validator})
      : super(key: key);

  @override
  _TextPasswordInputState createState() => _TextPasswordInputState();
}

class _TextPasswordInputState extends State<TextPasswordInput> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      validator: widget.validator,
      obscureText: !_passwordVisible,
      initialValue: widget.initialValue,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: widget.hintText,
        fillColor: Theme.of(context).cardColor,
        filled: true,
        suffixIcon: IconButton(
          icon:
              Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
          color: Colors.black,
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
    );
  }
}
