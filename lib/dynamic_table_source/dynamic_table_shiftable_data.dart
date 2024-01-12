import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_cell.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_row.dart';
import 'package:dynamic_table/dynamic_table_source/shifting_map.dart';

/**
 * data has the saved values for each row, state information such as isEditing, isSaved and isSelected are also contained in data
 * editingValues has the current edited values of a row
 * keyColumn holds the column index which is considered the key of the data in the table
 */

class DynamicTableShiftableData {
  DynamicTableShiftableData({void Function(Map<int, int> shiftData)? this.onShift, required this.keyColumnIndex, required this.columnsLength}) : sortByColumnIndex = keyColumnIndex;
  
  void loadInitialData(Map<Comparable<dynamic>, List<Comparable<dynamic>?>> data,) {
    _data.addAll(data.values.toList().asMap().map((index, values) => MapEntry(index, DynamicTableDataRow(index: index, cells: List.generate(values.length, (index) => DynamicTableDataCell(value: values[index])))),).values.toList());
    _data.asMap().forEach((row, values) { cacheIndexKeyMapping(row, (column) => values.cells[column].value); });
    sort();
  }

  final List<DynamicTableDataRow> _data = [];
  final int keyColumnIndex;
  final int columnsLength;
  final void Function(Map<int, int> shiftData)? onShift;
  int sortByColumnIndex;

  final Map<int, dynamic> indexKeyMap = {};

  void cacheIndexKeyMapping(int row, Comparable<dynamic>? getValueByColumn(int column)) {
    if (getValueByColumn(keyColumnIndex) != null) {
      indexKeyMap[row] = getValueByColumn(keyColumnIndex);
    }
  }

  void shift() {
    int getNewIndex(DynamicTableDataRow row) => _data.indexOf(row);
    int getOldIndex(DynamicTableDataRow row) => row.index;
    void updateToNewIndex(DynamicTableDataRow row) =>
        row.index = getNewIndex(row);
    List<DynamicTableDataRow> getData() => List.of(_data);

    Map<int, int> shiftData = {};
    for (DynamicTableDataRow data in getData()) {
      if (getOldIndex(data) != getNewIndex(data)) {
        shiftData[getOldIndex(data)] = getNewIndex(data);
        updateToNewIndex(data);
      }
    }
    indexKeyMap.shiftKeys(shiftData, getDataLength());
    onShift?.call(shiftData);
  }

  void insert(int index) {
    _data.insert(
        index,
        DynamicTableDataRow(
            index: index,
            cells:
                List.generate(columnsLength, (columnIndex) => DynamicTableDataCell(value: null))));
    shift();
  }

  void removeAt(int index) {
    _data.removeAt(index);
    shift();
  }

  void sort() {
    _sortByColumn(sortByColumnIndex);
  }

  void _sortByColumn(int sortColumnIndex) {
    _data.sort((a, b) {
      if (b.cells[sortColumnIndex].value == null &&
          a.cells[sortColumnIndex].value == null) return 0;
      if (b.cells[sortColumnIndex].value == null) return -1;
      if (a.cells[sortColumnIndex].value == null) return 1;
      return a.cells[sortColumnIndex].value!
          .compareTo(b.cells[sortColumnIndex].value!);
    });
    shift();
  }

  void updateSortByColumnIndex(int sortByColumnIndex) {
    this.sortByColumnIndex = sortByColumnIndex;
    sort();
  }

  void updateRow(int row, List<Comparable<dynamic>?> values) {
    for (int index = 0; index < columnsLength; index++) {
      _data[row].cells[index].value = values[index];
    }
    cacheIndexKeyMapping(row, (column) => values[column]);
    sort();
  }

  void markAsEditing(int index) {
    _data[index].isEditing = true;
  }

  void unmarkFromEditing(int index) {
    _data[index].isEditing = false;
  }

  void selectRow(int index, {required bool isSelected}) {
    _data[index].selected = isSelected;
  }

  bool isEditing(int index) {
    return _data[index].isEditing;
  }

  bool isSelected(int index) {
    return _data[index].selected;
  }

  bool isEmpty(int row) {
    return _data[row].cells.every((cell) => cell.value == null);
  }

  bool hasChangedOrNew(Comparable<dynamic> key, List<Comparable<dynamic>?> values) {
    int? row = getRowIndexOfKey(key);
    if (row == null) return true;
    List<Comparable<dynamic>?> oldValues = getSavedValues(row);
    if (!List.generate(columnsLength, (index) => index).every((column) => values[column] == oldValues[column])) return true;
    return false;
  }

  int? getRowIndexOfKey(Comparable<dynamic> key) {
    int row = indexKeyMap.keys.firstWhere((index) => indexKeyMap[index] == key, orElse: () => -1);
    return row == -1? null: row;
  }

  Comparable<dynamic>? getSavedValue(int row, int column) {
    return _data[row].cells[column].value;
  }

  List<Comparable<dynamic>?> getSavedValues(int row) {
    return _data[row]
        .cells
        .map(
          (cell) => cell.value,
        )
        .toList();
  }

  List<List<Comparable<dynamic>?>> getAllSavedValues() {
    List<List<Comparable<dynamic>?>> result = [];
    for (int row in List.generate(getDataLength(), (index) => index)) {
      result.add(getSavedValues(row));
    }
    return result;
  }

  List<List<Comparable<dynamic>?>> getAllSelectedSavedValues() {
    return _data.where((element) => element.selected).toList().map((e) {
      return e.cells.map((e) {
        return e.value;
      }).toList();
    }).toList();
  }

  int getEditingRowsCount() {
    return _data.where((element) => element.isEditing).length;
  }

  bool isEditingRowsCountZero() {
    return getEditingRowsCount() == 0;
  }

  List<int> getEditingRowIndices() {
    return _data
        .where((element) => element.isEditing)
        .map(
          (e) => e.index,
        )
        .toList();
  }

  int getSelectedRowsCount() {
    return _data.where((element) => element.selected).length;
  }

  int getDataLength() {
    return _data.length;
  }
}
