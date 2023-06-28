part of 'dynamic_input_type.dart';

class DynamicTableDropDownInput<T> extends DynamicTableInputType<T> {
  DynamicTableDropDownInput({
    required items,
    required String Function(T?) displayBuilder,
    required DropdownMenuItem<T> Function(T value) itemBuilder,
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
  })  : _displayBuilder = displayBuilder,
        _itemBuilder = itemBuilder,
        _items = items,
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
        );
  @override
  Widget displayWidget(T? value) {
    assert(_items.contains(value), "Value $value not found in items $_items");
    return Text(_displayBuilder(value));
  }

  final String Function(T?) _displayBuilder;
  final List<T> _items;
  final DropdownMenuItem<T> Function(T value) _itemBuilder;
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

  @override
  Widget editingWidget(T? value,
      Function(T value, int row, int column)? onChanged, int row, int column) {
    if (value != null) {
      assert(_items.contains(value), "Value $value not found in items $_items");
    }
    editingValue = value ?? _items.first;

    return DropdownButtonFormField<T>(
      value: value ?? _items.first,
      onChanged: (value) {
        onChanged?.call(value as T, row, column);
        editingValue = value;
      },
      items: _items.map<DropdownMenuItem<T>>((e) => _itemBuilder(e)).toList(),
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
