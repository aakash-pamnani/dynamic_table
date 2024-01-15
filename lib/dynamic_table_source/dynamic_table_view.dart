import 'package:dynamic_table/dynamic_input_type/dynamic_table_input_type.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_action.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_shiftable_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_source.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';
import 'package:flutter/material.dart';

class TouchEditCallBacks {
  final void Function()? focusPreviousField;
  final void Function()? focusNextField;
  final void Function()? focusThisEditingField;
  final void Function()? focusThisNonEditingField;
  final void Function()? cancelEdit;
  final void Function()? edit;

  const TouchEditCallBacks(
      {this.focusPreviousField,
      this.focusNextField,
      this.focusThisEditingField,
      this.focusThisNonEditingField,
      this.cancelEdit,
      this.edit});
}

mixin DynamicTableView
    implements DynamicTableSourceQuery, DynamicTableViewConfig {
  DynamicTableShiftableData getData();
  void selectRow(Reference<int> index, {required bool isSelected});
  void updateSortByColumnIndex(int sortByColumnIndex);
  void editRow(Reference<int> row);
  void cancelRow(Reference<int> row);
  void deleteRow(Reference<int> index);
  bool isColumnEditableAndIfDropdownColumnThenHasDropdownValues(
      Reference<int> row, int columnIndex);
  bool saveRow(Reference<int> row);
  void focusThisField(Reference<int> row, int column,
      {void onFocusThisField(Reference<int> row)?});
  void focusPreviousField(Reference<int> row, int column,
      {void onFocusPreviousRow(Reference<int> oldRow)?});
  void focusNextField(Reference<int> row, int column,
      {void onFocusNextRow(Reference<int> oldRow)?, void onFocusLastRow()?});
  void addRowLast();
  Comparable<dynamic>? getCurrentValue(Reference<int> row, int column);
  void setEditingValue(
      Reference<int> row, int column, Comparable<dynamic>? value);
  bool checkFocus(Reference<int> row, int column);

  void _onSort(int column, bool order) {
    updateSortByColumnIndex(column);
  }

  List<DataColumn> getTableColumns() {
    List<DataColumn> columnList =
        getColumnsQuery().toDataColumn(onSort: _onSort);
    if (showActions || showDeleteOrCancelAction) {
      columnList.add(
        DataColumn(
          label: Text(actionColumnTitle),
        ),
      );
    }
    return columnList;
  }

  DataRow? buildRow(Reference<int> index) {
    var datarow = DataRow(
      key: getData().getKeyOfRowIndex(index) != null
          ? ValueKey<Comparable<dynamic>>(getData().getKeyOfRowIndex(index)!)
          : null,
      selected: getData().isSelected(index),
      onSelectChanged: selectable
          ? (value) {
              selectRow(index, isSelected: value ?? false);
            }
          : null,
      cells: _buildRowCells(index),
    );
    return datarow;
  }

  List<DataCell> _buildRowCells(Reference<int> row) {
    List<DataCell> cellsList =
        List.generate(getColumnsQuery().getColumnsLength(), (index) => index)
            .map((column) {
      return _buildDataCell(row, column);
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
            }).toList(),
            isEditing: getData().isEditing(row),
          ),
        ),
      );
    }
    return cellsList;
  }

  DataCell _buildDataCell(Reference<int> index, int columnIndex) {
    void tapToEdit(Reference<int> row, int column) {
      focusThisField(row, column, onFocusThisField: (row) => editRow(row));
    }

    final bool showEditingWidget = getData().isEditing(index) &&
        isColumnEditableAndIfDropdownColumnThenHasDropdownValues(
            index, columnIndex);
    final bool enableTouchMode = (touchMode &&
        isColumnEditableAndIfDropdownColumnThenHasDropdownValues(
            index, columnIndex));
    final touchEditCallBacks = TouchEditCallBacks(
      focusPreviousField: enableTouchMode
          ? (showEditingWidget
              ? () {
                  focusPreviousField(index, columnIndex,
                      onFocusPreviousRow: ((oldRow) => saveRow(oldRow)));
                }
              : () {
                  focusPreviousField(index, columnIndex);
                })
          : null,
      focusNextField: enableTouchMode
          ? (showEditingWidget
              ? () {
                  focusNextField(
                    index,
                    columnIndex,
                    onFocusNextRow: (oldRow) => saveRow(oldRow),
                    onFocusLastRow: () => addRowLast(),
                  );
                }
              : () {
                  focusNextField(
                    index,
                    columnIndex,
                    onFocusLastRow: () => addRowLast(),
                  );
                })
          : null,
      focusThisEditingField: (enableTouchMode && showEditingWidget)
          ? () => focusThisField(index, columnIndex)
          : null,
      focusThisNonEditingField: (enableTouchMode && !showEditingWidget)
          ? () { focusThisField(index, columnIndex); }
          : null,
      cancelEdit: (enableTouchMode && showEditingWidget)
          ? () => cancelRow(index)
          : null,
      edit: (enableTouchMode && !showEditingWidget)
          ? () => tapToEdit(index, columnIndex)
          : null,
    );

    return DataCell(
      getColumnsQuery().getChildCallBack(columnIndex).call(
        focused: enableTouchMode ? checkFocus(index, columnIndex) : false,
        getCurrentValue(index, columnIndex),
        isEditing: showEditingWidget,
        onChanged: (value) {
          setEditingValue(index, columnIndex, value as Comparable<dynamic>?);
        },
        touchEditCallBacks: touchEditCallBacks,
      ),
      onDoubleTap: touchEditCallBacks.edit,
      onTap: touchEditCallBacks.focusThisNonEditingField,
    );
  }
}
