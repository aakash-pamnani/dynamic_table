part of 'dynamic_table_input_type.dart';

class DynamicTableDependentDropDownInput<T extends Object, W extends Object>
    extends DynamicTableInputType<T> {
  DynamicTableDependentDropDownInput({
    required List<DropdownMenuItem<T>> Function(W dependentValue) itemsBuilder,
    required int dependentOnColumn,

    /// The value to display when the row is not editing.
    String Function(T? value)? displayBuilder,
    List<Widget> Function(BuildContext)? selectedItemBuilder,
    Widget? hint,
    Widget? disabledHint,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? dropdownColor,
    InputDecoration? decoration,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    BorderRadius? borderRadius,
  })  : _itemsBuilder = itemsBuilder,
        _dependentOnColumn = dependentOnColumn,
        _displayBuilder = displayBuilder,
        _selectedItemBuilder = selectedItemBuilder,
        _hint = hint,
        _disabledHint = disabledHint,
        _elevation = elevation,
        _style = style,
        _icon = icon,
        _iconDisabledColor = iconDisabledColor,
        _iconEnabledColor = iconEnabledColor,
        _iconSize = iconSize,
        _isDense = isDense,
        _isExpanded = isExpanded,
        _itemHeight = itemHeight,
        _focusColor = focusColor,
        _focusNode = focusNode,
        _autofocus = autofocus,
        _dropdownColor = dropdownColor,
        _decoration = decoration,
        _menuMaxHeight = menuMaxHeight,
        _enableFeedback = enableFeedback,
        _alignment = alignment,
        _borderRadius = borderRadius,
        super(
        // dynamicTableInput: DynamicTableInput.dropdown,
        ) {
    dependentOn = _dependentOnColumn;
  }
  @override
  Widget displayWidget(T? value) {
    return Text((_displayBuilder ?? _defaultDisplayBuilder).call(value));
  }

  final String Function(T?)? _displayBuilder;
  final List<DropdownMenuItem<T>> Function(W dependentValue) _itemsBuilder;
  final List<Widget> Function(BuildContext)? _selectedItemBuilder;
  final Widget? _hint;
  final Widget? _disabledHint;
  final int _elevation;
  final TextStyle? _style;
  final Widget? _icon;
  final Color? _iconDisabledColor;
  final Color? _iconEnabledColor;
  final double _iconSize;
  final bool _isDense;
  final bool _isExpanded;
  final double? _itemHeight;
  final Color? _focusColor;
  final FocusNode? _focusNode;
  final bool _autofocus;
  final Color? _dropdownColor;
  final InputDecoration? _decoration;
  final double? _menuMaxHeight;
  final bool? _enableFeedback;
  final AlignmentGeometry _alignment;
  final BorderRadius? _borderRadius;

  W? dependentValue;
  int _dependentOnColumn;
  List<DropdownMenuItem<T>> _items = [];

  int get dependentOnColumn => _dependentOnColumn;

  String _defaultDisplayBuilder(T? value) {
    return value.toString();
  }

  @override
  Widget editingWidget(T? value,
      Function(T value, int row, int column)? onChanged, int row, int column) {
    assert(
      _items.isEmpty ||
          value == null ||
          _items.where((DropdownMenuItem<T> item) {
                return item.value == value;
              }).length ==
              1,
      "There should be exactly one item with [DropdownButton]'s value: "
      '$value. \n'
      'Either zero or 2 or more [DropdownMenuItem]s were detected '
      'with the same value',
    );
    _items =
        dependentValue == null ? [] : _itemsBuilder(dependentValue!).toList();
    // ?? _items.first.value;

    return DropdownButtonFormField<T>(
      value: value,
      onChanged: (value) {
        onChanged?.call(value as T, row, column);
      },
      items: _items,
      selectedItemBuilder: _selectedItemBuilder,
      hint: _hint,
      disabledHint: _disabledHint,
      elevation: _elevation,
      style: _style,
      icon: _icon,
      iconDisabledColor: _iconDisabledColor,
      iconEnabledColor: _iconEnabledColor,
      iconSize: _iconSize,
      isDense: _isDense,
      isExpanded: _isExpanded,
      itemHeight: _itemHeight,
      focusColor: _focusColor,
      focusNode: _focusNode,
      autofocus: _autofocus,
      dropdownColor: _dropdownColor,
      decoration: _decoration,
      menuMaxHeight: _menuMaxHeight,
      enableFeedback: _enableFeedback,
      alignment: _alignment,
      borderRadius: _borderRadius,
    );
  }

  @override
  void dispose() {}
}
