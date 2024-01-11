import 'package:dynamic_table/dynamic_table_source/dynamic_table_editables.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_editing_values.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_shiftable_data.dart';
import 'package:dynamic_table/dynamic_table_source/shifting_map.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_table/dynamic_input_type/dynamic_table_input_type.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_action.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_cell.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_column.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_row.dart';

abstract class DynamicTableSourceView {
  int getDataLength();
  int getColumnsLength();
  bool isColumnEditable(int column);
}

abstract class DynamicTableSourceConfig {
  bool Function(int index, List<dynamic> row)? get onRowEdit;
  bool Function(int index, bool isEditing)? get onRowAdd;
  bool Function(int index, List<dynamic> row)? get onRowDelete;
  List<dynamic>? Function(
      int index, List<dynamic> oldValue, List<dynamic> newValue)? get onRowSave;
  bool get selectable;
  bool get editOneByOne;
  bool get autoSaveRowsEnabled;
}

class DynamicTableSource extends DataTableSource
    with DynamicTableFocus, DynamicTableEditables
    implements DynamicTableSourceView, DynamicTableSourceConfig {
  final String actionColumnTitle;
  final bool showActions;
  final bool showDeleteAction;
  final bool showDeleteOrCancelAction;
  final bool touchMode;
  final bool selectable;
  final bool editOneByOne;
  final bool autoSaveRowsEnabled;
  final bool Function(int index, List<dynamic> row)? onRowEdit;
  final bool Function(int index, bool isEditing)? onRowAdd;
  final bool Function(int index, List<dynamic> row)? onRowDelete;
  final List<dynamic>? Function(
      int index, List<dynamic> oldValue, List<dynamic> newValue)? onRowSave;

  final List<DynamicTableDataColumn> columns;
  late DynamicTableShiftableData _data;
  late DynamicTableEditingValues _editingValues;

  DynamicTableFocusData? _focus;

  DynamicTableSource({
    required this.actionColumnTitle,
    required List<DynamicTableDataRow> data,
    required this.columns,
    this.showActions = false,
    this.showDeleteAction = false,
    this.showDeleteOrCancelAction = true,
    this.touchMode = true,
    this.selectable = true,
    this.editOneByOne = true,
    this.autoSaveRowsEnabled = true,
    this.onRowEdit,
    this.onRowAdd,
    this.onRowDelete,
    this.onRowSave,
    DynamicTableSource? lastSource,
  }) {
    this._focus = lastSource?._focus;

    _data = DynamicTableShiftableData(data, onShift: onShift);
    _editingValues = DynamicTableEditingValues(columns: columns);

    /*lastSource?._unsavedRows.sort((a, b) => a.compareTo(b));
    for (int row in lastSource?._unsavedRows??[]) {
      _insertRow(row, lastSource?._editingValues[row]??List.filled(columns.length, null), isEditing: false);
    }*/
  }

  @override
  DynamicTableFocusData? getRawFocus() => _focus;

  @override
  void updateFocus(DynamicTableFocusData? focus) {
    _focus = focus;
    notifyListeners();
  }

  @override
  int getDataLength() {
    return getData().getDataLength();
  }

  @override
  int getColumnsLength() {
    return columns.length;
  }

  @override
  bool isColumnEditable(int column) {
    return columns[column].isEditable;
  }

  @override
  DynamicTableShiftableData getData() => _data;

  @override
  DynamicTableEditingValues getEditingValues() => _editingValues;

  @override
  void unmarkFromEditing(int row) {
    super.unmarkFromEditing(row);
  }

  @override
  void insertRow(int index, {List<dynamic>? values, bool isEditing = false}) {
    super.insertRow(index, values: values, isEditing: isEditing);
    notifyListeners();
  }

  @override
  void deleteRow(int index) {
    super.deleteRow(index);
    notifyListeners();
  }

  @override
  void cancelRow(int row) {
    super.cancelRow(row);
    notifyListeners();
  }

  @override
  void editRow(int row) {
    super.editRow(row);
    notifyListeners();
  }

  @override
  void updateRow(int index, List<dynamic> values) {
    super.updateRow(index, values);
    notifyListeners();
  }

  @override
  void selectRow(int index, {required bool isSelected}) {
    super.selectRow(index, isSelected: isSelected);
    notifyListeners();
  }

  @override
  void setEditingValue(int row, int column, dynamic value) {
    super.setEditingValue(row, column, value);
    notifyListeners();
  }

  List<dynamic> getRowByIndex(int index) {
    if (index < 0 || index > getDataLength()) {
      throw Exception('Index out of bounds');
    }
    return getData().getSavedValues(index);
  }

  List<List<dynamic>> getSelectedRows() {
    return getData().getAllSelectedSavedValues();
  }

  int getEditingRowsCount() {
    return getData().getEditingRowsCount();
  }

  bool isEditingRowsCountZero() {
    return getEditingRowsCount() == 0;
  }

  List<List<dynamic>> getAllRows() {
    return getData().getAllSavedValues();
  }

  @override
  DataRow? getRow(int index) {
    return _buildRow(index);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => getDataLength();

  @override
  int get selectedRowCount => getData().getSelectedRowsCount();

  int getActionsColumn(int row) {
    return getColumnsLength();
  }

  List<DataColumn> getTableColumns() {
    List<DataColumn> columnList = columns.map((e) {
      return DataColumn(
          label: e.label,
          numeric: e.numeric,
          tooltip: e.tooltip,
          onSort: e.onSort);
    }).toList();
    if (showActions || showDeleteOrCancelAction) {
      columnList.add(
        DataColumn(
          label: Text(actionColumnTitle),
        ),
      );
    }
    return columnList;
  }

  DataRow? _buildRow(int index) {
    var datarow = DataRow.byIndex(
      index: index,
      selected: getData().isSelected(index),
      onSelectChanged: selectable
          ? (value) {
              selectRow(index, isSelected: value ?? false);
              //data[index].onSelectChanged?.call(value);
            }
          : null,
      //onLongPress: data[index].onLongPress,
      //color: data[index].color,
      cells: _buildRowCells(index),
    );
    return datarow;
  }

  List<DataCell> _addActionsInCell(int row) {
    List<DynamicTableAction> actions = [];
    List<DataCell> cellsList = [];

    if (showActions)
      actions.add(
        DynamicTableActionEdit(
          showOnlyOnEditing: false,
          onPressed: () {
            editRow(row);
          },
        ),
      );

    if (showActions)
      actions.add(
        DynamicTableActionSave(
          showOnlyOnEditing: true,
          onPressed: () {
            saveRow(row);
          },
        ),
      );

    if (showActions || showDeleteOrCancelAction)
      actions.add(DynamicTableActionCancel(
        showOnlyOnEditing: true,
        onPressed: () {
          cancelRow(row);
        },
      ));

    if ((showActions && showDeleteAction) || showDeleteOrCancelAction)
      actions.add(DynamicTableActionDelete(
        showOnlyOnEditing: false,
        showAlways: !showDeleteOrCancelAction,
        onPressed: () {
          deleteRow(row);
        },
      ));

    if (actions.isNotEmpty) {
      DynamicTableActionsInput actionsInput = DynamicTableActionsInput();
      cellsList.add(
        DataCell(
          actionsInput.getChild(
            actions.where((element) {
              if (element.showAlways) {
                return true;
              } else if (element.showOnlyOnEditing &&
                  getData().isEditing(row)) {
                return true;
              } else if (!element.showOnlyOnEditing &&
                  !getData().isEditing(row)) {
                return true;
              }
              return false;
            }).map((e) {
              return e;
            }).toList(),
            isEditing: getData().isEditing(row),
            row: row,
            column: getActionsColumn(row),
          ),
        ),
      );
    }
    return cellsList;
  }

  List<DataCell> _buildRowCells(int row) {
    List<DataCell> cellsList =
        List.generate(getColumnsLength(), (index) => index).map((column) {
      final showEditingWidget =
          getData().isEditing(row) && isColumnEditable(column);
      return _buildDataCell(row, column, showEditingWidget);
    }).toList();
    cellsList.addAll(_addActionsInCell(row));
    return cellsList;
  }

  DataCell _buildDataCell(int index, int columnIndex, bool showEditingWidget) {
    var dynamicTableInputType = columns[columnIndex].dynamicTableInputType;
    return DataCell(
      dynamicTableInputType.getChild(
        focused: touchMode ? checkFocus(index, columnIndex) : false,
        getCurrentValue(index, columnIndex),
        isEditing: showEditingWidget,
        row: index,
        column: columnIndex,
        onChanged: (value, row, column) {
          setEditingValue(row, column, value);
        },
        onEditComplete: touchMode
            ? (row, column) {
                focusNextField(
                  row,
                  column,
                  onFocusNextRow: (oldRow) => saveRow(row),
                  onFocusLastRow: () => addRowLast(),
                );
              }
            : null,
      ),
      //placeholder: cell.placeholder,
      //showEditIcon: cell.showEditIcon,
      onTap: () {
        void tapToEdit(int row, int column) {
          focusThisField(row, column, onFocusThisField: (row) => editRow(row));
        }

        if (touchMode) if (isColumnEditable(columnIndex)) {
          if (!showEditingWidget) {
            tapToEdit(index, columnIndex);
          } else {
            focusThisField(index, columnIndex);
          }
        }
        //cell.onTap?.call();
      },
      //onLongPress: cell.onLongPress,
      //onTapDown: cell.onTapDown,
      //onDoubleTap: cell.onDoubleTap,
      //onTapCancel: cell.onTapCancel,
    );
  }
}
