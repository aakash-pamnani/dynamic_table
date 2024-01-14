import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_cell.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_row.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';
import 'package:dynamic_table/dynamic_table_source/shifting_map.dart';
import 'package:flutter/foundation.dart';

/**
 * data has the saved values for each row, state information such as isEditing, isSaved and isSelected are also contained in data
 * editingValues has the current edited values of a row
 * keyColumn holds the column index which is considered the key of the data in the table
 */

extension FetchingFirstOrNull<T> on Iterable<T> {
  T? firstOrNull() {
    if (this.isNotEmpty) {
      return this.first;
    } else {
      return null;
    }
  }
}

class FetchTillEmptyIterator<T> implements Iterator<T> {
  T? _current;
  T? Function () _fetch;

  FetchTillEmptyIterator(T? Function () fetch) : _fetch = fetch;

  @override
  T get current { if (_current != null) return _current!; throw Exception('No Value'); }

  @override
  bool moveNext() {
    _current = _fetch();
    return _current != null;
  }
}

class DynamicTableIndicesFetchTillEmptyQueryResult with Iterable<Reference<int>> {
  Reference<int>? Function () _fetch;

  DynamicTableIndicesFetchTillEmptyQueryResult(Reference<int>? Function () fetch) : _fetch = fetch;

  FetchTillEmptyIterator<Reference<int>> get iterator => FetchTillEmptyIterator(_fetch);
  
}

class DynamicTableShiftableData {
  DynamicTableShiftableData(
      Map<Comparable<dynamic>, List<Comparable<dynamic>?>> data,
      {void Function(Map<int, int> shiftData)? this.onShift,
      required this.keyColumnIndex,
      required this.columnsLength})
      : sortByColumnIndex = keyColumnIndex {
    void _loadInitialData(
      Map<Comparable<dynamic>, List<Comparable<dynamic>?>> data,
    ) {
      var dataValues = _sortByColumn(data.values.toList(), sortByColumnIndex,
          (value, column) => value[column]);
      _data.addAll(dataValues
          .asMap()
          .map(
            (index, values) => MapEntry(
                index,
                DynamicTableDataRow(
                    index: index,
                    cells: List.generate(
                        values.length,
                        (index) =>
                            DynamicTableDataCell(value: values[index])))),
          )
          .values
          .toList());
      _data.asMap().forEach((row, values) {
        _cacheIndexKeyMapping(
            Reference<int>(value: row), (column) => values.cells[column].value);
      });
    }

    _loadInitialData(data);
  }

  final List<DynamicTableDataRow> _data = [];
  final int keyColumnIndex;
  final int columnsLength;
  final void Function(Map<int, int> shiftData)? onShift;
  int sortByColumnIndex;

  final Map<int, Comparable<dynamic>> indexKeyMap = {};

  static List<U> _sortByColumn<U>(List<U> data, int sortColumnIndex,
      Comparable<dynamic>? parseValue(U value, int column)) {
    data.sort((a, b) {
      Comparable<dynamic>? parsedAValue = parseValue(a, sortColumnIndex);
      Comparable<dynamic>? parsedBValue = parseValue(b, sortColumnIndex);
      if (parsedBValue == null && parsedAValue == null) return 0;
      if (parsedBValue == null) return -1;
      if (parsedAValue == null) return 1;
      return parsedAValue.compareTo(parsedBValue);
    });
    return data;
  }

  void _cacheIndexKeyMapping(
      Reference<int> row, Comparable<dynamic>? getValueByColumn(int column)) {
    if (getValueByColumn(keyColumnIndex) != null) {
      indexKeyMap[row.value] = getValueByColumn(keyColumnIndex)!;
    }
  }

  void _shift({Reference<int>? shiftableRowReference}) {
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
    if (shiftableRowReference!=null && shiftData[shiftableRowReference.value]!=null) shiftableRowReference.update(shiftData[shiftableRowReference.value]!);
    print("inner shift" + shiftData.toString());
    onShift?.call(shiftData);
  }

  void _sort({Reference<int>? shiftableRowReference}) {
    _sortByColumn(
        _data, sortByColumnIndex, (value, column) => value.cells[column].value);
    _shift(shiftableRowReference: shiftableRowReference);
  }

  // shifting
  void insert(Reference<int> row) {
    _data.insert(
        row.value,
        DynamicTableDataRow(
            index: row.value,
            cells: List.generate(columnsLength,
                (columnIndex) => DynamicTableDataCell(value: null))));
    _shift(shiftableRowReference: row);
  }

  // shifting
  void removeAt(Reference<int> row) {
    _data.removeAt(row.value);
    _shift(shiftableRowReference: row);
  }

  // shifting
  void updateSortByColumnIndex(int sortByColumnIndex) {
    this.sortByColumnIndex = sortByColumnIndex;
    _sort();
  }

  // shifting
  void updateRow(Reference<int> row, List<Comparable<dynamic>?> values) {
    for (int index = 0; index < columnsLength; index++) {
      _data[row.value].cells[index].value = values[index];
    }
    _cacheIndexKeyMapping(row, (column) => values[column]);
    _sort(shiftableRowReference: row);
  }

  void markAsEditing(Reference<int> row) {
    _data[row.value].isEditing = true;
  }

  void unmarkFromEditing(Reference<int> row) {
    _data[row.value].isEditing = false;
  }

  void selectRow(Reference<int> row, {required bool isSelected}) {
    _data[row.value].selected = isSelected;
  }

  bool isEditing(Reference<int> row) {
    return _data[row.value].isEditing;
  }

  bool isSelected(Reference<int> row) {
    return _data[row.value].selected;
  }

  bool isEmpty(Reference<int> row) {
    return _data[row.value].cells.every((cell) => cell.value == null);
  }

  bool hasChangedOrNew(
      Comparable<dynamic> key, List<Comparable<dynamic>?> values) {
    Reference<int>? row = getRowIndexOfKey(key);
    if (row == null) return true;
    List<Comparable<dynamic>?> oldValues = getSavedValues(row);
    if (!List.generate(columnsLength, (index) => index)
        .every((column) => values[column] == oldValues[column])) return true;
    return false;
  }

  Reference<int>? getRowIndexOfKey(Comparable<dynamic> key) {
    int row = indexKeyMap.keys
        .firstWhere((index) => indexKeyMap[index] == key, orElse: () => -1);
    return row == -1 ? null : Reference<int>(value: row);
  }

  Comparable<dynamic>? getKeyOfRowIndex(Reference<int> row) {
    return indexKeyMap[row.value];
  }

  Comparable<dynamic>? getSavedValue(Reference<int> row, int column) {
    return _data[row.value].cells[column].value;
  }

  List<Comparable<dynamic>?> getSavedValues(Reference<int> row) {
    return _data[row.value]
        .cells
        .map(
          (cell) => cell.value,
        )
        .toList();
  }

  List<List<Comparable<dynamic>?>> getAllSavedValues() {
    List<List<Comparable<dynamic>?>> result = [];
    for (var row in List.generate(
        getDataLength(), (index) => Reference<int>(value: index))) {
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

  void logEditingRowIndices() {
    var indices = _data
        .where((element) => element.isEditing)
        .map(
          (e) => e.index,
        )
        .toList();
    if (kDebugMode) {
      print('editing rows: ' + indices.toString());
    }
  }

  DynamicTableIndicesFetchTillEmptyQueryResult getAllEditingRowIndices() {
    return DynamicTableIndicesFetchTillEmptyQueryResult(() {
      var row = _data
        .where((element) => element.isEditing)
        .firstOrNull()?.index;
      return row != null? Reference<int>(value: row) : null;
    },);
  }

  DynamicTableIndicesFetchTillEmptyQueryResult getAllSelectedRowIndices() {
    return DynamicTableIndicesFetchTillEmptyQueryResult(() {
      var row = _data
        .where((element) => element.selected)
        .firstOrNull()?.index;
      return row != null? Reference<int>(value: row) : null;
    },);
  }

  DynamicTableIndicesFetchTillEmptyQueryResult getAllUnSelectedRowIndices() {
    return DynamicTableIndicesFetchTillEmptyQueryResult(() {
      var row = _data
        .where((element) => !element.selected)
        .firstOrNull()?.index;
      return row != null? Reference<int>(value: row) : null;
    },);
  }

  int getSelectedRowsCount() {
    return _data.where((element) => element.selected).length;
  }

  int getDataLength() {
    return _data.length;
  }
}
