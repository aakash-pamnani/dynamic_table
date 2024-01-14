import 'package:dynamic_table/dynamic_table.dart';
import 'package:dynamic_table/dynamic_table_widget/focusing_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicTableDateInputWidget extends StatefulWidget {
  const DynamicTableDateInputWidget(
      {super.key,
      required DateTime initialDate,
      required DateTime lastDate,
      required bool readOnly,
      required InputDecoration? decoration,
      required TextStyle? style,
      required StrutStyle? strutStyle,
      required TextDirection? textDirection,
      required TextAlign textAlign,
      required TextAlignVertical? textAlignVertical,
      required MouseCursor? mouseCursor,
      required this.value,
      required this.onChanged,
      required this.onEditComplete,
      required this.focusThisField,
      required this.row,
      required this.column,
      required this.focused,
      required this.displayBuilder})
      : _initialDate = initialDate,
        _lastDate = lastDate,
        _readOnly = readOnly,
        _decoration = decoration,
        _style = style,
        _strutStyle = strutStyle,
        _textDirection = textDirection,
        _textAlign = textAlign,
        _textAlignVertical = textAlignVertical,
        _mouseCursor = mouseCursor;

  final DateTime _initialDate;
  final DateTime _lastDate;
  final bool _readOnly;
  final InputDecoration? _decoration;
  final TextStyle? _style;
  final StrutStyle? _strutStyle;
  final TextDirection? _textDirection;
  final TextAlign _textAlign;
  final TextAlignVertical? _textAlignVertical;
  final MouseCursor? _mouseCursor;
  final DateTime? value;
  final Function(DateTime? value, int row, int column)? onChanged;
  final void Function(int row, int column)? onEditComplete;
  final void Function(int row, int column)? focusThisField;
  final int row;
  final int column;
  final bool focused;
  final String Function(DateTime?) displayBuilder;

  @override
  State<DynamicTableDateInputWidget> createState() =>
      _DynamicTableDateInputWidgetState();
}

enum Completion {
  Completed, Cancelled
}

class _DynamicTableDateInputWidgetState
    extends State<DynamicTableDateInputWidget> {
  TextEditingController? controller;
  FocusNode? focusNode;
  FocusNode? datePickerIconFocusNode;

  Future<DateTime> _showPicker(DateTime selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: widget._initialDate,
      lastDate: widget._lastDate,
    );
    if (picked == null) {
      return Future.error(Completion.Cancelled);
    }
    if (picked != selectedDate) {
      selectedDate = picked;
    }
    return selectedDate;
  }

  void showPicker() {
    _showPicker(widget.value ?? DateTime.now()).then((value) {
      widget.onChanged?.call(value, widget.row, widget.column);
      widget.onEditComplete?.call(widget.row, widget.column);
      controller?.text = widget.displayBuilder(value);
    }, onError: (error) {if (error != Completion.Cancelled) throw error;});
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    datePickerIconFocusNode = FocusNode();

    focusNode?.addListener(() {
      if ((focusNode?.hasFocus ?? false) &&
          !widget.focused) {
        widget.focusThisField?.call(widget.row, widget.column);
      }
    });
    datePickerIconFocusNode?.addListener(() {
      if ((focusNode?.hasFocus ?? false) &&
          !widget.focused) {
        widget.focusThisField?.call(widget.row, widget.column);
      }
    });

    focusNode?.onKeyEvent = (node, event) {
      if (widget.onEditComplete != null &&
          (event.logicalKey ==
              LogicalKeyboardKey.tab)) if (event is KeyDownEvent) {
        widget.onEditComplete?.call(widget.row, widget.column);
        return KeyEventResult.handled;
      } else {
                return KeyEventResult.handled;
              }

      if ((event.logicalKey == LogicalKeyboardKey.enter)) if (event
          is KeyDownEvent) {
        if (!widget._readOnly) {
          widget.onEditComplete?.call(widget.row, widget.column);
        } else {
          showPicker.call();
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };

    datePickerIconFocusNode?.onKeyEvent = (node, event) {
      if (widget.onEditComplete != null &&
          (event.logicalKey ==
              LogicalKeyboardKey.tab)) if (event is KeyDownEvent) {
        widget.onEditComplete?.call(widget.row, widget.column);
        return KeyEventResult.handled;
      } else {
                return KeyEventResult.handled;
              }
      return KeyEventResult.ignored;
    };

    controller?.text = widget.displayBuilder(widget.value);
    if (!widget._readOnly) {
      focusNode?.focus(widget.focused);
    } else {
      datePickerIconFocusNode?.focus(widget.focused);
    }
  }

  @override
  void didUpdateWidget(DynamicTableDateInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller?.text = widget.displayBuilder(widget.value);
    if (!widget._readOnly) {
      focusNode?.focus(widget.focused);
    } else {
      datePickerIconFocusNode?.focus(widget.focused);
    }
  }

  @override
  void dispose() {
    super.dispose();
    focusNode?.unfocus();
    datePickerIconFocusNode?.unfocus();
    controller?.dispose();
    focusNode?.dispose();
    datePickerIconFocusNode?.dispose();
    controller = null;
    focusNode = null;
    datePickerIconFocusNode = null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) =>
            RegExp(r'^(\d{0,2}\/?){0,2}(\d{0,4}\/?){0,1}$')
                    .hasMatch(newValue.text)
                ? newValue
                : oldValue)
      ],
      keyboardType: TextInputType.datetime,
      decoration: widget._decoration?.copyWith(
        suffixIcon: InkWell(
          focusNode: datePickerIconFocusNode,
          child: widget._decoration?.suffixIcon ??
              const Icon(Icons.calendar_today),
          onTap: showPicker,
        ),
      ),
      style: widget._style,
      strutStyle: widget._strutStyle,
      textDirection: widget._textDirection,
      textAlign: widget._textAlign,
      textAlignVertical: widget._textAlignVertical,
      mouseCursor: widget._mouseCursor,
      readOnly: widget._readOnly,
      onEditingComplete: () =>
          widget.onEditComplete?.call(widget.row, widget.column),
    );
  }
}
