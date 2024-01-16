import 'package:dynamic_table/dynamic_table_source/dynamic_table_columns_query.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_editables.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_editing_values.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_shiftable_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_view.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';
import 'package:dynamic_table/dynamic_table_source/sort_order.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_column.dart';

abstract class DynamicTableSourceQuery {
  int getDataLength();
  DynamicTableColumnsQuery getColumnsQuery();
  bool isDropdownColumnAndHasNoDropdownValues(
      Reference<int> row, int columnIndex);
}

abstract class DynamicTableEditablesConfig {
  bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)?
      get onRowEdit;
  bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)?
      get onRowDelete;
  List<Comparable<dynamic>?>? Function(
      Comparable<dynamic>? key,
      List<Comparable<dynamic>?> oldValue,
      List<Comparable<dynamic>?> newValue)? get onRowSave;
  bool get editOneByOne;
  bool get autoSaveRowsEnabled;
}

abstract class DynamicTableViewConfig {
  String get actionColumnTitle;
  bool get showActions;
  bool get showDeleteAction;
  bool get showDeleteOrCancelAction;
  bool get touchMode;
  bool get selectable;
}

class DynamicTableSource extends DataTableSource
    with DynamicTableEditables, DynamicTableFocus, DynamicTableView
    implements DynamicTableSourceQuery, DynamicTableEditablesConfig, DynamicTableViewConfig {
  String actionColumnTitle;
  bool showActions;
  bool showDeleteAction;
  bool showDeleteOrCancelAction;
  bool touchMode;
  bool selectable;

  bool editOneByOne;
  bool autoSaveRowsEnabled;
  bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)?
      onRowEdit;
  bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)?
      onRowDelete;
  List<Comparable<dynamic>?>? Function(
      Comparable<dynamic>? key,
      List<Comparable<dynamic>?> oldValue,
      List<Comparable<dynamic>?> newValue)? onRowSave;

  final void Function(int rowIndex) pageTo;
  final void Function() triggerTableStateUpdate;

  final DynamicTableColumnsQuery _columnsQuery;
  late DynamicTableShiftableData _data;
  final DynamicTableEditingValues _editingValues;
  DynamicTableFocusData? _focus;

  void updateConfig({
    String? actionColumnTitle,
    bool? showActions,
    bool? showDeleteAction,
    bool? showDeleteOrCancelAction,
    bool? touchMode,
    bool? selectable,

    bool? editOneByOne,
    bool? autoSaveRowsEnabled,
    bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)?
        onRowEdit,
    bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)?
        onRowDelete,
    List<Comparable<dynamic>?>? Function(
            Comparable<dynamic>? key,
            List<Comparable<dynamic>?> oldValue,
            List<Comparable<dynamic>?> newValue)?
        onRowSave,
  }) {
    if (actionColumnTitle != null) this.actionColumnTitle = actionColumnTitle;
    if (showActions != null) this.showActions = showActions;
    if (showDeleteAction != null) this.showDeleteAction = showDeleteAction;
    if (showDeleteOrCancelAction != null) {
      this.showDeleteOrCancelAction = showDeleteOrCancelAction;
    }
    if (touchMode != null) this.touchMode = touchMode;
    if (selectable != null) this.selectable = selectable;
    if (editOneByOne != null) this.editOneByOne = editOneByOne;
    if (autoSaveRowsEnabled != null) {
      this.autoSaveRowsEnabled = autoSaveRowsEnabled;
    }
    if (onRowEdit != null) this.onRowEdit = onRowEdit;
    if (onRowDelete != null) this.onRowDelete = onRowDelete;
    if (onRowSave != null) this.onRowSave = onRowSave;
    notifyListeners();
  }

  DynamicTableSource({
    required Map<Comparable<dynamic>, List<Comparable<dynamic>?>> data,
    required List<DynamicTableDataColumn> columns,
    required this.actionColumnTitle,
    this.showActions = false,
    this.showDeleteAction = false,
    this.showDeleteOrCancelAction = true,
    this.touchMode = true,
    this.selectable = true,
    this.editOneByOne = true,
    this.autoSaveRowsEnabled = true,
    this.onRowEdit,
    this.onRowDelete,
    this.onRowSave,
    required this.pageTo,
    required this.triggerTableStateUpdate
  })  : _columnsQuery = DynamicTableColumnsQuery(columns),
        _editingValues = DynamicTableEditingValues(
            columnsQuery: DynamicTableColumnsQuery(columns)) {
    _data = DynamicTableShiftableData(data,
        onShift: _onShift, columnsQuery: _columnsQuery);
  }

  @override
  DynamicTableColumnsQuery getColumnsQuery() => _columnsQuery;

  @override
  DynamicTableFocusData? getRawFocus() => _focus;

  @override
  DynamicTableEditingValues getEditingValues() => _editingValues;

  @override
  DynamicTableShiftableData getData() => _data;

  @override
  int getDataLength() {
    return getData().getDataLength();
  }

  SortOrder get sortOrder => getData().sortOrder;
  int get sortColumnIndex => getData().sortByColumnIndex;

  void _onShift(Map<int, int> shiftData) {
    shiftEditingValues(shiftData);
    _focus = shiftFocus(_focus, shiftData);
    shiftViewCache(shiftData);
    pageTo(getFocus().row);
  }

  @override
  void updateFocus(DynamicTableFocusData? focus) {
    _focus = focus != null? DynamicTableFocusData(row: focus.row, column: focus.column, previous: _focus): null;
    unfocusPreviousFocusNodes();
    notifyListeners();
    pageTo(getFocus().row);
  }

  @override
  void insertRow(Reference<int> index,
      {List<Comparable<dynamic>?>? values, bool isEditing = false}) {
    super.insertRow(index, values: values, isEditing: isEditing);
    notifyListeners();
    focusThisRow(index);
  }

  @override
  void deleteRow(Reference<int> index) {
    super.deleteRow(index);
    notifyListeners();
  }

  @override
  void cancelRow(Reference<int> row) {
    super.cancelRow(row);
    notifyListeners();
  }

  @override
  void editRow(Reference<int> row) {
    super.editRow(row);
    notifyListeners();
  }

  @override
  void updateRow(Reference<int> index, List<Comparable<dynamic>?> values) {
    super.updateRow(index, values);
    notifyListeners();
  }

  @override
  void selectRow(Reference<int> index, {required bool isSelected}) {
    super.selectRow(index, isSelected: isSelected);
    notifyListeners();
  }

  @override
  void setEditingValue(
      Reference<int> row, int column, Comparable<dynamic>? value) {
    super.setEditingValue(row, column, value);
    notifyListeners();
  }

  @override
  void updateSortByColumnIndex(int sortByColumnIndex) {
    super.updateSortByColumnIndex(sortByColumnIndex);
    notifyListeners();
    triggerTableStateUpdate();
  }

  @override
  bool isDropdownColumnAndHasNoDropdownValues(
      Reference<int> row, int columnIndex) {
    return getEditingValues()
        .isDropdownColumnAndHasNoDropdownValues(row, columnIndex);
  }

  @override
  bool isColumnEditableAndIfDropdownColumnThenHasDropdownValues(
      Reference<int> row, int columnIndex) {
    return _columnsQuery.isColumnEditable(columnIndex) &&
        getEditingValues()
            .ifDropdownColumnThenHasDropdownValues(row, columnIndex);
  }

  @override
  DataRow? getRow(int index) {
    return buildRow(Reference<int>(value: index));
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => getDataLength();

  @override
  int get selectedRowCount => getData().getSelectedRowsCount();

}
