import 'package:dynamic_table/dynamic_table.dart';
import 'package:dynamic_table/dynamic_table_widget/focusing_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefaultDisplayWidget<T> extends StatefulWidget {
  const DefaultDisplayWidget({
    super.key,
    String Function(T? value)? displayBuilder,
    required T? value,
    required focused,
    required this.onEditComplete,
    required this.row,
    required this.column
  }) : _displayBuilder = displayBuilder,
      _value = value,
      _focused = focused;

  final String Function(T? value)? _displayBuilder;
  final T? _value;
  final bool _focused;
  final void Function(int row, int column)? onEditComplete;
  final int row;
  final int column;

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
    super.initState();
    focusNode = new FocusNode();
    focusNode?.onKeyEvent = (node, event) {
      if (widget.onEditComplete != null &&
          (event.logicalKey ==
              LogicalKeyboardKey.tab)) if (event is KeyDownEvent) {
        widget.onEditComplete!.call(widget.row, widget.column);
        return KeyEventResult.handled;
      } else {
                return KeyEventResult.handled;
              }

      return KeyEventResult.ignored;
    };
    focusNode?.focus(widget._focused);
  }

  @override
  void didUpdateWidget(DefaultDisplayWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    focusNode?.focus(widget._focused);
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
    return Focus(child: Text((widget._displayBuilder ?? _defaultDisplayBuilder).call(widget._value)), focusNode: focusNode,);
  }
}
