import 'package:dynamic_table/dynamic_input_type/dynamic_table_input_type.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_action.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_shiftable_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_source.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';
import 'package:dynamic_table/dynamic_table_source/shifting_map.dart';
import 'package:flutter/material.dart';

class UpdateFocusNodeCallBacks {
  final void Function() unfocusFocusNodes;
  final void Function() focusFocusNodes;

  UpdateFocusNodeCallBacks(
      {required this.unfocusFocusNodes, required this.focusFocusNodes});
}

class TouchEditCallBacks {
  final void Function()? focusPreviousField;
  final void Function()? focusNextField;
  final void Function()? focusThisEditingField;
  final void Function()? focusThisNonEditingField;
  final void Function()? cancelEdit;
  final void Function()? edit;
  final void Function(UpdateFocusNodeCallBacks updateFocusNodeCallBacks,
      {required Object identity})? updateFocusCache;
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

class UnfinishedFocusUpdateData {
  final bool clearPreviousFocus;
  final bool setThisFocus;

  UnfinishedFocusUpdateData(
      {required this.clearPreviousFocus, required this.setThisFocus});

  UnfinishedFocusUpdateData clone(
      {bool? clearPreviousFocus, bool? setThisFocus}) {
    return UnfinishedFocusUpdateData(
        clearPreviousFocus: clearPreviousFocus ?? this.clearPreviousFocus,
        setThisFocus: setThisFocus ?? this.setThisFocus);
  }

  bool hasUnfinishedUpdates() {
    return clearPreviousFocus || setThisFocus;
  }

  @override
  String toString() {
    return 'clearPreviousFocus: ' +
        clearPreviousFocus.toString() +
        ' | ' +
        'setThisFocus: ' +
        setThisFocus.toString();
  }
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
  DynamicTableFocusData getRawFocus();
  DynamicTableFocusData getFocus();
  void callOnFocus(
      void callBack(
          DynamicTableFocusData focus, DynamicTableFocusData? previousFocus));
  bool isRowWithinRange(TableRowRange? tableRowRange);
  TableRowRange Function() get tableRowVisibleRange;

  final Map<int, Map<int, UpdateFocusNodeCallBacks>>
      _updateFocusNodeCallBacksCache = {};
  final Map<int, Map<int, Object>> _identities = {};
  final Map<int, Map<int, UnfinishedFocusUpdateData>>
      _unfinishedFocusUpdateDataCache = {};

  Set<Reference<int>> currentBuiltRows = Set();

  void shiftViewCache(Map<int, int> shiftData) {
    [LoggerName.focusCache].info(() => shiftData.toString());
    _updateFocusNodeCallBacksCache.shiftKeys(shiftData, getDataLength());
    _identities.shiftKeys(shiftData, getDataLength());
    _unfinishedFocusUpdateDataCache.shiftKeys(shiftData, getDataLength());
    currentBuiltRows.forEach((row) {
      row.shift(shiftData);
    });
  }

  void _updateUnfinishedFocusUpdateDataCache(DynamicTableFocusData focus,
      UnfinishedFocusUpdateData unfinishedFocusUpdateData) {
    if (!_unfinishedFocusUpdateDataCache.containsKey(focus.row)) {
      _unfinishedFocusUpdateDataCache[focus.row] = {};
    }
    if (unfinishedFocusUpdateData.hasUnfinishedUpdates()) {
      [LoggerName.focusCache].info(() =>
          'has unfinished updates: ' +
          focus.toString() +
          ' | unfinished updates: ' +
          unfinishedFocusUpdateData.toString());
      _unfinishedFocusUpdateDataCache[focus.row]![focus.column] =
          unfinishedFocusUpdateData;
    } else {
      [LoggerName.focusCache]
          .info(() => 'has no unfinished updates: ' + focus.toString());
      _unfinishedFocusUpdateDataCache[focus.row]!.remove(focus.column);
    }
  }

  void _updateFocusCache(Reference<int> row, int column,
      UpdateFocusNodeCallBacks updateFocusNodeCallBacks,
      {required Object identity}) {
    if (!_updateFocusNodeCallBacksCache.containsKey(row.value)) {
      _updateFocusNodeCallBacksCache[row.value] = {};
    }
    if (!_identities.containsKey(row.value)) _identities[row.value] = {};
    _updateFocusNodeCallBacksCache[row.value]![column] =
        updateFocusNodeCallBacks;
    _identities[row.value]![column] = identity;

    if (_unfinishedFocusUpdateDataCache.containsKey(row.value) &&
        _unfinishedFocusUpdateDataCache[row.value]!.containsKey(column)) {
      final UnfinishedFocusUpdateData unfinishedFocusUpdateData =
          _unfinishedFocusUpdateDataCache[row.value]![column]!;
      [LoggerName.focusCache].info(() =>
          'update focus cache: ' +
          ' :at: ' +
          'row: ' +
          row.value.toString() +
          ' | column: ' +
          column.toString() +
          ':notclearprev:' +
          unfinishedFocusUpdateData.clearPreviousFocus.toString() +
          ':notsetthis:' +
          unfinishedFocusUpdateData.setThisFocus.toString());
      updateFocusNodes(
          cachedFocus: DynamicTableFocusData(row: row.value, column: column),
          cachedUnfinishedFocusUpdateData: unfinishedFocusUpdateData);
    }
  }

  void _clearFocusCache(Reference<int> row, int column,
      {required Object identity}) {
    if (_identities.containsKey(row.value) &&
        _identities[row.value]!.containsKey(column) &&
        !identical(_identities[row.value]![column], identity)) return;

    if (_updateFocusNodeCallBacksCache.containsKey(row.value) &&
        _updateFocusNodeCallBacksCache[row.value]!.containsKey(column)) {
      _updateFocusNodeCallBacksCache[row.value]!.remove(column);
    }
    if (_updateFocusNodeCallBacksCache.containsKey(row.value) &&
        _updateFocusNodeCallBacksCache[row.value]!.isEmpty) {
      _updateFocusNodeCallBacksCache.remove(row.value);
    }

    if (_identities.containsKey(row.value) &&
        _identities[row.value]!.containsKey(column)) {
      _identities[row.value]!.remove(column);
    }
    if (_identities.containsKey(row.value) && _identities[row.value]!.isEmpty) {
      _identities.remove(row.value);
    }
    [LoggerName.focusCache].info(() =>
        'cleared focus cache: ' +
        ' :at: ' +
        'row: ' +
        row.value.toString() +
        ' | column: ' +
        column.toString());
  }

  ({bool newFocusSet}) updateFocusNodes(
      {DynamicTableFocusData? cachedFocus,
      UnfinishedFocusUpdateData? cachedUnfinishedFocusUpdateData,
      bool? secondaryUpdate}) {
    bool isNotSecondaryUpdate() => !(secondaryUpdate ?? false);
    bool isTableCellPositionVisible(DynamicTableFocusData? focus) {
      if (focus == null) return false;
      final TableRowRange visibleRowRange = tableRowVisibleRange();
      return ((visibleRowRange.startIndex == null ||
              focus.row >= visibleRowRange.startIndex!) ||
          (visibleRowRange.endIndex == null ||
              focus.row <= visibleRowRange.endIndex!));
    }

    UnfinishedFocusUpdateData? couldNotClearPreviousFocus(
        UnfinishedFocusUpdateData unfinishedFocusUpdateData) {
      if (isNotSecondaryUpdate()) {
        return unfinishedFocusUpdateData.clone(clearPreviousFocus: true);
      }
      return null;
    }

    UnfinishedFocusUpdateData? clearedPreviousFocus(
        UnfinishedFocusUpdateData unfinishedFocusUpdateData) {
      if (isNotSecondaryUpdate()) {
        return unfinishedFocusUpdateData.clone(clearPreviousFocus: false);
      }
      return null;
    }

    UnfinishedFocusUpdateData? couldNotSetThisFocus(
        UnfinishedFocusUpdateData unfinishedFocusUpdateData) {
      if (isNotSecondaryUpdate()) {
        return unfinishedFocusUpdateData.clone(setThisFocus: true);
      }
      return null;
    }

    bool newFocusSet = false;
    UnfinishedFocusUpdateData? settedThisFocus(
        UnfinishedFocusUpdateData unfinishedFocusUpdateData) {
      if (isNotSecondaryUpdate()) newFocusSet = true;
      if (isNotSecondaryUpdate()) {
        return unfinishedFocusUpdateData.clone(setThisFocus: false);
      }
      return null;
    }

    void _clearPreviousFocus(DynamicTableFocusData? previousFocus) {
      UnfinishedFocusUpdateData unfinishedFocusUpdateData =
          UnfinishedFocusUpdateData(
              clearPreviousFocus: false, setThisFocus: false);
      if (previousFocus == null) {
        unfinishedFocusUpdateData =
            clearedPreviousFocus(unfinishedFocusUpdateData) ??
                unfinishedFocusUpdateData;
        return;
      }
      if (_updateFocusNodeCallBacksCache.containsKey(previousFocus.row) &&
          _updateFocusNodeCallBacksCache[previousFocus.row]!
              .containsKey(previousFocus.column)) {
        [LoggerName.focusCache].info(() => 'cleared previous focus');
        _updateFocusNodeCallBacksCache[previousFocus.row]![
                previousFocus.column]!
            .unfocusFocusNodes();
        unfinishedFocusUpdateData =
            clearedPreviousFocus(unfinishedFocusUpdateData) ??
                unfinishedFocusUpdateData;
      } else {
        unfinishedFocusUpdateData =
            couldNotClearPreviousFocus(unfinishedFocusUpdateData) ??
                unfinishedFocusUpdateData;
      }
      if (isNotSecondaryUpdate()) {
        _updateUnfinishedFocusUpdateDataCache(
            previousFocus, unfinishedFocusUpdateData);
      }
    }

    void _setThisFocus(DynamicTableFocusData focus) {
      UnfinishedFocusUpdateData unfinishedFocusUpdateData =
          UnfinishedFocusUpdateData(
              clearPreviousFocus: false, setThisFocus: false);
      if (_updateFocusNodeCallBacksCache.containsKey(focus.row) &&
          _updateFocusNodeCallBacksCache[focus.row]!
              .containsKey(focus.column)) {
        [LoggerName.focusCache].info(() => 'set new focus');
        _updateFocusNodeCallBacksCache[focus.row]![focus.column]!
            .focusFocusNodes();
        unfinishedFocusUpdateData =
            settedThisFocus(unfinishedFocusUpdateData) ??
                unfinishedFocusUpdateData;
      } else {
        unfinishedFocusUpdateData =
            couldNotSetThisFocus(unfinishedFocusUpdateData) ??
                unfinishedFocusUpdateData;
      }
      if (isNotSecondaryUpdate()) {
        _updateUnfinishedFocusUpdateDataCache(focus, unfinishedFocusUpdateData);
      }
    }

    void callOnCachedFocus() {
      if (isTableCellPositionVisible(cachedFocus) &&
          (cachedUnfinishedFocusUpdateData?.clearPreviousFocus ?? false)) {
        [LoggerName.focusCache].info(() =>
            'focus nodes update: previous focus: ' + cachedFocus.toString());
        _clearPreviousFocus(cachedFocus);
      }

      if (isTableCellPositionVisible(cachedFocus) &&
          (cachedUnfinishedFocusUpdateData?.setThisFocus ?? false)) {
        [LoggerName.focusCache]
            .info(() => 'focus nodes update: focus: ' + cachedFocus.toString());
        _setThisFocus(cachedFocus!);
      }
    }

    void callOnCurrentFocus() => callOnFocus((focus, previousFocus) {
          [LoggerName.focusCache].info(() =>
              'focus nodes update: previous focus: ' +
              previousFocus.toString());
          _clearPreviousFocus(previousFocus);

          [LoggerName.focusCache]
              .info(() => 'focus nodes update: focus: ' + focus.toString());
          _setThisFocus(focus);
        });

    if (cachedFocus != null || cachedUnfinishedFocusUpdateData != null) {
      callOnCachedFocus();
    } else {
      callOnCurrentFocus();
    }
    return (newFocusSet: newFocusSet);
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

  DataRow? buildRow(int index) {
    Reference<int> rowIndex = Reference<int>(value: index);
    currentBuiltRows.remove(rowIndex);
    currentBuiltRows.add(rowIndex);
    var datarow = DataRow(
      key: getData().getKeyOfRowIndex(rowIndex) != null
          ? ValueKey<Comparable<dynamic>>(getData().getKeyOfRowIndex(rowIndex)!)
          : null,
      selected: getData().isSelected(rowIndex),
      onSelectChanged: selectable
          ? (value) {
              selectRow(rowIndex, isSelected: value ?? false);
            }
          : null,
      cells: _buildRowCells(rowIndex),
    );
    return datarow;
  }

  List<DataCell> _buildRowCells(Reference<int> rowIndex) {
    List<DataCell> cellsList =
        List.generate(getColumnsQuery().getColumnsLength(), (index) => index)
            .map((column) {
      return _buildDataCell(rowIndex, column);
    }).toList();
    cellsList.addAll(_addActionsInCell(rowIndex));
    return cellsList;
  }

  List<DataCell> _addActionsInCell(Reference<int> rowIndex) {
    List<DynamicTableAction> actions = [];
    List<DataCell> cellsList = [];

    if (showActions) {
      actions.add(
        DynamicTableActionEdit(
          showOnlyOnEditing: false,
          onPressed: () {
            editRow(rowIndex.clone());
          },
        ),
      );
    }

    if (showActions) {
      actions.add(
        DynamicTableActionSave(
          showOnlyOnEditing: true,
          onPressed: () {
            saveRow(rowIndex.clone());
          },
        ),
      );
    }

    if (showActions || showDeleteOrCancelAction) {
      actions.add(DynamicTableActionCancel(
        showOnlyOnEditing: true,
        onPressed: () {
          cancelRow(rowIndex.clone());
        },
      ));
    }

    if ((showActions && showDeleteAction) || showDeleteOrCancelAction) {
      actions.add(DynamicTableActionDelete(
        showOnlyOnEditing: false,
        showAlways: !showDeleteOrCancelAction,
        onPressed: () {
          deleteRow(rowIndex.clone());
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
                  getData().isEditing(rowIndex.clone())) {
                return true;
              } else if (!element.showOnlyOnEditing &&
                  !getData().isEditing(rowIndex.clone())) {
                return true;
              }
              return false;
            }).toList(),
            isEditing: getData().isEditing(rowIndex.clone()),
          ),
        ),
      );
    }
    return cellsList;
  }

  DataCell _buildDataCell(Reference<int> rowIndex, int columnIndex) {
    void tapToEdit(Reference<int> row, int column) {
      focusThisField(row, column, onFocusThisField: (row) => editRow(row));
    }

    final bool showEditingWidget = getData().isEditing(rowIndex.clone()) &&
        isColumnEditableAndIfDropdownColumnThenHasDropdownValues(
            rowIndex.clone(), columnIndex);
    final bool enableTouchMode = (touchMode &&
        isColumnEditableAndIfDropdownColumnThenHasDropdownValues(
            rowIndex.clone(), columnIndex));
    final touchEditCallBacks = TouchEditCallBacks(
      focusPreviousField: enableTouchMode
          ? (showEditingWidget
              ? () {
                  focusPreviousField(rowIndex.clone(), columnIndex,
                      onFocusPreviousRow: ((oldRow) => saveRow(oldRow)));
                }
              : () {
                  focusPreviousField(rowIndex.clone(), columnIndex);
                })
          : null,
      focusNextField: enableTouchMode
          ? (showEditingWidget
              ? () {
                  focusNextField(
                    rowIndex.clone(),
                    columnIndex,
                    onFocusNextRow: (oldRow) => saveRow(oldRow),
                    onFocusLastRow: () => addRowLast(),
                  );
                }
              : () {
                  focusNextField(
                    rowIndex.clone(),
                    columnIndex,
                    onFocusLastRow: () => addRowLast(),
                  );
                })
          : null,
      focusThisEditingField: (enableTouchMode && showEditingWidget)
          ? () => focusThisField(rowIndex.clone(), columnIndex)
          : null,
      focusThisNonEditingField: (enableTouchMode && !showEditingWidget)
          ? () {
              focusThisField(rowIndex.clone(), columnIndex);
            }
          : null,
      cancelEdit: (enableTouchMode && showEditingWidget)
          ? () => cancelRow(rowIndex.clone())
          : null,
      edit: (enableTouchMode && !showEditingWidget)
          ? () => tapToEdit(rowIndex.clone(), columnIndex)
          : null,
      updateFocusCache: (UpdateFocusNodeCallBacks updateFocusNodeCallBacks,
              {required Object identity}) =>
          _updateFocusCache(
              rowIndex.clone(), columnIndex, updateFocusNodeCallBacks,
              identity: identity),
      clearFocusCache: ({required Object identity}) =>
          _clearFocusCache(rowIndex.clone(), columnIndex, identity: identity),
    );

    [LoggerName.focusCache].info(() => checkFocus(rowIndex.clone(), columnIndex)
        ? ('building focus : ' +
            'row: ' +
            rowIndex.clone().value.toString() +
            ' | column: ' +
            columnIndex.toString())
        : '');
    [LoggerName.focusCache].info(() =>
        'building raw focus: ' +
        getRawFocus().toString() +
        ' :focus: ' +
        getFocus().toString() +
        ' :at: ' +
        'row: ' +
        rowIndex.clone().value.toString() +
        ' | column: ' +
        columnIndex.toString());

    return DataCell(
      getColumnsQuery().getChildCallBack(columnIndex).call(
        focused:
            enableTouchMode ? checkFocus(rowIndex.clone(), columnIndex) : false,
        getCurrentValue(rowIndex.clone(), columnIndex),
        isEditing: showEditingWidget,
        onChanged: (value) {
          setEditingValue(
              rowIndex.clone(), columnIndex, value as Comparable<dynamic>?);
        },
        touchEditCallBacks: touchEditCallBacks,
      ),
      onDoubleTap: touchEditCallBacks.edit,
      onTap: touchEditCallBacks.focusThisNonEditingField,
    );
  }
}
