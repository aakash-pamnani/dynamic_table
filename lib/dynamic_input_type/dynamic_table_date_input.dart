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
        _initialDate = initialDate {
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
  @override
  Widget editingWidget(
      DateTime? value,
      Function(DateTime? value, int row, int column)? onChanged,
      int row,
      int column) {
    controller =
        TextEditingController(text: value == null ? "" : formatDate!(value));

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.none,
      decoration: _decoration?.copyWith(
        suffixIcon: InkWell(
          child: _decoration?.suffixIcon ?? const Icon(Icons.calendar_today),
          onTap: () {
            _showPicker(value ?? DateTime.now()).then((value) {
              onChanged?.call(value, row, column);
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
      readOnly: true,
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    controller = null;
  }
}
