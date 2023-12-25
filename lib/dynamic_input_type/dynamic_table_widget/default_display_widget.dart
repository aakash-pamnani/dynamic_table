import 'package:dynamic_table/dynamic_table.dart';
import 'package:flutter/material.dart';

class DefaultDisplayWidget<T> extends StatefulWidget {
  const DefaultDisplayWidget({
    super.key,
    String Function(T? value)? displayBuilder,
    required T? value,
    required focused
  }) : _displayBuilder = displayBuilder,
      _value = value,
      _focused = focused;

  final String Function(T? value)? _displayBuilder;
  final T? _value;
  final bool _focused;

  @override
  State<DefaultDisplayWidget<T>> createState() => _DefaultDisplayWidgetState<T>();
}

class _DefaultDisplayWidgetState<T> extends State<DefaultDisplayWidget<T>> {
  String _defaultDisplayBuilder(T? value) {
    return value?.toString()??'';
  }

  FocusNode? focusNode;

  @override
  void initState() {
    focusNode = new FocusNode();
    super.initState();
  }

  @override
  void didUpdateWidget(DefaultDisplayWidget<T> oldWidget) {
    focusNode = new FocusNode();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    focusNode?.unfocus();
    focusNode?.dispose();
    focusNode = null;
  }

  @override
  Widget build(BuildContext context) {
    focusNode?.focus(widget._focused);
    return Focus(child: Text((widget._displayBuilder ?? _defaultDisplayBuilder).call(widget._value)), focusNode: focusNode,);
  }
}
