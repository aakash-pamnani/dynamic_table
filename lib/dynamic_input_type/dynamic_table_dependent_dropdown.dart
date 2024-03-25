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
    Color? dropdownColor,
    InputDecoration? decoration,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    BorderRadius? borderRadius,
  })  : _itemsBuilder = itemsBuilder,
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
        _dropdownColor = dropdownColor,
        _decoration = decoration,
        _menuMaxHeight = menuMaxHeight,
        _enableFeedback = enableFeedback,
        _alignment = alignment,
        _borderRadius = borderRadius,
        
        super(
        // dynamicTableInput: DynamicTableInput.dropdown,
        dependentOn: dependentOnColumn,
        ) {;
  }

  T? getFirstValue() {
    if (_dependentValue == null) {
      return null;
    }
    return _itemsBuilder(_dependentValue!).firstOrNull?.value;
  }

  bool hasSelectionValues(W dependentValue) {
    return _itemsBuilder(dependentValue).isNotEmpty;
  }

  @override
  Widget displayWidget(T? value, bool focused, TouchEditCallBacks touchEditCallBacks, ) {
    return DefaultDisplayWidget<T>(
      displayBuilder: _displayBuilder,
      value: value,
      focused: focused,
      touchEditCallBacks: touchEditCallBacks,
    );
  }

  @override
  Widget editingWidget(
      T? value,
      Function(T? value)? onChanged,
      TouchEditCallBacks touchEditCallBacks,
      bool focused) {
    return DynamicTableDependentDropdownWidget<T, W>(
        dependentValue: _dependentValue,
        itemsBuilder: _itemsBuilder,
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
        dropdownColor: _dropdownColor,
        decoration: _decoration,
        menuMaxHeight: _menuMaxHeight,
        enableFeedback: _enableFeedback,
        alignment: _alignment,
        borderRadius: _borderRadius,
        value: value,
        onChanged: onChanged,
        touchEditCallBacks: touchEditCallBacks,
        focused: focused);
  }

  final List<DropdownMenuItem<T>> Function(W dependentValue) _itemsBuilder;
  final String Function(T?)? _displayBuilder;
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
  final Color? _dropdownColor;
  final InputDecoration? _decoration;
  final double? _menuMaxHeight;
  final bool? _enableFeedback;
  final AlignmentGeometry _alignment;
  final BorderRadius? _borderRadius;

  W? _dependentValue;

  W? get dependentValue => _dependentValue;

  int get dependentOnColumn => _dependentOn!;

  bool setDefaultDependentValue(W? dependentValue) {
    if (_dependentValue == null || _dependentValue != dependentValue) {
      _dependentValue = dependentValue;
      return true;
    }
    return false;
  }

  @override
  void dispose() {}
}
