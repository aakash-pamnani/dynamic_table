import 'package:dynamic_table/dynamic_table_source/dynamic_table_editing_values.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_shiftable_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_source.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';

mixin DynamicTableEditables
    implements DynamicTableSourceView, DynamicTableSourceConfig {
  DynamicTableShiftableData getData();
  DynamicTableEditingValues getEditingValues();

  void shiftEditingValues(Map<int, int> shiftData) {
    getEditingValues().shiftKeys(shiftData, getDataLength());
  }

  bool isSaved(Reference<int> index) {
    return !getEditingValues().contains(index);
  }

  void editRow(Reference<int> index) {
    if (getData().isEditing(index)) {
      return;
    }

    if (editOneByOne && !getData().isEditingRowsCountZero()) {
      if (!autoSaveRowsEnabled || !autoSaveRows()) {
        return;
      }
    }

    if (!(onRowEdit?.call(getData().getKeyOfRowIndex(index), getData().getSavedValues(index)) ?? true)) {
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

  void unmarkFromEditing(Reference<int> index) {
    if (!getData().isEditing(index)) return;
    getData().unmarkFromEditing(index);
  }

  void unmarkFromEditingAndClearEditingValues(Reference<int> index) {
    unmarkFromEditing(index);
    getEditingValues().clear(index);
  }

  void insertRow(Reference<int> index, {List<Comparable<dynamic>?>? values, bool isEditing = false}) {
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
    insertRow(Reference<int>(value: 0), isEditing: true);
  }

  void addRowLast() {
    insertRow(Reference<int>(value: getDataLength()), isEditing: true);
  }

  void addRowWithValues(List<Comparable<dynamic>?> values, {bool isEditing = false}) {
    insertRow(Reference<int>(value: 0), values: values, isEditing: isEditing);
  }

  void deleteRow(Reference<int> index) {
    if (index < 0 || index >= getDataLength()) {
      throw Exception('Index out of bounds');
    }
    if (!(onRowDelete?.call(getData().getKeyOfRowIndex(index), getData().getSavedValues(index)) ?? true)) {
      return;
    }
    getData().removeAt(index);
  }

  void deleteAllRows() {
    while (getDataLength() != 0) {
      deleteRow(Reference<int>(value: 0));
    }
  }

  void deleteSelectedRows() {
    for (Reference<int> row in getData().getAllSelectedRowIndices()) {
      if (getData().isSelected(row)) {
        deleteRow(row);
      }
    }
  }

  void cancelRow(Reference<int> row) {
    unmarkFromEditingAndClearEditingValues(row);
    if (getData().isEmpty(row)) {
      deleteRow(row);
    }
  }

  void updateRow(Reference<int> index, List<Comparable<dynamic>?> values) {
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
      Reference<int>? row = getData().getRowIndexOfKey(key);
      if (rows[key] == null) continue;
      if (!getData().hasChangedOrNew(key, rows[key]!)) continue;
      if (row == null) {
        row = Reference<int>(value: getDataLength());
        insertRow(row);
      }
      updateRow(row, rows[key]!);
    }
  }

  bool saveRow(Reference<int> row) {
    List<Comparable<dynamic>?> newValue = getCurrentValues(row);

    var response =
        onRowSave?.call(getData().getKeyOfRowIndex(row), getData().getSavedValues(row), newValue);
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
    return getData().getAllEditingRowIndices().map((row) {
      return saveRow(row);
    }).every((e) => e);
  }

  void selectRow(Reference<int> index, {required bool isSelected}) {
    if (index < 0 || index >= getDataLength()) {
      throw Exception('Index out of bounds');
    }
    if (!selectable) {
      return;
    }
    if (getData().isSelected(index) == isSelected) return;
    getData().selectRow(index, isSelected: isSelected);
  }

  void selectAllRows({required bool isSelected, bool filterByIndex(int index)? }) {
    for (var row in isSelected? getData().getAllUnSelectedRowIndices(filterByIndex: filterByIndex) : getData().getAllSelectedRowIndices(filterByIndex : filterByIndex)) {
      selectRow(row, isSelected: isSelected);
    }
  }

  List<Comparable<dynamic>?> getCurrentValues(Reference<int> row) {
    List<Comparable<dynamic>?> newValue = [];
    for (int column = 0; column < getColumnsLength(); column++) {
      newValue.add(getCurrentValue(row, column));
    }
    return newValue;
  }

  Comparable<dynamic>? getCurrentValue(Reference<int> row, int column) {
    return getEditingValues().getEditingValue(row, column) ??
        getData().getSavedValue(row, column);
  }

  void setEditingValue(Reference<int> row, int column, Comparable<dynamic>? value) {
    getEditingValues().setEditingValue(row, column, value);
  }
}
