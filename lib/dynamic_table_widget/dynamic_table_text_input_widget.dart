import 'package:dynamic_table/dynamic_table_source/dynamic_table_view.dart';
import 'package:dynamic_table/dynamic_table_widget/focusing_extension.dart';
import 'package:dynamic_table/dynamic_table_widget/key_event_handlers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicTableTextInputWidget extends StatefulWidget {
  const DynamicTableTextInputWidget({
    super.key,
    required TextInputType? keyboardType,
    required int maxLines,
    required InputDecoration? decoration,
    required TextCapitalization textCapitalization,
    required TextInputAction? textInputAction,
    required TextStyle? style,
    required StrutStyle? strutStyle,
    required TextDirection? textDirection,
    required TextAlign textAlign,
    required TextAlignVertical? textAlignVertical,
    required bool readOnly,
    required bool? showCursor,
    required String obscuringCharacter,
    required bool obscureText,
    required bool autocorrect,
    required SmartDashesType? smartDashesType,
    required SmartQuotesType? smartQuotesType,
    required bool enableSuggestions,
    required MaxLengthEnforcement? maxLengthEnforcement,
    required int? minLines,
    required bool expands,
    required int? maxLength,
    required List<TextInputFormatter>? inputFormatters,
    required bool? enabled,
    required double cursorWidth,
    required double? cursorHeight,
    required Radius? cursorRadius,
    required Color? cursorColor,
    required Brightness? keyboardAppearance,
    required EdgeInsets scrollPadding,
    required ScrollPhysics? scrollPhysics,
    required Iterable<String>? autofillHints,
    required AutovalidateMode? autovalidateMode,
    required MouseCursor? mouseCursor,
    required this.value,
    required this.onChanged,
    required this.touchEditCallBacks,
    required this.focused,
  }) : _keyboardType = keyboardType, _maxLines = maxLines, _decoration = decoration, _textCapitalization = textCapitalization, _textInputAction = textInputAction, _style = style, _strutStyle = strutStyle, _textDirection = textDirection, _textAlign = textAlign, _textAlignVertical = textAlignVertical, _readOnly = readOnly, _showCursor = showCursor, _obscuringCharacter = obscuringCharacter, _obscureText = obscureText, _autocorrect = autocorrect, _smartDashesType = smartDashesType, _smartQuotesType = smartQuotesType, _enableSuggestions = enableSuggestions, _maxLengthEnforcement = maxLengthEnforcement, _minLines = minLines, _expands = expands, _maxLength = maxLength, _inputFormatters = inputFormatters, _enabled = enabled, _cursorWidth = cursorWidth, _cursorHeight = cursorHeight, _cursorRadius = cursorRadius, _cursorColor = cursorColor, _keyboardAppearance = keyboardAppearance, _scrollPadding = scrollPadding, _scrollPhysics = scrollPhysics, _autofillHints = autofillHints, _autovalidateMode = autovalidateMode, _mouseCursor = mouseCursor;

  final TextInputType? _keyboardType;
  final int _maxLines;
  final InputDecoration? _decoration;
  final TextCapitalization _textCapitalization;
  final TextInputAction? _textInputAction;
  final TextStyle? _style;
  final StrutStyle? _strutStyle;
  final TextDirection? _textDirection;
  final TextAlign _textAlign;
  final TextAlignVertical? _textAlignVertical;
  final bool _readOnly;
  final bool? _showCursor;
  final String _obscuringCharacter;
  final bool _obscureText;
  final bool _autocorrect;
  final SmartDashesType? _smartDashesType;
  final SmartQuotesType? _smartQuotesType;
  final bool _enableSuggestions;
  final MaxLengthEnforcement? _maxLengthEnforcement;
  final int? _minLines;
  final bool _expands;
  final int? _maxLength;
  final List<TextInputFormatter>? _inputFormatters;
  final bool? _enabled;
  final double _cursorWidth;
  final double? _cursorHeight;
  final Radius? _cursorRadius;
  final Color? _cursorColor;
  final Brightness? _keyboardAppearance;
  final EdgeInsets _scrollPadding;
  final ScrollPhysics? _scrollPhysics;
  final Iterable<String>? _autofillHints;
  final AutovalidateMode? _autovalidateMode;
  final MouseCursor? _mouseCursor;
  final String? value;
  final Function(String? value, )? onChanged;
  final TouchEditCallBacks touchEditCallBacks;
  final bool focused;

  @override
  State<DynamicTableTextInputWidget> createState() => _DynamicTableTextInputWidgetState();
}

class _DynamicTableTextInputWidgetState extends State<DynamicTableTextInputWidget> {
  TextEditingController? textEditingController;
  FocusNode? focusNode;

  bool _isMultilineTextField() {
    return (widget._keyboardType == TextInputType.multiline ||
        (widget._keyboardType == null && widget._maxLines > 1));
  }

  bool _hasTextReachedMaxLinesLimit() {
    return (("\n"
                  .allMatches(textEditingController?.text ?? "")
                  .length +
              1) >=
          widget._maxLines);
  }

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    focusNode?.addListener(() {
      if ((focusNode?.hasFocus??false) && !widget.focused) {
        widget.touchEditCallBacks.focusThisEditingField?.call();
      }
    });

    focusNode?.onKeyEvent = (node, event) => event.handleKeysIfCallBackExistAndCallOnlyOnKeyDown([LogicalKeyboardKey.enter], widget.touchEditCallBacks.focusNextField, handleOnCondition: () => (_isMultilineTextField() && _hasTextReachedMaxLinesLimit()),)
    .chain([LogicalKeyboardKey.tab], widget.touchEditCallBacks.focusPreviousField, withShift: true)
    .chain([LogicalKeyboardKey.tab], widget.touchEditCallBacks.focusNextField)
    .chain([LogicalKeyboardKey.escape], widget.touchEditCallBacks.cancelEdit).result();

    focusNode?.focus(widget.focused);
    if (textEditingController?.text != widget.value) textEditingController?.text = widget.value ?? "";
  }

  @override
  void didUpdateWidget(DynamicTableTextInputWidget oldWidget){
    super.didUpdateWidget(oldWidget);
    focusNode?.focus(widget.focused);
    if (textEditingController?.text != widget.value) textEditingController?.text = widget.value ?? "";
  }

  @override
  void dispose() {
    super.dispose();
    focusNode?.unfocus();
    textEditingController?.dispose();
    focusNode?.dispose();
    textEditingController = null;
    focusNode = null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      onChanged: (value) {
        widget.onChanged?.call(value, );
      },
      controller: textEditingController,
      decoration: widget._decoration ??
          const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Enter a value",
          ),
      keyboardType: widget._keyboardType,
      textCapitalization: widget._textCapitalization,
      textInputAction: widget._textInputAction,
      style: widget._style,
      strutStyle: widget._strutStyle,
      textDirection: widget._textDirection,
      textAlign: widget._textAlign,
      textAlignVertical: widget._textAlignVertical,
      readOnly: widget._readOnly,
      showCursor: widget._showCursor,
      obscuringCharacter: widget._obscuringCharacter,
      obscureText: widget._obscureText,
      autocorrect: widget._autocorrect,
      smartDashesType: widget._smartDashesType,
      smartQuotesType: widget._smartQuotesType,
      enableSuggestions: widget._enableSuggestions,
      maxLengthEnforcement: widget._maxLengthEnforcement,
      maxLines: widget._maxLines,
      minLines: widget._minLines,
      expands: widget._expands,
      maxLength: widget._maxLength,
      // onTap: onTap,
      // onTapOutside: onTapOutside,
      // validator: validator,
      inputFormatters: [...?widget._inputFormatters,
        TextInputFormatter.withFunction((oldValue, newValue) => ("\n".allMatches(newValue.text).length+1) <= widget._maxLines ? newValue : oldValue)
      ],
      enabled: widget._enabled,
      cursorWidth: widget._cursorWidth,
      cursorHeight: widget._cursorHeight,
      cursorRadius: widget._cursorRadius,
      cursorColor: widget._cursorColor,
      keyboardAppearance: widget._keyboardAppearance,
      scrollPadding: widget._scrollPadding,
      scrollPhysics: widget._scrollPhysics,
      autofillHints: widget._autofillHints,
      autovalidateMode: widget._autovalidateMode,
      mouseCursor: widget._mouseCursor,
      onEditingComplete: () => widget.touchEditCallBacks.focusNextField?.call(),
    );
  }
}
