import 'package:dynamic_table/dynamic_table_source/dynamic_table_columns_query.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';
import 'package:dynamic_table/dynamic_table_source/shifting_map.dart';

class DynamicTableEditingValues {
  DynamicTableEditingValues({required this.columnsQuery});

  Map<int, List<Comparable<dynamic>?>> _editingValues = {};
  final DynamicTableColumnsQuery columnsQuery;

  void shiftKeys(Map<int, int> shiftData, int dataLength) {
    _editingValues.shiftKeys(shiftData, dataLength);
  }

  bool contains(Reference<int> row) {
    return _editingValues.containsKey(row.value);
  }

  void cache(Reference<int> row, List<Comparable<dynamic>?> values) {
    setDefaultIfAbsent(row, currentValues: values);
  }

  void clear(Reference<int> row) {
    _editingValues.remove(row.value);
  }

  Comparable<dynamic>? getEditingValue(Reference<int> row, int column) {
    return _editingValues[row.value]?[column];
  }

  List<Comparable<dynamic>?> getEditingValues(Reference<int> row) {
    List<Comparable<dynamic>?> editingValues = [];
    for (int column in List.generate(columnsQuery.getColumnsLength(), (index) => index)) {
      editingValues.add(getEditingValue(row, column));
    }
    return editingValues;
  }

  void setEditingValue(
      Reference<int> row, int column, Comparable<dynamic>? value) {
    setDefaultIfAbsent(row);
    _editingValues[row.value]![column] = value;
  }

  void setDefaultIfAbsent(Reference<int> row,
      {List<Comparable<dynamic>?>? currentValues}) {
    void fillEditingValuesIfAbsent(Reference<int> row,
        {List<Comparable<dynamic>?>? currentValues}) {
      if (_editingValues[row.value] != null) return;
      _editingValues[row.value] =
          currentValues ?? List.filled(columnsQuery.getColumnsLength(), null);
    }

    fillEditingValuesIfAbsent(row, currentValues: currentValues);

    columnsQuery.setDefaultIfAbsent((column) => _editingValues[row.value]![column], (column, value) { _editingValues[row.value]![column] = value; });
  }

  bool isDropdownColumnAndHasNoDropdownValues(
      Reference<int> row, int columnIndex) {
    return columnsQuery.isDropdownColumn(columnIndex) &&
        !columnsQuery.hasDropdownValues((int columnIndex) => getEditingValue(row, columnIndex), columnIndex);
  }

  bool ifDropdownColumnThenHasDropdownValues(
      Reference<int> row, int columnIndex) {
    return !columnsQuery.isDropdownColumn(columnIndex) ||
        columnsQuery.hasDropdownValues((int columnIndex) => getEditingValue(row, columnIndex), columnIndex);
  }
}
