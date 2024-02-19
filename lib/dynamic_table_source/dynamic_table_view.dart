import 'package:dynamic_table/dynamic_input_type/dynamic_table_input_type.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_action.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_source.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';
import 'package:dynamic_table/dynamic_table_source/shifting_map.dart';
import 'package:dynamic_table/utils/logging.dart';
import 'package:flutter/material.dart';

class UpdateFocusNodeCallBacks {
  final void Function() unfocusFocusNodes;
  final void Function() focusFocusNodes;

  const UpdateFocusNodeCallBacks(
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
  final String Function()? debugMessage;

  const TouchEditCallBacks(
      {this.focusPreviousField,
      this.focusNextField,
      this.focusThisEditingField,
      this.focusThisNonEditingField,
      this.cancelEdit,
      this.edit,
      this.updateFocusCache,
      this.clearFocusCache,
      this.debugMessage});
}

class UnfinishedFocusUpdateData {
  final bool clearPreviousFocus;
  final bool setThisFocus;

  const UnfinishedFocusUpdateData(
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
  void selectRow(Reference<int> index, {required bool isSelected});
  void updateSortByColumnIndex(int sortByColumnIndex);
  void editRow(Reference<int> row);
  void cancelRow(Reference<int> row);
  void deleteRow(Reference<int> index);
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
  void callOnFocus(
      void callBack(
          DynamicTableFocusData focus, DynamicTableFocusData? previousFocus));

  final Map<int, Map<int, UpdateFocusNodeCallBacks>>
      _updateFocusNodeCallBacksCache = {};
  final Map<int, Map<int, Object>> _identities = {};
  final Map<int, Map<int, UnfinishedFocusUpdateData>>
      _unfinishedFocusUpdateDataCache = {};

  Set<Reference<int>> _currentBuiltRows = Set();

  void shiftViewCache(Map<int, int> shiftData) {
    [LoggerName.focusCache, LoggerName.editing].info(() => "Shifting: " + shiftData.toString());
    _updateFocusNodeCallBacksCache.shiftKeys(shiftData, getDataLength());
    _identities.shiftKeys(shiftData, getDataLength());
    _unfinishedFocusUpdateDataCache.shiftKeys(shiftData, getDataLength());
    _currentBuiltRows.forEach((row) {
      row.shift(shiftData);
    });
  }

  void _updateUnfinishedFocusUpdateDataCache(DynamicTableFocusData focus,
      UnfinishedFocusUpdateData unfinishedFocusUpdateData) {
    if (!_unfinishedFocusUpdateDataCache.containsKey(focus.row)) {
      _unfinishedFocusUpdateDataCache[focus.row] = {};
    }
    if (unfinishedFocusUpdateData.hasUnfinishedUpdates()) {
      [LoggerName.focusCache, LoggerName.editing].info(() =>
          'has unfinished updates: ' +
          focus.toString() +
          ' | unfinished updates: ' +
          unfinishedFocusUpdateData.toString());
      _unfinishedFocusUpdateDataCache[focus.row]![focus.column] =
          unfinishedFocusUpdateData;
    } else {
      [LoggerName.focusCache, LoggerName.editing]
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

    [LoggerName.focusCache, LoggerName.editing].info(() =>
        'stored focus cache: ' +
        ' :at: ' +
        'row: ' +
        row.value.toString() +
        ' | column: ' +
        column.toString());

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
    [LoggerName.focusCache, LoggerName.editing].info(() =>
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
    bool? isTableCellPositionVisible(DynamicTableFocusData? focus) {
      final TableRowRange visibleRowRange = tableRowVisibleRange();
      return DynamicTableSourceQuery.isRowWithinRange(focus, visibleRowRange);
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
      [LoggerName.editing].info(() => "clearing previous focus: " + previousFocus.toString());
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
        [LoggerName.focusCache, LoggerName.editing].info(() => 'cleared previous focus');
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
      [LoggerName.editing].info(() => "setting this focus: " + focus.toString());
      UnfinishedFocusUpdateData unfinishedFocusUpdateData =
          UnfinishedFocusUpdateData(
              clearPreviousFocus: false, setThisFocus: false);
      if (_updateFocusNodeCallBacksCache.containsKey(focus.row) &&
          _updateFocusNodeCallBacksCache[focus.row]!
              .containsKey(focus.column)) {
        [LoggerName.focusCache, LoggerName.editing].info(() => 'set new focus');
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
      if ((isTableCellPositionVisible(cachedFocus)??false) &&
          (cachedUnfinishedFocusUpdateData?.clearPreviousFocus ?? false)) {
        [LoggerName.focusCache].info(() =>
            'focus nodes update: previous focus: ' + cachedFocus.toString());
        _clearPreviousFocus(cachedFocus);
      }

      if ((isTableCellPositionVisible(cachedFocus)??false) &&
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
    [LoggerName.editing].info(() => "Building Row: " + index.toString());
    Reference<int> Function() getRowReferenceCloner() {
      Reference<int> rowIndex = Reference<int>(value: index);
      _currentBuiltRows.remove(rowIndex);
      _currentBuiltRows.add(rowIndex);
      return () => rowIndex.clone();
    }
    final cloneRowReference = getRowReferenceCloner();
    final KeyOfRowReference = getKeyOfRowIndex(cloneRowReference());
    var datarow = DataRow(
      key: KeyOfRowReference != null
          ? ValueKey<Comparable<dynamic>>(KeyOfRowReference)
          : null,
      selected: isSelected(cloneRowReference()),
      onSelectChanged: selectable
          ? (value) {
              selectRow(cloneRowReference(), isSelected: value ?? false);
            }
          : null,
      cells: _buildRowCells(cloneRowReference),
    );
    return datarow;
  }

  List<DataCell> _buildRowCells(Reference<int> cloneRowReference()) {
    List<DataCell> cellsList =
        List.generate(getColumnsQuery().getColumnsLength(), (index) => index)
            .map((column) {
      return _buildDataCell(cloneRowReference, column);
    }).toList();
    cellsList.addAll(_addActionsInCell(cloneRowReference));
    return cellsList;
  }

  List<DataCell> _addActionsInCell(Reference<int> cloneRowReference()) {
    List<DynamicTableAction> actions = [];
    List<DataCell> cellsList = [];

    if (showActions) {
      actions.add(
        DynamicTableActionEdit(
          showOnlyOnEditing: false,
          onPressed: () {
            editRow(cloneRowReference());
          },
        ),
      );
    }

    if (showActions) {
      actions.add(
        DynamicTableActionSave(
          showOnlyOnEditing: true,
          onPressed: () {
            saveRow(cloneRowReference());
          },
        ),
      );
    }

    if (showActions || showDeleteOrCancelAction) {
      actions.add(DynamicTableActionCancel(
        showOnlyOnEditing: true,
        onPressed: () {
          cancelRow(cloneRowReference());
        },
      ));
    }

    if ((showActions && showDeleteAction) || showDeleteOrCancelAction) {
      actions.add(DynamicTableActionDelete(
        showOnlyOnEditing: false,
        showAlways: !showDeleteOrCancelAction,
        onPressed: () {
          deleteRow(cloneRowReference());
        },
      ));
    }

    if (actions.isNotEmpty) {
      DynamicTableActionsInput actionsInput = DynamicTableActionsInput();
      final isRowEditing = isEditing(cloneRowReference());
      cellsList.add(
        DataCell(
          actionsInput.getChild(
            actions.where((element) {
              if (element.showAlways) {
                return true;
              } else if (element.showOnlyOnEditing &&
                  isRowEditing) {
                return true;
              } else if (!element.showOnlyOnEditing &&
                  !isRowEditing) {
                return true;
              }
              return false;
            }).toList(),
            isEditing: isRowEditing,
          ),
        ),
      );
    }
    return cellsList;
  }

  DataCell _buildDataCell(Reference<int> cloneRowReference(), int columnIndex) {
    void tapToEdit(Reference<int> row, int column) {
      focusThisField(row, column, onFocusThisField: (row) => editRow(row));
    }

    final bool showEditingWidget = isEditing(cloneRowReference()) &&
        isColumnEditableAndIfDropdownColumnThenHasDropdownValues(
            cloneRowReference(), columnIndex);
    final bool enableTouchMode = (touchMode &&
        isColumnEditableAndIfDropdownColumnThenHasDropdownValues(
            cloneRowReference(), columnIndex));
    final touchEditCallBacks = TouchEditCallBacks(
      focusPreviousField: enableTouchMode
          ? (showEditingWidget
              ? () {
                  focusPreviousField(cloneRowReference(), columnIndex,
                      onFocusPreviousRow: ((oldRow) => saveRow(oldRow)));
                }
              : () {
                  focusPreviousField(cloneRowReference(), columnIndex);
                })
          : null,
      focusNextField: enableTouchMode
          ? (showEditingWidget
              ? () {
                  focusNextField(
                    cloneRowReference(),
                    columnIndex,
                    onFocusNextRow: (oldRow) => saveRow(oldRow),
                    onFocusLastRow: () => addRowLast(),
                  );
                }
              : () {
                  focusNextField(
                    cloneRowReference(),
                    columnIndex,
                    onFocusLastRow: () => addRowLast(),
                  );
                })
          : null,
      focusThisEditingField: (enableTouchMode && showEditingWidget)
          ? () => focusThisField(cloneRowReference(), columnIndex)
          : null,
      focusThisNonEditingField: (enableTouchMode && !showEditingWidget)
          ? () {
              focusThisField(cloneRowReference(), columnIndex);
            }
          : null,
      cancelEdit: (enableTouchMode && showEditingWidget)
          ? () => cancelRow(cloneRowReference())
          : null,
      edit: (enableTouchMode && !showEditingWidget)
          ? () => tapToEdit(cloneRowReference(), columnIndex)
          : null,
      updateFocusCache: (UpdateFocusNodeCallBacks updateFocusNodeCallBacks,
              {required Object identity}) =>
          _updateFocusCache(
              cloneRowReference(), columnIndex, updateFocusNodeCallBacks,
              identity: identity),
      clearFocusCache: ({required Object identity}) =>
          _clearFocusCache(cloneRowReference(), columnIndex, identity: identity),
      debugMessage: () => "row: " + cloneRowReference().value.toString(),
    );

    [LoggerName.focusCache].info(() => checkFocus(cloneRowReference(), columnIndex)
        ? ('building focus : ' +
            'row: ' +
            cloneRowReference().value.toString() +
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
        cloneRowReference().value.toString() +
        ' | column: ' +
        columnIndex.toString());

    return DataCell(
      getColumnsQuery().getChildCallBack(columnIndex).call(
        focused:
            enableTouchMode ? checkFocus(cloneRowReference(), columnIndex) : false,
        getCurrentValue(cloneRowReference(), columnIndex),
        isEditing: showEditingWidget,
        onChanged: (value) {
          setEditingValue(
              cloneRowReference(), columnIndex, value as Comparable<dynamic>?);
        },
        touchEditCallBacks: touchEditCallBacks,
      ),
      onDoubleTap: touchEditCallBacks.edit,
      onTap: touchEditCallBacks.focusThisNonEditingField,
    );
  }
}
