part of 'dynamic_table_input_type.dart';

class DynamicTableDateInput extends DynamicTableInputType<DateTime> {
  DynamicTableDateInput(
      {required BuildContext context,
      required DateTime initialDate,
      required DateTime lastDate,
      String Function(DateTime)? formatDate,
      InputDecoration? decoration,
      TextStyle? style,
      StrutStyle? strutStyle,
      TextDirection? textDirection,
      TextAlign textAlign = TextAlign.start,
      TextAlignVertical? textAlignVertical,
      bool autofocus = false,
      MouseCursor? mouseCursor,
      bool readOnly = true})
      : _textDirection = textDirection,
        _style = style,
        _decoration = decoration,
        _mouseCursor = mouseCursor,
        _autofocus = autofocus,
        _textAlignVertical = textAlignVertical,
        _textAlign = textAlign,
        _strutStyle = strutStyle,
        _lastDate = lastDate,
        _context = context,
        _initialDate = initialDate,
        _readOnly = readOnly,
        _displayBuilder = ((value) => (value == null ? "" : (formatDate ??
            (DateTime date) => "${date.day}/${date.month}/${date.year}").call(value)));

  final BuildContext _context;
  final DateTime _initialDate;
  final DateTime _lastDate;
  final InputDecoration? _decoration;
  final TextStyle? _style;
  final StrutStyle? _strutStyle;
  final TextDirection? _textDirection;
  final TextAlign _textAlign;
  final TextAlignVertical? _textAlignVertical;
  final bool _autofocus;
  final MouseCursor? _mouseCursor;
  final bool _readOnly;
  final String Function(DateTime?) _displayBuilder;

  @override
  Widget displayWidget(DateTime? value, bool focused, void Function(int row, int column)? onEditComplete, int row, int column) {
    return DefaultDisplayWidget<DateTime>(
      value: value,
      focused: focused,
      displayBuilder: _displayBuilder,
      onEditComplete: onEditComplete,
      row: row,
      column: column
    );
  }

  Widget editingWidget(
      DateTime? value,
      Function(DateTime? value, int row, int column)? onChanged,
      void Function(int row, int column)? onEditComplete,
      void Function(int row, int column)? focusThisField,
      int row,
      int column,
      bool focused) {
    return DynamicTableDateInputWidget(initialDate: _initialDate, lastDate: _lastDate, readOnly: _readOnly, decoration: _decoration, style: _style, strutStyle: _strutStyle, textDirection: _textDirection, textAlign: _textAlign, textAlignVertical: _textAlignVertical, mouseCursor: _mouseCursor, value: value, onChanged: onChanged, onEditComplete: onEditComplete, focusThisField: focusThisField, row: row, column: column, focused: focused, displayBuilder: _displayBuilder);
  }

  @override
  void dispose() {}
}
