import 'package:dynamic_table/dynamic_table_source/dynamic_table_editing_values.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_shiftable_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_source.dart';

mixin DynamicTableEditables
    implements DynamicTableSourceView, DynamicTableSourceConfig {
  DynamicTableShiftableData getData();
  DynamicTableEditingValues getEditingValues();

  void onShift(Map<int, int> shiftData) {
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

  void unmarkFromEditing(int index) {
    if (!getData().isEditing(index)) return;
    getData().unmarkFromEditing(index);
  }

  void unmarkFromEditingAndClearEditingValues(int index) {
    unmarkFromEditing(index);
    getEditingValues().clear(index);
  }

  void insertRow(int index, {List<dynamic>? values, bool isEditing = false}) {
    if (values != null && values.length != getColumnsLength()) {
      throw Exception('Values length must match columns');
    }
    if (index < 0 || index > getDataLength()) {
      throw Exception('Index out of bounds');
    }

    getData().insert(index, getColumnsLength());
    if (values != null) getEditingValues().cache(index, values);
    if (isEditing) editRow(index);
  }

  void addRow() {
    insertRow(0, isEditing: true);
  }

  void addRowLast() {
    insertRow(getDataLength(), isEditing: true);
  }

  void addRowWithValues(List<dynamic> values, {bool isEditing = false}) {
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

  void updateRow(int index, List<dynamic> values) {
    if (values.length != getColumnsLength()) {
      throw Exception('Values length must match columns');
    }
    getData().updateRow(index, getColumnsLength(), values);
    unmarkFromEditingAndClearEditingValues(index);
  }

  void updateRows(Map<dynamic, List<dynamic>> diff) {
    for (dynamic key in diff.keys) {
      int? row = getData().getRowIndexOfKey(key);
      if (row == null || diff[key] == null) continue; //TODO: insert row if the row for the key not exists already
      updateRow(row, diff[key]!);
    }
  }

  void updateAllRows(List<List<dynamic>> values) {
    if (values.length != getDataLength()) {
      throw Exception('Values length must match data rows length');
    }
    for (int i = 0; i < values.length; i++) {
      updateRow(i, values[i]);
    }
  }

  bool saveRow(int row) {
    List newValue = getCurrentValues(row);

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

  List<dynamic> getCurrentValues(int row) {
    List newValue = [];
    for (int column = 0; column < getColumnsLength(); column++) {
      newValue.add(getCurrentValue(row, column));
    }
    return newValue;
  }

  dynamic getCurrentValue(int row, int column) {
    return getEditingValues().getEditingValue(row, column) ??
        getData().getSavedValue(row, column);
  }

  void setEditingValue(int row, int column, dynamic value) {
    getEditingValues().setEditingValue(row, column, value);
  }
}
