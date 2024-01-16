import 'package:dynamic_table/dynamic_table_source/dynamic_table_view.dart';
import 'package:dynamic_table/dynamic_table_widget/focusing_extension.dart';
import 'package:dynamic_table/dynamic_table_widget/key_event_handlers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefaultDisplayWidget<T> extends StatefulWidget {
  const DefaultDisplayWidget({
    super.key,
    String Function(T? value)? displayBuilder,
    required T? value,
    required focused,
    required this.touchEditCallBacks,
  })  : _displayBuilder = displayBuilder,
        _value = value,
        _focused = focused;

  final String Function(T? value)? _displayBuilder;
  final T? _value;
  final bool _focused;
  final TouchEditCallBacks touchEditCallBacks;

  @override
  State<DefaultDisplayWidget<T>> createState() =>
      _DefaultDisplayWidgetState<T>();
}

class _DefaultDisplayWidgetState<T> extends State<DefaultDisplayWidget<T>> {
  String _defaultDisplayBuilder(T? value) {
    return value?.toString() ?? '';
  }

  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = new FocusNode();
    widget.touchEditCallBacks.updateFocusCache?.call(
        identity: this,
        UpdateFocusNodeCallBacks(
            unfocusFocusNodes: () => setState(() {
                  focusNode?.unfocus();
                }),
            focusFocusNodes: () => setState(() {
                  focusNode?.requestFocus();
                })));
    focusNode?.onKeyEvent = (node, event) =>
        event.handleKeysIfCallBackExistAndCallOnlyOnKeyDown([
          LogicalKeyboardKey.tab
        ],
            widget.touchEditCallBacks.focusPreviousField, withShift: true).chain([
          LogicalKeyboardKey.tab
        ], widget.touchEditCallBacks.focusNextField).chain(
            [LogicalKeyboardKey.enter], widget.touchEditCallBacks.edit).result();
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
    widget.touchEditCallBacks.clearFocusCache?.call(identity: this);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: Text((widget._displayBuilder ?? _defaultDisplayBuilder)
          .call(widget._value)),
      focusNode: focusNode,
    );
  }
}
