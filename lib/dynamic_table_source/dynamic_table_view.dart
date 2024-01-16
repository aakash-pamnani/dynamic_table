import 'package:dynamic_table/dynamic_input_type/dynamic_table_input_type.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_action.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_shiftable_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_source.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';
import 'package:dynamic_table/dynamic_table_source/shifting_map.dart';
import 'package:flutter/material.dart';

typedef UnfocusFocusNodes = void Function ();
typedef GetFocusNode = FocusNode? Function();

class TouchEditCallBacks {
  final void Function()? focusPreviousField;
  final void Function()? focusNextField;
  final void Function()? focusThisEditingField;
  final void Function()? focusThisNonEditingField;
  final void Function()? cancelEdit;
  final void Function()? edit;
  final void Function(UnfocusFocusNodes unfocusFocusNodes, GetFocusNode getFocusNode, {required Object identity})? updateFocusCache;
  final void Function({required Object identity})? clearFocusCache;

  const TouchEditCallBacks(
      {this.focusPreviousField,
      this.focusNextField,
      this.focusThisEditingField,
      this.focusThisNonEditingField,
      this.cancelEdit,
      this.edit,
      this.updateFocusCache,
      this.clearFocusCache});
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
  void callOnPreviousFocus(void callBack(DynamicTableFocusData focus, DynamicTableFocusData previousFocus));

  final Map<int, Map<int, UnfocusFocusNodes>> _unfocusFocusNodesCache = {};
  final Map<int, Map<int, GetFocusNode>> _getFocusNodeCache = {};
  final Map<int, Map<int, Object>> _identities = {};

  void shiftViewCache(Map<int, int> shiftData) {
    _unfocusFocusNodesCache.shiftKeys(shiftData, getDataLength());
    _getFocusNodeCache.shiftKeys(shiftData, getDataLength());
    _identities.shiftKeys(shiftData, getDataLength());
  }

  void _updateFocusCache(
      Reference<int> row, int column, UnfocusFocusNodes unfocusFocusNodes, GetFocusNode getFocusNode, { required Object identity }) {
    if (!_unfocusFocusNodesCache.containsKey(row.value)) _unfocusFocusNodesCache[row.value] = {};
    if (!_getFocusNodeCache.containsKey(row.value)) _getFocusNodeCache[row.value] = {};
    if (!_identities.containsKey(row.value)) _identities[row.value] = {};
    _unfocusFocusNodesCache[row.value]![column] = unfocusFocusNodes;
    _getFocusNodeCache[row.value]![column] = getFocusNode;
    _identities[row.value]![column] = identity;
  }

  void _clearFocusCache(Reference<int> row, int column, {required Object identity}) {
    if (_identities.containsKey(row.value) && _identities[row.value]!.containsKey(column) && _identities[row.value]![column] != identity) return;

    if (_unfocusFocusNodesCache.containsKey(row.value) && _unfocusFocusNodesCache[row.value]!.containsKey(column)) {
      _unfocusFocusNodesCache[row.value]!.remove(column);
    }
    if (_unfocusFocusNodesCache.containsKey(row.value) && _unfocusFocusNodesCache[row.value]!.isEmpty) {
      _unfocusFocusNodesCache.remove(row.value);
    }

    if (_getFocusNodeCache.containsKey(row.value) && _getFocusNodeCache[row.value]!.containsKey(column)) {
      _getFocusNodeCache[row.value]!.remove(column);
    }
    if (_getFocusNodeCache.containsKey(row.value) && _getFocusNodeCache[row.value]!.isEmpty) {
      _getFocusNodeCache.remove(row.value);
    }

    if (_identities.containsKey(row.value) && _identities[row.value]!.containsKey(column)) {
      _identities[row.value]!.remove(column);
    }
    if (_identities.containsKey(row.value) && _identities[row.value]!.isEmpty) {
      _identities.remove(row.value);
    }
  }

  void unfocusPreviousFocusNodes() {
    callOnPreviousFocus((focus, previousFocus) {
      if (_unfocusFocusNodesCache.containsKey(previousFocus.row) && _unfocusFocusNodesCache[previousFocus.row]!.containsKey(previousFocus.column)) {
        _unfocusFocusNodesCache[previousFocus.row]![previousFocus.column]!();
      }
    });
  }

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
          ? () {
              focusThisField(index, columnIndex);
            }
          : null,
      cancelEdit: (enableTouchMode && showEditingWidget)
          ? () => cancelRow(index)
          : null,
      edit: (enableTouchMode && !showEditingWidget)
          ? () => tapToEdit(index, columnIndex)
          : null,
      updateFocusCache: (UnfocusFocusNodes unfocusFocusNodes, GetFocusNode getFocusNode, {required Object identity}) => _updateFocusCache(
                  index,
                  columnIndex,
                  unfocusFocusNodes,
                  getFocusNode, identity: identity),
      clearFocusCache: ({required Object identity}) => _clearFocusCache(index, columnIndex, identity: identity),
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
