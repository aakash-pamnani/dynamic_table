import 'package:dynamic_table/dynamic_table_source/dynamic_table_editing_values.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_shiftable_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_source.dart';

mixin DynamicTableEditables
    implements DynamicTableSourceView, DynamicTableSourceConfig {
  DynamicTableShiftableData getData();
  DynamicTableEditingValues getEditingValues();

  void shiftEditingValues(Map<int, int> shiftData) {
    getEditingValues().shiftKeys(shiftData, getDataLength());
  }

  bool isSaved(int index) {
    return !getEditingValues().contains(index);
  }

  void editRow(int index) {
    if (getData().isEditing(index)) {
      return;
    }

    if (editOneByOne && !getData().isEditingRowsCountZero()) {
      if (!autoSaveRowsEnabled || !autoSaveRows()) {
        return;
      }
    }

    if (!(onRowEdit?.call(index, getData().getSavedValues(index)) ?? true)) {
      return;
    }

    getData().markAsEditing(index);
    getEditingValues().setDefaultIfAbsent(index, currentValues: getCurrentValues(index));
  }

  void updateSortByColumnIndex(int sortByColumnIndex) {
    if (sortByColumnIndex < 0 || sortByColumnIndex >= getColumnsLength()) {
      throw Exception('Index out of bounds');
    }
    getData().updateSortByColumnIndex(sortByColumnIndex);
  }

  void unmarkFromEditing(int index) {
    if (!getData().isEditing(index)) return;
    getData().unmarkFromEditing(index);
  }

  void unmarkFromEditingAndClearEditingValues(int index) {
    unmarkFromEditing(index);
    getEditingValues().clear(index);
  }

  void insertRow(int index, {List<Comparable<dynamic>?>? values, bool isEditing = false}) {
    if (values != null && values.length != getColumnsLength()) {
      throw Exception('Values length must match columns');
    }
    if (index < 0 || index > getDataLength()) {
      throw Exception('Index out of bounds');
    }

    getData().insert(index);
    if (values != null) getEditingValues().cache(index, values);
    if (isEditing) editRow(index);
  }

  void addRow() {
    insertRow(0, isEditing: true);
  }

  void addRowLast() {
    insertRow(getDataLength(), isEditing: true);
  }

  void addRowWithValues(List<Comparable<dynamic>?> values, {bool isEditing = false}) {
    insertRow(0, values: values, isEditing: isEditing);
  }

  void deleteRow(int index) {
    if (index < 0 || index >= getDataLength()) {
      throw Exception('Index out of bounds');
    }
    if (!(onRowDelete?.call(index, getData().getSavedValues(index)) ?? true))
      return;
    getData().removeAt(index);
  }

  void deleteAllRows() {
    for (int index in List.generate(getDataLength(), (index) => index)) {
      deleteRow(index);
    }
  }

  void deleteSelectedRows() {
    for (int index = getDataLength() - 1; index >= 0; index--) {
      if (getData().isSelected(index)) {
        deleteRow(index);
      }
    }
  }

  void cancelRow(int row) {
    unmarkFromEditingAndClearEditingValues(row);
    if (getData().isEmpty(row)) {
      deleteRow(row);
    }
  }

  void updateRow(int index, List<Comparable<dynamic>?> values) {
    if (values.length != getColumnsLength()) {
      throw Exception('Values length must match columns');
    }
    if (index < 0 || index >= getDataLength()) {
      throw Exception('Index out of bounds');
    }
    getData().updateRow(index, values);
    unmarkFromEditingAndClearEditingValues(index);
  }

  void updateRowsByKeyByDiffChecking(Map<Comparable<dynamic>, List<Comparable<dynamic>?>> rows) {
    for (Comparable<dynamic> key in rows.keys) {
      int? row = getData().getRowIndexOfKey(key);
      if (rows[key] == null) continue;
      if (!getData().hasChangedOrNew(key, rows[key]!)) continue;
      if (row == null) {
        row = getDataLength();
        insertRow(row);
      }
      updateRow(row, rows[key]!);
    }
  }

  void updateAllRows(List<List<Comparable<dynamic>?>> values) {
    if (values.length != getDataLength()) {
      throw Exception('Values length must match data rows length');
    }
    for (int i = 0; i < values.length; i++) {
      updateRow(i, values[i]);
    }
  }

  bool saveRow(int row) {
    List<Comparable<dynamic>?> newValue = getCurrentValues(row);

    var response =
        onRowSave?.call(row, getData().getSavedValues(row), newValue);
    if (onRowSave != null && response == null) {
      return false;
    }
    if (response != null) {
      newValue = response;
    }

    updateRow(row, newValue);
    return true;
  }

  bool autoSaveRows() {
    return getData().getEditingRowIndices().map((index) {
      return saveRow(index);
    }).every((e) => e);
  }

  void selectRow(int index, {required bool isSelected}) {
    if (index < 0 || index >= getDataLength()) {
      throw Exception('Index out of bounds');
    }
    if (!selectable) {
      return;
    }
    if (getData().isSelected(index) == isSelected) return;
    getData().selectRow(index, isSelected: isSelected);
  }

  void selectAllRows({required bool isSelected}) {
    for (int i = 0; i < getDataLength(); i++) {
      selectRow(i, isSelected: isSelected);
    }
  }

  List<Comparable<dynamic>?> getCurrentValues(int row) {
    List<Comparable<dynamic>?> newValue = [];
    for (int column = 0; column < getColumnsLength(); column++) {
      newValue.add(getCurrentValue(row, column));
    }
    return newValue;
  }

  Comparable<dynamic>? getCurrentValue(int row, int column) {
    return getEditingValues().getEditingValue(row, column) ??
        getData().getSavedValue(row, column);
  }

  void setEditingValue(int row, int column, Comparable<dynamic>? value) {
    getEditingValues().setEditingValue(row, column, value);
  }
}
