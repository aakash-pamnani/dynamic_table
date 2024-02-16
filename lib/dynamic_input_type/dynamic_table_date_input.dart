part of 'dynamic_table_input_type.dart';

class DynamicTableDateInput extends DynamicTableInputType<DateTime> {
  DynamicTableDateInput(
      {required DateTime initialDate,
      required DateTime lastDate,
      DateFormat? dateFormat,
      InputDecoration? decoration,
      TextStyle? style,
      StrutStyle? strutStyle,
      TextDirection? textDirection,
      TextAlign textAlign = TextAlign.start,
      TextAlignVertical? textAlignVertical,
      MouseCursor? mouseCursor,
      bool readOnly = true})
      : _textDirection = textDirection,
        _style = style,
        _decoration = decoration,
        _mouseCursor = mouseCursor,
        _textAlignVertical = textAlignVertical,
        _textAlign = textAlign,
        _strutStyle = strutStyle,
        _lastDate = lastDate,
        _initialDate = initialDate,
        _readOnly = readOnly,
        _displayBuilder = ((date) => date==null? "":getDateFormat(dateFormat).format(date)),
        _tryParseDate = ((date) => (date==null || date.isEmpty)? null:getDateFormat(dateFormat).tryParse(date));
  
  static DateFormat getDateFormat(DateFormat? dateFormat) {
    return dateFormat?? DateFormat("dd\\MM\\yy");
  }

  final DateTime _initialDate;
  final DateTime _lastDate;
  final InputDecoration? _decoration;
  final TextStyle? _style;
  final StrutStyle? _strutStyle;
  final TextDirection? _textDirection;
  final TextAlign _textAlign;
  final TextAlignVertical? _textAlignVertical;
  final MouseCursor? _mouseCursor;
  final bool _readOnly;
  final String Function(DateTime?) _displayBuilder;
  final DateTime? Function(String?) _tryParseDate;

  @override
  Widget displayWidget(DateTime? value, bool focused, TouchEditCallBacks touchEditCallBacks) {
    return DefaultDisplayWidget<DateTime>(
      value: value,
      focused: focused,
      displayBuilder: _displayBuilder,
      touchEditCallBacks: touchEditCallBacks,
    );
  }

  Widget editingWidget(
      DateTime? value,
      Function(DateTime? value, )? onChanged,
      TouchEditCallBacks touchEditCallBacks,
      bool focused) {
    return DynamicTableDateInputWidget(initialDate: _initialDate, lastDate: _lastDate, readOnly: _readOnly, decoration: _decoration, style: _style, strutStyle: _strutStyle, textDirection: _textDirection, textAlign: _textAlign, textAlignVertical: _textAlignVertical, mouseCursor: _mouseCursor, value: value, onChanged: onChanged, touchEditCallBacks: touchEditCallBacks, focused: focused, displayBuilder: _displayBuilder, tryParseDate: _tryParseDate,);
  }

  @override
  void dispose() {}
}
