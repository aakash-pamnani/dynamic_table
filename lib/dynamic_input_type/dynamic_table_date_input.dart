part of 'dynamic_table_input_type.dart';

class DynamicTableDateInput extends DynamicTableInputType<DateTime> {
  DynamicTableDateInput({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime lastDate,
    this.formatDate,
    InputDecoration? decoration,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    MouseCursor? mouseCursor,
    bool readOnly = true
  })  : _textDirection = textDirection,
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
        _readOnly = readOnly {
    formatDate = formatDate ??
        (DateTime date) => "${date.day}/${date.month}/${date.year}";
  }
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

  String Function(DateTime)? formatDate = (DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  };

  Future<DateTime> _showPicker(DateTime selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: _context,
      initialDate: selectedDate,
      firstDate: _initialDate,
      lastDate: _lastDate,
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
    }
    return selectedDate;
  }

  @override
  Widget displayWidget(DateTime? value) {
    return Text(value == null ? "" : formatDate!(value));
  }

  TextEditingController? controller;
  FocusNode focusNode = FocusNode();
  @override
  Widget editingWidget(
      DateTime? value,
      Function(DateTime? value, int row, int column)? onChanged,
      void Function(int row, int column)? onEditComplete,
      int row,
      int column) {
    controller =
        TextEditingController(text: value == null ? "" : formatDate!(value));

    focusNode.onKeyEvent = (node, event) {
      if (onEditComplete != null &&
          (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.tab)) if (event
          is KeyDownEvent) {
        onEditComplete.call(row, column);
        return KeyEventResult.handled;
      } else
        return KeyEventResult.handled;
      return KeyEventResult.ignored;
    };

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      inputFormatters: [TextInputFormatter.withFunction((oldValue, newValue) => RegExp(r'^(\d{0,2}\/?){0,2}(\d{0,4}\/?){0,1}$').hasMatch(newValue.text) ? newValue : oldValue)],
      keyboardType: TextInputType.datetime,
      decoration: _decoration?.copyWith(
        suffixIcon: InkWell(
          child: _decoration?.suffixIcon ?? const Icon(Icons.calendar_today),
          onTap: () {
            _showPicker(value ?? DateTime.now()).then((value) {
              onChanged?.call(value, row, column);
              onEditComplete?.call(row, column);
              controller?.text = formatDate!(value);
            });
          },
        ),
      ),
      style: _style,
      strutStyle: _strutStyle,
      textDirection: _textDirection,
      textAlign: _textAlign,
      textAlignVertical: _textAlignVertical,
      autofocus: _autofocus,
      mouseCursor: _mouseCursor,
      readOnly: _readOnly,
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
  }
}
