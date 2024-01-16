import 'package:dynamic_table/dynamic_table_source/dynamic_table_view.dart';
import 'package:dynamic_table/dynamic_table_widget/focusing_extension.dart';
import 'package:dynamic_table/dynamic_table_widget/key_event_handlers.dart';
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
      required this.touchEditCallBacks,
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
  final Function(
    DateTime? value,
  )? onChanged;
  final TouchEditCallBacks touchEditCallBacks;
  final bool focused;
  final String Function(DateTime?) displayBuilder;

  @override
  State<DynamicTableDateInputWidget> createState() =>
      _DynamicTableDateInputWidgetState();
}

enum Completion { Completed, Cancelled }

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
      widget.onChanged?.call(
        value,
      );
      widget.touchEditCallBacks.focusNextField?.call();
      controller?.text = widget.displayBuilder(value);
    }, onError: (error) {
      if (error != Completion.Cancelled) throw error;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    datePickerIconFocusNode = FocusNode();

    widget.touchEditCallBacks.updateFocusCache?.call(identity: this, () => setState(() {
          focusNode?.unfocus();
          datePickerIconFocusNode?.unfocus();
        }), () => (!widget._readOnly)? focusNode : datePickerIconFocusNode);

    focusNode?.addListener(() {
      if ((focusNode?.hasFocus ?? false) && !widget.focused) {
        widget.touchEditCallBacks.focusThisEditingField?.call();
      }
    });
    datePickerIconFocusNode?.addListener(() {
      if ((focusNode?.hasFocus ?? false) && !widget.focused) {
        widget.touchEditCallBacks.focusThisEditingField?.call();
      }
    });

    focusNode?.onKeyEvent = (node, event) => event.handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
        [LogicalKeyboardKey.tab], widget.touchEditCallBacks.focusPreviousField,
        withShift:
            true).chain([LogicalKeyboardKey.tab], widget.touchEditCallBacks.focusNextField).chain(
        [LogicalKeyboardKey.enter],
        () =>
            (!widget._readOnly) ? widget.touchEditCallBacks.focusNextField : showPicker).chain(
        [LogicalKeyboardKey.escape], widget.touchEditCallBacks.cancelEdit).result();

    datePickerIconFocusNode?.onKeyEvent = (node, event) =>
        event.handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
            [LogicalKeyboardKey.tab], widget.touchEditCallBacks.focusPreviousField,
            withShift: true).chain([
          LogicalKeyboardKey.tab
        ], widget.touchEditCallBacks.focusNextField).chain(
            [LogicalKeyboardKey.escape],
            widget.touchEditCallBacks.cancelEdit).result();

    if (controller?.text != widget.displayBuilder(widget.value)) {
      controller?.text = widget.displayBuilder(widget.value);
    }
    if (!widget._readOnly) {
      focusNode?.focus(widget.focused);
    } else {
      datePickerIconFocusNode?.focus(widget.focused);
    }
  }

  @override
  void didUpdateWidget(DynamicTableDateInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller?.text != widget.displayBuilder(widget.value)) {
      controller?.text = widget.displayBuilder(widget.value);
    }
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
    widget.touchEditCallBacks.clearFocusCache?.call(identity: this);
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
      onEditingComplete: () => widget.touchEditCallBacks.focusNextField?.call(),
    );
  }
}
