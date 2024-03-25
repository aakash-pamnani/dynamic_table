import 'package:dynamic_table/dynamic_input_type/dynamic_table_input_type.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_column.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_view.dart';
import 'package:flutter/material.dart';

class DynamicTableColumnsQuery {
  DynamicTableColumnsQuery(List<DynamicTableDataColumn> columns)
      : _columns = List.of(columns) {
    for (int i = 0; i < columns.length; i++) {
      if (columns[i].dynamicTableInputType.dependentOn != null) {
        int dependent = (columns[i].dynamicTableInputType
                as DynamicTableDependentDropDownInput)
            .dependentOn!;
        if (_dependentOn[dependent] == null) {
          _dependentOn[dependent] = [];
        }
        _dependentOn[dependent]!.add(i);
      }
    }
  }
  final List<DynamicTableDataColumn> _columns;
  //{1:[3,4]} 3 and 4th column are dependent on 1st column
  final Map<int, List<int>> _dependentOn = {};

  int getColumnsLength() => _columns.length;
  bool isColumnEditable(int columnIndex) => _columns[columnIndex].isEditable;
  int getKeyColumnIndex() {
    var column = _columns.where((column) => column.isKeyColumn).first;
    return _columns.indexOf(column);
  }

  DynamicTableInputType _getInputType(int columnIndex) =>
      _columns[columnIndex].dynamicTableInputType;

  Widget Function(
    Object? value, {
    required bool isEditing,
    dynamic Function(Object?)? onChanged,
    TouchEditCallBacks touchEditCallBacks,
    bool focused,
  }) getChildCallBack(int columnIndex) {
    return _getInputType(columnIndex).getChild;
  }

  bool isDropdownColumn(int columnIndex) {
    final DynamicTableInputType inputType = _getInputType(columnIndex);
    return inputType is DynamicTableDropDownInput<Comparable<dynamic>> ||
        inputType is DynamicTableDependentDropDownInput<Comparable<dynamic>,
            Comparable<dynamic>>;
  }

  bool hasDropdownValues(
      Comparable<dynamic>? getEditingValue(int column), int columnIndex) {
    final DynamicTableInputType inputType = _getInputType(columnIndex);
    if (inputType is DynamicTableDropDownInput<Comparable<dynamic>>) {
      return inputType.hasSelectionValues();
    }
    if (inputType is DynamicTableDependentDropDownInput<Comparable<dynamic>,
        Comparable<dynamic>>) {
      final int dependentOnColumnIndex = inputType.dependentOnColumn;
      final Comparable<dynamic>? dependentOnColumnSelectedValue =
          getEditingValue(dependentOnColumnIndex);
      return dependentOnColumnSelectedValue != null &&
          inputType.hasSelectionValues(dependentOnColumnSelectedValue);
    }
    return false;
  }

  void setDefaultIfAbsent(Comparable<dynamic>? getEditingValue(int column),
      void setEditingValue(int column, Comparable<dynamic>? value)) {
    _columns
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

      if (getEditingValue(columnIndex) == null) {
        setEditingValue(
            columnIndex,
            (dynamicTableInputType
                    as DynamicTableDropDownInput<Comparable<dynamic>>)
                .getFirstValue());
      }
    });

    _columns
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

      if ((dynamicTableInputType as DynamicTableDependentDropDownInput<
                  Comparable<dynamic>, Comparable<dynamic>>)
              .setDefaultDependentValue(
                  getEditingValue(dynamicTableInputType.dependentOn!)) ||
          getEditingValue(columnIndex) == null) {
        setEditingValue(columnIndex, (dynamicTableInputType).getFirstValue());
      }
    });
  }

  List<DataColumn> toDataColumn(
      // ignore: avoid_positional_boolean_parameters
      {void Function(int column, bool order)? onSort}) {
    return _columns.map((e) {
      return DataColumn(
          label: e.label,
          numeric: e.numeric,
          tooltip: e.tooltip,
          onSort: onSort);
    }).toList();
  }
}
