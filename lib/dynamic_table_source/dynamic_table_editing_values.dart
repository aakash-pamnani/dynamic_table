import 'package:dynamic_table/dynamic_input_type/dynamic_table_input_type.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_column.dart';
import 'package:dynamic_table/dynamic_table_source/shifting_map.dart';

class DynamicTableEditingValues {
  DynamicTableEditingValues({required this.columns}) {
    for (int i = 0; i < columns.length; i++) {
      if (columns[i].dynamicTableInputType.dependentOn != null) {
        int dependent = (columns[i].dynamicTableInputType
                as DynamicTableDependentDropDownInput)
            .dependentOn!;
        if (dependentOn[dependent] == null) {
          dependentOn[dependent] = [];
        }
        dependentOn[dependent]!.add(i);
      }
    }
  }

  Map<int, List<dynamic>> _editingValues = {};
  final List<DynamicTableDataColumn> columns;
  //{1:[3,4]} 3 and 4th column are dependent on 1st column
  final Map<int, List<int>> dependentOn = {};

  int getColumnsLength() {
    return columns.length;
  }

  void shiftKeys(Map<int, int> shiftData, int dataLength) {
    _editingValues.shiftKeys(shiftData, dataLength);
  }

  bool contains(int index) {
    return _editingValues.containsKey(index);
  }

  void cache(int index, List<dynamic> values) {
    _editingValues.update(index, (oldValues) => values, ifAbsent: () => values);
  }

  void clear(int index) {
    _editingValues.remove(index);
  }

  dynamic getEditingValue(int row, int column) {
    return _editingValues[row]?[column];
  }

  List<dynamic> getEditingValues(int row) {
    List editingValues = [];
    for (int column in List.generate(getColumnsLength(), (index) => index)) {
      editingValues.add(getEditingValue(row, column));
    }
    return editingValues;
  }

  void setEditingValue(int row, int column, dynamic value) {
    setDefaultIfAbsent(row);
    _editingValues[row]![column] = value;
  }

  void setDefaultIfAbsent(int row, { List<dynamic>? currentValues }) {
    void fillEditingValuesIfAbsent(int index, { List<dynamic>? currentValues }) {
      if (_editingValues[index] != null) return;
      _editingValues[index] = currentValues ?? List.filled(getColumnsLength(), null);
    }

    fillEditingValuesIfAbsent(row, currentValues: currentValues);

    columns
        .asMap()
        .map(
          (key, value) => MapEntry(key, (key, value)),
        )
        .values
        .where((indexedColumn) => (indexedColumn.$2.dynamicTableInputType
            is DynamicTableDropDownInput))
        .forEach((indexedColumn) {
      var dynamicTableInputType = indexedColumn.$2.dynamicTableInputType;
      var columnIndex = indexedColumn.$1;

      if (_editingValues[row]![columnIndex] == null) {
        _editingValues[row]![columnIndex] =
            (dynamicTableInputType as DynamicTableDropDownInput)
                .getFirstValue();
      }
    });

    columns
        .asMap()
        .map(
          (key, value) => MapEntry(key, (key, value)),
        )
        .values
        .where((indexedColumn) =>
            (indexedColumn.$2.dynamicTableInputType.dependentOn != null &&
                indexedColumn.$2.dynamicTableInputType
                    is DynamicTableDependentDropDownInput))
        .forEach((indexedColumn) {
      var dynamicTableInputType = indexedColumn.$2.dynamicTableInputType;
      var columnIndex = indexedColumn.$1;

      if ((dynamicTableInputType as DynamicTableDependentDropDownInput)
                  .dependentValue ==
              null ||
          (dynamicTableInputType as DynamicTableDependentDropDownInput)
                  .dependentValue !=
              _editingValues[row]![dynamicTableInputType.dependentOn!]) {
        (dynamicTableInputType as DynamicTableDependentDropDownInput)
                .dependentValue =
            _editingValues[row]![dynamicTableInputType.dependentOn!];
        _editingValues[row]![columnIndex] =
            (dynamicTableInputType as DynamicTableDependentDropDownInput)
                .getFirstValue();
      }
    });
  }
}
