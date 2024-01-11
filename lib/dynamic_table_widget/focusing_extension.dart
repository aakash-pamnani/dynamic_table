import 'package:flutter/material.dart';

extension Focusing on FocusNode {
  void focus(bool focused) {
    if (focused)
      this.requestFocus();
    else
      this.unfocus();
  }
}
