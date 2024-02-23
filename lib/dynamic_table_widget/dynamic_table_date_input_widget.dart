import 'dart:async';

import 'package:dynamic_table/dynamic_table_source/dynamic_table_view.dart';
import 'package:dynamic_table/dynamic_table_widget/completion.dart';
import 'package:dynamic_table/dynamic_table_widget/focusing_extension.dart';
import 'package:dynamic_table/dynamic_table_widget/key_event_handlers.dart';
import 'package:dynamic_table/dynamic_table_widget/logging.dart';
import 'package:dynamic_table/utils/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//TODO: in text input mode restrict the date to be within the initial and last dates as given by the widget
//TODO: make date editable incrementally in text input mode
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
      required this.displayBuilder,
      required this.tryParseDate})
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
  final DateTime? Function(String?) tryParseDate;

  @override
  State<DynamicTableDateInputWidget> createState() =>
      _DynamicTableDateInputWidgetState();
}

class _DynamicTableDateInputWidgetState
    extends State<DynamicTableDateInputWidget> {
  TextEditingController? controller;
  FocusNode? focusNode;
  FocusNode? datePickerIconFocusNode;

  Future<ActionCompletionResult<DateTime>> _showPicker(DateTime selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: widget._initialDate,
      lastDate: widget._lastDate,
    );
    if (picked == null) {
      return Future.value(ActionCompletionResult.cancel());
    }
    if (picked != selectedDate) {
      return Future.value(ActionCompletionResult.edit(picked));
    }
    return Future.value(ActionCompletionResult.complete(selectedDate));
  }

  void showPicker(DateTime? selectedDate) async {
    await _showPicker(selectedDate??DateTime.now())
        .then<ActionCompletionResult<DateTime>>((value) {
      if (value.status == ActionCompletion.Edited) {
        controller?.text =
            widget.displayBuilder(value.data.editedValue?.editedValue);
      }
      if (value.status == ActionCompletion.Edited
      || value.status == ActionCompletion.Completed) {
        widget.touchEditCallBacks.focusNextField?.call();
      }
      return value;
    });
  }

  void _focusThisWidget({ required bool isFocused}) {
    if (!widget._readOnly) {
      focusNode?.focus(isFocused);
      [LoggingWidget.loggingFocus].info(() => 'DateInput: focusing date input text input control.');
    }
    else {
      [LoggingWidget.loggingFocus].info(() => 'DateInput: focusing date input calender icon.');
      datePickerIconFocusNode?.focus(isFocused);
    }
  }

  void _init() {
    widget.touchEditCallBacks.updateFocusCache?.call(
        identity: this,
        UpdateFocusNodeCallBacks(
            unfocusFocusNodes: () => setState(() {
                  _focusThisWidget(isFocused: false);
                }),
            focusFocusNodes: () => setState(() {
                  _focusThisWidget(isFocused: true);
                })));

    controller?.addListener(() {
      var value = widget.tryParseDate(controller?.text);
      widget.onChanged?.call(value);
    });

    focusNode?.onKeyEvent = (node, event) { return event.handleKeysIfCallBackExistAndCallOnlyOnKeyDown(debugLabel: "Date Input Text Field")
    .chain(
        [LogicalKeyboardKey.tab], widget.touchEditCallBacks.focusPreviousField,
        withShift:
            true).chain([LogicalKeyboardKey.tab], widget.touchEditCallBacks.focusNextField).chain(
        [LogicalKeyboardKey.enter],
        () {
            if (!widget._readOnly) { 
              widget.touchEditCallBacks.focusNextField?.call();
            }
            else {
              showPicker(widget.tryParseDate(controller?.text));
            }
          }).chain(
        [LogicalKeyboardKey.escape], widget.touchEditCallBacks.cancelEdit).result();};

    datePickerIconFocusNode?.onKeyEvent = (node, event) =>
        event.handleKeysIfCallBackExistAndCallOnlyOnKeyDown(debugLabel: "Date Input Button")
        .chain(
            [LogicalKeyboardKey.tab], widget.touchEditCallBacks.focusPreviousField,
            withShift: true).chain([
          LogicalKeyboardKey.tab
        ], widget.touchEditCallBacks.focusNextField).chain(
            [LogicalKeyboardKey.escape],
            widget.touchEditCallBacks.cancelEdit).result();

    controller?.text = widget.displayBuilder(widget.value);
    _focusThisWidget(isFocused: widget.focused);
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    focusNode = FocusNode();
    datePickerIconFocusNode = FocusNode();

    _init();
  }

  @override
  void didUpdateWidget(DynamicTableDateInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
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
            //RegExp(r'^(\d{0,2}\/?){0,2}(\d{0,4}\/?){0,1}$')
            //        .hasMatch(newValue.text)
            widget.tryParseDate(newValue.text)!= null
                ? newValue
                : oldValue)
      ],
      keyboardType: TextInputType.datetime,
      decoration: widget._decoration?.copyWith(
        suffixIcon: InkWell(
          focusNode: datePickerIconFocusNode,
          child: widget._decoration?.suffixIcon ??
              const Icon(Icons.calendar_today),
          onTap: () => showPicker(widget.tryParseDate(controller?.text)),
        ),
      ),
      style: widget._style,
      strutStyle: widget._strutStyle,
      textDirection: widget._textDirection,
      textAlign: widget._textAlign,
      textAlignVertical: widget._textAlignVertical,
      mouseCursor: widget._mouseCursor,
      readOnly: widget._readOnly,
    );
  }
}
