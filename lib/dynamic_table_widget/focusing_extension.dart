import 'package:flutter/material.dart';

typedef UnfocusFocusNode = void Function ();

extension Focusing on FocusNode {
  // ignore: avoid_positional_boolean_parameters
  void focus(bool focused) {
    if (focused) {
      this.requestFocus();
    } else {
      this.unfocus();
    }
  }
}
