import 'dart:async';

import 'package:dynamic_table/dynamic_table_source/dynamic_table_view.dart';
import 'package:dynamic_table/dynamic_table_widget/completion.dart';
import 'package:dynamic_table/dynamic_table_widget/focusing_extension.dart';
import 'package:dynamic_table/dynamic_table_widget/key_event_handlers.dart';
import 'package:dynamic_table/dynamic_table_widget/logging.dart';
import 'package:dynamic_table/utils/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show DateFormat;

typedef DatePart = (int, int, int);

extension Equality on DatePart {
  bool equals(DatePart? other) {
    if (other == null) return false;
    return this.$1 == other.$1 && this.$2 == other.$2 && this.$3 == other.$3;
  }

  bool partEquals(DatePart? other) {
    if (other == null) return false;
    return this.$1 == other.$1;
  }
}

class InputDateParts {
  InputDateParts(
      {this.parts,
      this.partOneStart,
      this.partOneEnd,
      this.partTwoStart,
      this.partTwoEnd,
      this.partThreeStart,
      this.partThreeEnd});

  factory InputDateParts.fromText(String text, String separator) {
    final parts = text.split(separator);
    final partOneStart = 0;
    final partOneEnd = text.indexOf(separator);
    final partTwoStart = partOneEnd + 1;
    final partTwoEnd = text.lastIndexOf(separator);
    final partThreeStart = partTwoEnd + 1;
    final partThreeEnd = text.length;
    return InputDateParts(
        parts: parts,
        partOneStart: partOneStart,
        partOneEnd: partOneEnd,
        partTwoStart: partTwoStart,
        partTwoEnd: partTwoEnd,
        partThreeStart: partThreeStart,
        partThreeEnd: partThreeEnd);
  }

  final parts;
  final partOneStart;
  final partOneEnd;
  final partTwoStart;
  final partTwoEnd;
  final partThreeStart;
  final partThreeEnd;

  DatePart get partOne => (1, partOneStart, partOneEnd);
  DatePart get partTwo => (2, partTwoStart, partTwoEnd);
  DatePart get partThree => (3, partThreeStart, partThreeEnd);
}

class InputDateFormat {
  const InputDateFormat(
      {this.separator = '/',
      this.date = 'dd',
      this.month = 'MM',
      this.year = 'yyyy'});

  final String separator;
  final String date;
  final String month;
  final String year;

  String buildDisplay(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat(date + separator + month + separator + year)
        .format(dateTime);
  }

  DateTime? tryParseDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return null;
    return DateFormat(date + separator + month + separator + year)
        .tryParse(dateTime);
  }

  InputDateParts getParts(String text) {
    return InputDateParts.fromText(text, separator);
  }

  DatePart? getApproachedPart(
      TextEditingValue oldText, TextEditingValue newText) {
    if (!(getSelection(oldText)?.partEquals(getSelection(newText)) ?? false))
      return null;
    if ((newText.selection.start != newText.selection.end)) return null;

    final oldSelection = getSelection(oldText);
    final oldParts = getParts(oldText.text);
    if ((oldSelection?.partEquals(oldParts.partOne) ?? false) &&
        !(oldSelection?.equals(oldParts.partOne) ?? false)) return null;
    if ((oldSelection?.partEquals(oldParts.partTwo) ?? false) &&
        !(oldSelection?.equals(oldParts.partTwo) ?? false)) return null;
    if ((oldSelection?.partEquals(oldParts.partThree) ?? false) &&
        !(oldSelection?.equals(oldParts.partThree) ?? false)) return null;

    final parts = getParts(newText.text);
    if (newText.selection.start == parts.partOneEnd) {
      return parts.partTwo;
    }
    if (newText.selection.start == parts.partTwoStart) {
      return parts.partOne;
    }
    if (newText.selection.start == parts.partTwoEnd) {
      return parts.partThree;
    }
    if (newText.selection.start == parts.partThreeStart) {
      return parts.partTwo;
    }

    return null;
  }

  DatePart? getSelection(TextEditingValue text) {
    final parts = getParts(text.text);
    if (parts.parts[0].isNotEmpty &&
        (parts.partOneStart <= text.selection.start &&
            parts.partOneEnd >= text.selection.end)) {
      return (1, text.selection.start, text.selection.end);
    }
    if (parts.parts[1].isNotEmpty &&
        (parts.partTwoStart <= text.selection.start &&
            parts.partTwoEnd >= text.selection.end)) {
      return (2, text.selection.start, text.selection.end);
    }
    if (parts.parts[2].isNotEmpty &&
        (parts.partThreeStart <= text.selection.start &&
            parts.partThreeEnd >= text.selection.end)) {
      return (3, text.selection.start, text.selection.end);
    }
    return null;
  }

  DatePart? getSelectedPart(TextEditingValue text) {
    final parts = getParts(text.text);
    final selection = getSelection(text);
    if (parts.partOne.partEquals(selection)) return parts.partOne;
    if (parts.partTwo.partEquals(selection)) return parts.partTwo;
    if (parts.partThree.partEquals(selection)) return parts.partThree;
    return null;
  }

  bool validateIncrementally(String? dateTime) {
    if (dateTime == null) return false;
    var dateParts = dateTime.split(separator);
    if (dateParts.length != 3) return false;
    if (!dateParts.every(
        (element) => (element.isEmpty || int.tryParse(element) != null))) {
      return false;
    }
    var intDateParts = [
      int.tryParse(dateParts[0]),
      int.tryParse(dateParts[1]),
      int.tryParse(dateParts[2])
    ];
    if (!(dateParts[0].isEmpty ||
        (intDateParts[0]?.isWithinInclusiveRange(0, 31) ?? false))) {
      return false;
    }
    if (!(dateParts[1].isEmpty ||
        (intDateParts[1]?.isWithinInclusiveRange(0, 12) ?? false))) {
      return false;
    }
    if (!(dateParts[2].isEmpty ||
        (intDateParts[2]?.isWithinInclusiveRange(0, 9999) ?? false))) {
      return false;
    }
    return true;
  }
}

extension RangeCheck on int {
  bool isWithinInclusiveRange(int start, int end) {
    return start <= this && this <= end;
  }
}

//TODO: remove previous listeners in _init()
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
      required this.inputDateFormat})
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
  final InputDateFormat inputDateFormat;

  @override
  State<DynamicTableDateInputWidget> createState() =>
      _DynamicTableDateInputWidgetState();
}

class _DynamicTableDateInputWidgetState
    extends State<DynamicTableDateInputWidget> {
  TextEditingController? controller;
  FocusNode? focusNode;
  FocusNode? datePickerIconFocusNode;
  DateTime? previousDate;
  TextEditingValue? previousValue;

  Future<ActionCompletionResult<DateTime>> _showPicker(
      DateTime selectedDate) async {
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
    await _showPicker(selectedDate ?? DateTime.now())
        .then<ActionCompletionResult<DateTime>>((value) {
      if (value.status == ActionCompletion.Edited) {
        controller?.text = widget.inputDateFormat
            .buildDisplay(value.data.editedValue?.editedValue);
        widget.onChanged?.call(value.data.editedValue?.editedValue);
      }
      if (value.status == ActionCompletion.Edited ||
          value.status == ActionCompletion.Completed) {
        widget.touchEditCallBacks.focusNextField?.call();
      }
      return value;
    });
  }

  void _focusThisWidget({required bool isFocused}) {
    if (!widget._readOnly) {
      focusNode?.focus(isFocused);
      [LoggingWidget.loggingFocus]
          .info(() => 'DateInput: focusing date input text input control.');
    } else {
      [LoggingWidget.loggingFocus]
          .info(() => 'DateInput: focusing date input calender icon.');
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
      if ((!widget._readOnly) &&
          previousValue != null &&
          controller?.value != null) {
        final oldValue = previousValue!;
        final newValue = (controller?.value)!;
        print("selection changed: " +
            ((controller?.value.selection.toString()) ?? "<<empty>>"));
        if (oldValue.text.isNotEmpty && newValue.text.isNotEmpty) {

          final oldSelectedPart =
              widget.inputDateFormat.getSelectedPart(oldValue);
          final newSelectedPart =
              widget.inputDateFormat.getSelectedPart(newValue);
          if (oldSelectedPart != null &&
              newSelectedPart != null &&
              oldSelectedPart.$1 != newSelectedPart.$1) {
            controller?.value = newValue.copyWith(
                selection: TextSelection(
                    baseOffset: newSelectedPart.$2,
                    extentOffset: newSelectedPart.$3));
          }

          final approachedPart =
              widget.inputDateFormat.getApproachedPart(oldValue, newValue);
          if (approachedPart != null) {
            controller?.value = newValue.copyWith(
                selection: TextSelection(
                    baseOffset: approachedPart.$2,
                    extentOffset: approachedPart.$3));
          }
        }
      }
      previousValue = controller?.value;
    });

    focusNode?.addListener(() {
      if (!widget._readOnly && (focusNode?.hasFocus ?? false)) {
        previousDate = widget.inputDateFormat.tryParseDate(controller?.text);
        final newValue = (controller?.value)!;
        print("initial selection: " +
            ((controller?.value.selection.toString()) ?? "<<empty>>"));
        final parts = widget.inputDateFormat.getParts(newValue.text);
        controller?.value = newValue.copyWith(
            selection: TextSelection(
                baseOffset: parts.partOneStart,
                extentOffset: parts.partOneEnd));
      }
    });

    focusNode?.addListener(() {
      if (!widget._readOnly && !(focusNode?.hasFocus ?? false)) {
        var value = widget.inputDateFormat.tryParseDate(controller?.text);
        if (value != null &&
            (value.isAtSameMomentAs(widget._initialDate) ||
                value.isAfter(widget._initialDate)) &&
            (value.isAtSameMomentAs(widget._lastDate) ||
                value.isBefore(widget._lastDate))) {
          print("value changed: " + ((controller?.text) ?? "<<empty>>"));
          widget.onChanged?.call(value);
          controller?.text = widget.inputDateFormat.buildDisplay(value);
        } else {
          controller?.text = widget.inputDateFormat.buildDisplay(previousDate);
        }
      }
    });

    focusNode?.onKeyEvent = (node, event) {
      return event
          .handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
              debugLabel: "Date Input Text Field")
          .chain([
        LogicalKeyboardKey.tab
      ], widget.touchEditCallBacks.focusPreviousField, withShift: true).chain(
              [LogicalKeyboardKey.tab],
              widget.touchEditCallBacks
                  .focusNextField).chain([LogicalKeyboardKey.enter], () {
        if (!widget._readOnly) {
          widget.touchEditCallBacks.focusNextField?.call();
        } else {
          showPicker(widget.inputDateFormat.tryParseDate(controller?.text));
        }
      }).chain([LogicalKeyboardKey.escape],
              widget.touchEditCallBacks.cancelEdit).result();
    };

    datePickerIconFocusNode?.onKeyEvent = (node, event) => event
            .handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
                debugLabel: "Date Input Button")
            .chain([LogicalKeyboardKey.tab], widget.touchEditCallBacks.focusPreviousField,
                withShift: true).chain([
          LogicalKeyboardKey.tab
        ], widget.touchEditCallBacks.focusNextField).chain(
                [LogicalKeyboardKey.escape],
                widget.touchEditCallBacks.cancelEdit).result();

    controller?.text = widget.inputDateFormat.buildDisplay(widget.value);
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
        TextInputFormatter.withFunction((oldValue, newValue) {
          //RegExp(r'^(\d{0,2}\/?){0,2}(\d{0,4}\/?){0,1}$')
          //        .hasMatch(newValue.text)
          if (!widget._readOnly) {
            print('formatting: ' + newValue.text);
            return widget.inputDateFormat.validateIncrementally(newValue.text)
                ? newValue
                : oldValue;
          }
          return newValue;
        })
      ],
      keyboardType: TextInputType.datetime,
      decoration: widget._decoration?.copyWith(
        suffixIcon: InkWell(
          focusNode: datePickerIconFocusNode,
          child: widget._decoration?.suffixIcon ??
              const Icon(Icons.calendar_today),
          onTap: () =>
              showPicker(widget.inputDateFormat.tryParseDate(controller?.text)),
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
