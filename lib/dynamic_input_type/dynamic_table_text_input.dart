part of 'dynamic_table_input_type.dart';

class DynamicTableTextInput extends DynamicTableInputType<String> {
  DynamicTableTextInput({
    InputDecoration? decoration,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    // this.validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    MouseCursor? mouseCursor,
  })  : _mouseCursor = mouseCursor,
        _autovalidateMode = autovalidateMode,
        _autofillHints = autofillHints,
        _scrollPhysics = scrollPhysics,
        _scrollPadding = scrollPadding,
        _keyboardAppearance = keyboardAppearance,
        _cursorColor = cursorColor,
        _cursorHeight = cursorHeight,
        _cursorRadius = cursorRadius,
        _cursorWidth = cursorWidth,
        _enabled = enabled,
        _inputFormatters = inputFormatters,
        _maxLength = maxLength,
        _expands = expands,
        _minLines = minLines,
        _maxLines = maxLines,
        _maxLengthEnforcement = maxLengthEnforcement,
        _enableSuggestions = enableSuggestions,
        _smartQuotesType = smartQuotesType,
        _smartDashesType = smartDashesType,
        _autocorrect = autocorrect,
        _obscureText = obscureText,
        _obscuringCharacter = obscuringCharacter,
        _showCursor = showCursor,
        _readOnly = readOnly,
        _autofocus = autofocus,
        _textAlignVertical = textAlignVertical,
        _textAlign = textAlign,
        _textDirection = textDirection,
        _strutStyle = strutStyle,
        _style = style,
        _textInputAction = textInputAction,
        _textCapitalization = textCapitalization,
        _decoration = decoration,
        _keyboardType = keyboardType,
        super(
        // dynamicTableInput: DynamicTableInput.text,
        );

  final InputDecoration? _decoration;
  final TextInputType? _keyboardType;
  final TextCapitalization _textCapitalization;
  final TextInputAction? _textInputAction;
  final TextStyle? _style;
  final StrutStyle? _strutStyle;
  final TextDirection? _textDirection;
  final TextAlign _textAlign;
  final TextAlignVertical? _textAlignVertical;
  final bool _autofocus;
  final bool _readOnly;
  final bool? _showCursor;
  final String _obscuringCharacter;
  final bool _obscureText;
  final bool _autocorrect;
  final SmartDashesType? _smartDashesType;
  final SmartQuotesType? _smartQuotesType;
  final bool _enableSuggestions;
  final MaxLengthEnforcement? _maxLengthEnforcement;
  final int _maxLines;
  final int? _minLines;
  final bool _expands;
  final int? _maxLength;
  // final void Function()? onTap;
  // final void Function(PointerDownEvent)? onTapOutside;
  // final String? Function(String?)? validator;
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

  @override
  Widget displayWidget(String? value) {
    return Text(value ?? "");
  }

  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget editingWidget(
      String? value,
      Function(String? value, int row, int column)? onChanged,
      void Function(int row, int column)? onEditComplete,
      int row,
      int column) {
    textEditingController.text = value ?? "";
    if (_keyboardType == TextInputType.multiline ||
        (_keyboardType == null && _maxLines > 1))
      focusNode.onKeyEvent = (node, event) {
        if (onEditComplete != null &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.tab)) if ((event
                    .logicalKey !=
                LogicalKeyboardKey.enter) ||
            (("\n".allMatches(textEditingController.text).length + 1) >=
                _maxLines)) if (event is KeyDownEvent) {
          onEditComplete.call(row, column);
          return KeyEventResult.handled;
        } else
          return KeyEventResult.handled;
        return KeyEventResult.ignored;
      };
    return TextFormField(
      focusNode: focusNode,
      onChanged: (value) {
        onChanged?.call(value, row, column);
      },
      controller: textEditingController,
      decoration: _decoration ??
          const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Enter a value",
          ),
      keyboardType: _keyboardType,
      textCapitalization: _textCapitalization,
      textInputAction: _textInputAction,
      style: _style,
      strutStyle: _strutStyle,
      textDirection: _textDirection,
      textAlign: _textAlign,
      textAlignVertical: _textAlignVertical,
      autofocus: _autofocus,
      readOnly: _readOnly,
      showCursor: _showCursor,
      obscuringCharacter: _obscuringCharacter,
      obscureText: _obscureText,
      autocorrect: _autocorrect,
      smartDashesType: _smartDashesType,
      smartQuotesType: _smartQuotesType,
      enableSuggestions: _enableSuggestions,
      maxLengthEnforcement: _maxLengthEnforcement,
      maxLines: _maxLines,
      minLines: _minLines,
      expands: _expands,
      maxLength: _maxLength,
      // onTap: onTap,
      // onTapOutside: onTapOutside,
      // validator: validator,
      inputFormatters: [...?_inputFormatters,
        TextInputFormatter.withFunction((oldValue, newValue) => ("\n".allMatches(newValue.text).length+1) <= _maxLines ? newValue : oldValue)
      ],
      enabled: _enabled,
      cursorWidth: _cursorWidth,
      cursorHeight: _cursorHeight,
      cursorRadius: _cursorRadius,
      cursorColor: _cursorColor,
      keyboardAppearance: _keyboardAppearance,
      scrollPadding: _scrollPadding,
      scrollPhysics: _scrollPhysics,
      autofillHints: _autofillHints,
      autovalidateMode: _autovalidateMode,
      mouseCursor: _mouseCursor,
      onEditingComplete: () => onEditComplete?.call(row, column),
    );
  }

  @override
  void dispose() {}
}
