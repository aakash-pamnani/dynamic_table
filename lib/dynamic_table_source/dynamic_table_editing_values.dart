import 'package:dynamic_table/dynamic_input_type/dynamic_table_input_type.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_column.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';
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

  Map<int, List<Comparable<dynamic>?>> _editingValues = {};
  final List<DynamicTableDataColumn> columns;
  //{1:[3,4]} 3 and 4th column are dependent on 1st column
  final Map<int, List<int>> dependentOn = {};

  int getColumnsLength() {
    return columns.length;
  }

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
    for (int column in List.generate(getColumnsLength(), (index) => index)) {
      editingValues.add(getEditingValue(row, column));
    }
    return editingValues;
  }

  void setEditingValue(Reference<int> row, int column, Comparable<dynamic>? value) {
    setDefaultIfAbsent(row);
    _editingValues[row.value]![column] = value;
  }

  void setDefaultIfAbsent(Reference<int> row, { List<Comparable<dynamic>?>? currentValues }) {
    void fillEditingValuesIfAbsent(Reference<int> row, { List<Comparable<dynamic>?>? currentValues }) {
      if (_editingValues[row.value] != null) return;
      _editingValues[row.value] = currentValues ?? List.filled(getColumnsLength(), null);
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

      if (_editingValues[row.value]![columnIndex] == null) {
        _editingValues[row.value]![columnIndex] =
            (dynamicTableInputType as DynamicTableDropDownInput<Comparable<dynamic>>)
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
          (dynamicTableInputType)
                  .dependentValue !=
              _editingValues[row.value]![dynamicTableInputType.dependentOn!]) {
        (dynamicTableInputType)
                .dependentValue =
            _editingValues[row.value]![dynamicTableInputType.dependentOn!];
        _editingValues[row.value]![columnIndex] =
            (dynamicTableInputType as DynamicTableDependentDropDownInput<Comparable<dynamic>, Comparable<dynamic>>)
                .getFirstValue();
      }
    });
  }

  bool isDropdownColumnAndHasNoDropdownValues(Reference<int> row, int columnIndex) {
    bool isDropdownColumn() {
      return columns[columnIndex].dynamicTableInputType is DynamicTableDropDownInput<Comparable<dynamic>>
        || columns[columnIndex].dynamicTableInputType is DynamicTableDependentDropDownInput<Comparable<dynamic>, Comparable<dynamic>>;
    }
    bool hasDropdownValues() {
      if (columns[columnIndex].dynamicTableInputType is DynamicTableDropDownInput<Comparable<dynamic>>) {
        return (columns[columnIndex].dynamicTableInputType as DynamicTableDropDownInput<Comparable<dynamic>>).hasSelectionValue();
      }
      if (columns[columnIndex].dynamicTableInputType is DynamicTableDependentDropDownInput<Comparable<dynamic>, Comparable<dynamic>>) {
        final int dependentOnColumnIndex = (columns[columnIndex].dynamicTableInputType as DynamicTableDependentDropDownInput<Comparable<dynamic>, Comparable<dynamic>>).dependentOnColumn;
        final Comparable<dynamic>? dependentOnColumnSelectedValue = getEditingValue(row, dependentOnColumnIndex);
        return dependentOnColumnSelectedValue != null && (columns[columnIndex].dynamicTableInputType as DynamicTableDependentDropDownInput<Comparable<dynamic>, Comparable<dynamic>>).hasSelectionValue(dependentOnColumnSelectedValue);
      }
      return false;
    }
    return isDropdownColumn() && !hasDropdownValues();
  }
}
