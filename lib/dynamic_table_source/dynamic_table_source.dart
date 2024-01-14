import 'package:dynamic_table/dynamic_table_source/dynamic_table_editables.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_editing_values.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_shiftable_data.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_table/dynamic_input_type/dynamic_table_input_type.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_action.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_column.dart';

abstract class DynamicTableSourceView {
  int getDataLength();
  int getColumnsLength();
  bool isColumnEditable(int column);
  int getKeyColumnIndex();
}

abstract class DynamicTableSourceConfig {
  bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)? get onRowEdit;
  bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)? get onRowDelete;
  List<Comparable<dynamic>?>? Function(
      Comparable<dynamic>? key, List<Comparable<dynamic>?> oldValue, List<Comparable<dynamic>?> newValue)? get onRowSave;
  bool get selectable;
  bool get editOneByOne;
  bool get autoSaveRowsEnabled;
}

class DynamicTableSource extends DataTableSource
    with DynamicTableFocus, DynamicTableEditables
    implements DynamicTableSourceView, DynamicTableSourceConfig {
  String actionColumnTitle;
  bool showActions;
  bool showDeleteAction;
  bool showDeleteOrCancelAction;
  bool touchMode;
  bool selectable;
  bool editOneByOne;
  bool autoSaveRowsEnabled;
  bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)? onRowEdit;
  bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)? onRowDelete;
  List<Comparable<dynamic>?>? Function(
      Comparable<dynamic>? key, List<Comparable<dynamic>?> oldValue, List<Comparable<dynamic>?> newValue)? onRowSave;

  final List<DynamicTableDataColumn> columns;
  late DynamicTableShiftableData _data;
  late DynamicTableEditingValues _editingValues;

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
    bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)? onRowEdit,
    bool Function(Comparable<dynamic>? key, List<Comparable<dynamic>?> row)? onRowDelete,
    List<Comparable<dynamic>?>? Function(
      Comparable<dynamic>? key, List<Comparable<dynamic>?> oldValue, List<Comparable<dynamic>?> newValue)? onRowSave,}) {
      if (actionColumnTitle != null) this.actionColumnTitle = actionColumnTitle;
      if (showActions != null) this.showActions = showActions;
      if (showDeleteAction != null) this.showDeleteAction = showDeleteAction;
      if (showDeleteOrCancelAction != null) this.showDeleteOrCancelAction = showDeleteOrCancelAction;
      if (touchMode != null) this.touchMode = touchMode;
      if (selectable != null) this.selectable = selectable;
      if (editOneByOne != null) this.editOneByOne = editOneByOne;
      if (autoSaveRowsEnabled != null) this.autoSaveRowsEnabled = autoSaveRowsEnabled;
      if (onRowEdit != null) this.onRowEdit = onRowEdit;
      if (onRowDelete != null) this.onRowDelete = onRowDelete;
      if (onRowSave != null) this.onRowSave = onRowSave;
      notifyListeners();
    }

  void retainFocus(DynamicTableSource? lastSource) {
    this._focus = lastSource?._focus;
    notifyListeners();
  }

  DynamicTableSource({
    required Map<Comparable<dynamic>, List<Comparable<dynamic>?>> data,
    required this.columns,
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
  }) : _editingValues = DynamicTableEditingValues(columns: columns) {

    _data = DynamicTableShiftableData(data, onShift: onShift, keyColumnIndex: getKeyColumnIndex(), columnsLength: getColumnsLength());

    //Retaining empty rows with their editing values if present
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

  int getKeyColumnIndex() {
    var column = columns.where((column) => column.isKeyColumn).first;
    return columns.indexOf(column);
  }

  @override
  DynamicTableShiftableData getData() =>  _data;

  @override
  DynamicTableEditingValues getEditingValues() => _editingValues;

  void onShift(Map<int, int> shiftData) {
    shiftEditingValues(shiftData);
    _focus = shiftFocus(_focus, shiftData);
  }

  @override
  void insertRow(Reference<int> index, {List<Comparable<dynamic>?>? values, bool isEditing = false}) {
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
  void setEditingValue(Reference<int> row, int column, Comparable<dynamic>? value) {
    super.setEditingValue(row, column, value);
    notifyListeners();
  }

  @override
  void updateSortByColumnIndex(int sortByColumnIndex) {
    super.updateSortByColumnIndex(sortByColumnIndex);
    notifyListeners();
  }

  List<Comparable<dynamic>?> getRowByIndex(Reference<int> index) {
    if (index < 0 || index >= getDataLength()) {
      throw Exception('Index out of bounds');
    }
    return getData().getSavedValues(index);
  }

  List<List<Comparable<dynamic>?>> getSelectedRows() {
    return getData().getAllSelectedSavedValues();
  }

  int getEditingRowsCount() {
    return getData().getEditingRowsCount();
  }

  bool isEditingRowsCountZero() {
    return getData().isEditingRowsCountZero();
  }

  List<List<Comparable<dynamic>?>> getAllRows() {
    return getData().getAllSavedValues();
  }

  @override
  DataRow? getRow(int index) {
    return _buildRow(Reference<int>(value: index));
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
          onSort: (column, order) => updateSortByColumnIndex(column));
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

  DataRow? _buildRow(Reference<int> index) {
    var datarow = DataRow(
      key: getData().getKeyOfRowIndex(index)!=null? ValueKey<Comparable<dynamic>>(getData().getKeyOfRowIndex(index)!) : null,
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

  List<DataCell> _buildRowCells(Reference<int> row) {
    List<DataCell> cellsList =
        List.generate(getColumnsLength(), (index) => index).map((column) {
      final showEditingWidget =
          getData().isEditing(row) && isColumnEditable(column);
      return _buildDataCell(row, column, showEditingWidget);
    }).toList();
    cellsList.addAll(_addActionsInCell(row));
    return cellsList;
  }

  List<DataCell> _addActionsInCell(Reference<int> row) {
    List<DynamicTableAction> actions = [];
    List<DataCell> cellsList = [];

    if (showActions) {
      actions.add(
        DynamicTableActionEdit(
          showOnlyOnEditing: false,
          onPressed: () {
            editRow(row);
          },
        ),
      );
    }

    if (showActions) {
      actions.add(
        DynamicTableActionSave(
          showOnlyOnEditing: true,
          onPressed: () {
            saveRow(row);
          },
        ),
      );
    }

    if (showActions || showDeleteOrCancelAction) {
      actions.add(DynamicTableActionCancel(
        showOnlyOnEditing: true,
        onPressed: () {
          cancelRow(row);
        },
      ));
    }

    if ((showActions && showDeleteAction) || showDeleteOrCancelAction) {
      actions.add(DynamicTableActionDelete(
        showOnlyOnEditing: false,
        showAlways: !showDeleteOrCancelAction,
        onPressed: () {
          deleteRow(row);
        },
      ));
    }

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
          ),
        ),
      );
    }
    return cellsList;
  }

  DataCell _buildDataCell(Reference<int> index, int columnIndex, bool showEditingWidget) {
    var dynamicTableInputType = columns[columnIndex].dynamicTableInputType;
    return DataCell(
      dynamicTableInputType.getChild(
        focused: touchMode ? checkFocus(index, columnIndex) : false,
        getCurrentValue(index, columnIndex),
        isEditing: showEditingWidget,
        onChanged: (value) {
          setEditingValue(index, columnIndex, value as Comparable<dynamic>?);
        },
        onEditComplete: touchMode
            ? () {
                if (showEditingWidget) {
                  focusNextField(
                    index,
                    columnIndex,
                    onFocusNextRow: (oldRow) => saveRow(index),
                    onFocusLastRow: () => addRowLast(),
                  );
                } else {
                  focusNextField(
                    index,
                    columnIndex,
                    onFocusLastRow: () => addRowLast(),
                  );
                }
              }
            : null,
        focusThisField: () => focusThisField(index, columnIndex),
      ),
      //placeholder: cell.placeholder,
      //showEditIcon: cell.showEditIcon,
      onTap: () {
        void tapToEdit(Reference<int> row, int column) {
          focusThisField(row, column, onFocusThisField: (row) => editRow(row));
        }

        if (touchMode && isColumnEditable(columnIndex)) {
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
