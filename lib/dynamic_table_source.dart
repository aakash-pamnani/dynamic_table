import 'package:flutter/material.dart';

import 'dynamic_input_type/dynamic_input_type.dart';
import 'dynamic_table_action.dart';
import 'dynamic_table_data_cell.dart';
import 'dynamic_table_data_column.dart';
import 'dynamic_table_data_row.dart';

class DynamicTableSource extends DataTableSource {
  final List<DynamicTableDataRow> data;
  final List<DynamicTableDataColumn> columns;
  // final List<DynamicTableAction> actions;
  final bool showActions;
  final String actionColumnTitle;
  final bool showDeleteAction;
  final bool Function(int index, List<dynamic> row)? onRowEdit;
  final bool Function(int index, List<dynamic> row)? onRowDelete;
  final List<dynamic>? Function(
      int index, List<dynamic> oldValue, List<dynamic> newValue)? onRowSave;
  int _selectedCount = 0;

  DynamicTableSource({
    this.showActions = false,
    this.showDeleteAction = true,
    required this.data,
    required this.columns,
    required this.actionColumnTitle,
    this.onRowEdit,
    this.onRowDelete,
    this.onRowSave,
  }) {
    _selectedCount = data.where((element) => element.selected).length;
  }
  Map<int, List<dynamic>> editingValues = {};
  Map<int, Map<int, DynamicTableInputType>> editingCellsInput = {};

  @override
  void dispose() {
    super.dispose();
    editingCellsInput.forEach((key, value) {
      value.forEach((key, value) {
        value.dispose();
      });
    });
  }

  void insertRow(int index, List<dynamic> values, {bool isEditing = false}) {
    if (values.length != columns.length) {
      throw Exception('Values length must match columns');
    }
    if (isEditing && !showActions) {
      throw Exception(
          'Show actions must be true to make row editable either set isEditing false or set showActions to true');
    }
    if (index < 0 || index > data.length) {
      throw Exception('Index out of bounds');
    }
    data.insert(
        index,
        DynamicTableDataRow(
          index: index,
          isEditing: isEditing,
          cells: columns.map((e) {
            return DynamicTableDataCell(
              value: values[columns.indexOf(e)],
            );
          }).toList(),
        ));
    notifyListeners();
  }

  void addRow() {
    if (!showActions) {
      throw Exception(
          'Show actions must be true to make row editable either use addRowWithValues or set showActions to true');
    }
    data.insert(
      0,
      DynamicTableDataRow(
        index: 0,
        isEditing: true,
        cells: columns.map((e) {
          return DynamicTableDataCell(
            value: null,
            // dynamicTableInputType: e.dynamicTableInputType,
          );
        }).toList(),
      ),
    );

    notifyListeners();
  }

  void addRowWithValues(List<dynamic> values, {bool isEditing = false}) {
    insertRow(0, values, isEditing: isEditing);
  }

  void deleteRow(int index) {
    if (index < 0 || index > data.length) {
      throw Exception('Index out of bounds');
    }
    _selectedCount -= data[index].selected ? 1 : 0;
    data.removeAt(index);
    notifyListeners();
  }

  void deleteAllRows() {
    data.clear();
    _selectedCount = 0;
    notifyListeners();
  }

  void deleteSelectedRows() {
    data.removeWhere((element) => element.selected);
    _selectedCount = 0;
    notifyListeners();
  }

  List<dynamic> getRowByIndex(int index) {
    if (index < 0 || index > data.length) {
      throw Exception('Index out of bounds');
    }
    return data[index].cells.map((e) {
      return e.value;
    }).toList();
  }

  List<List<dynamic>> getSelectedRows() {
    return data.where((element) => element.selected).toList().map((e) {
      return e.cells.map((e) {
        return e.value;
      }).toList();
    }).toList();
  }

  List<List<dynamic>> getAllRows() {
    return data.map((e) {
      return e.cells.map((e) {
        return e.value;
      }).toList();
    }).toList();
  }

  void updateRow(int index, List<dynamic> values) {
    if (values.length != columns.length) {
      throw Exception('Values length must match columns');
    }
    for (int i = 0; i < columns.length; i++) {
      data[index].cells[i].value = values[i];
    }
    notifyListeners();
  }

  void updateAllRows(List<List<dynamic>> values) {
    if (values.length != data.length) {
      throw Exception('Values length must match data rows length');
    }
    for (int i = 0; i < values.length; i++) {
      if (values[i].length != columns.length) {
        throw Exception('Values length must match columns');
      }
    }
    for (int i = 0; i < values.length; i++) {
      updateRow(i, values[i]);
    }
    notifyListeners();
  }

  void selectRow(int index, bool isSelected) {
    if (index < 0 || index > data.length) {
      throw Exception('Index out of bounds');
    }
    if (data[index].selected != isSelected) {
      _selectedCount += isSelected ? 1 : -1;
      assert(_selectedCount >= 0);
      data[index].selected = isSelected;
      notifyListeners();
    }
  }

  void selectAllRows(bool isSeleted) {
    for (int i = 0; i < data.length; i++) {
      selectRow(i, isSeleted);
    }
  }

  @override
  DataRow? getRow(int index) {
    return _buildRow(index);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => _selectedCount;

  DataRow? _buildRow(int index) {
    var datarow = DataRow.byIndex(
      index: index,
      selected: data[index].selected,
      onSelectChanged: (value) {
        if (data[index].selected != value && value != null) {
          _selectedCount += value ? 1 : -1;
          assert(_selectedCount >= 0);
          data[index].selected = value;
          notifyListeners();
        }
        data[index].onSelectChanged?.call(value);
      },
      onLongPress: data[index].onLongPress,
      color: data[index].color,
      cells: _buildRowCells(data[index].cells, index),
    );
    return datarow;
  }

  List<DataCell> _addActionsInCell(
      List<DynamicTableDataCell> cells, int row, int column) {
    List<DynamicTableAction> actions = [];
    List<DataCell> cellsList = [];

    if (showActions) {
      actions.add(
        DynamicTableActionEdit(
          showOnlyOnEditing: false,
          onPressed: () {
            var response = onRowEdit?.call(
                row,
                data[row].cells.map((e) {
                  return e.value;
                }).toList());
            if (response == null || response) {
              data[row].isEditing = !data[row].isEditing;
              notifyListeners();
            }
          },
        ),
      );

      actions.add(
        DynamicTableActionSave(
          showOnlyOnEditing: true,
          onPressed: () {
            List newValue = [];
            List oldValue = cells.map((e) {
              return e.value;
            }).toList();

            for (int i = 0; i < columns.length; i++) {
              if (columns[i].isEditable) {
                newValue.add(
                    editingCellsInput[row]?[i]?.editingValue ?? oldValue[i]);
              } else {
                newValue.add(oldValue[i]);
              }
            }

            var response = onRowSave?.call(row, oldValue, newValue);
            if (onRowSave != null && response == null) {
              return;
            }
            if (response != null) {
              newValue = response;
            }
            for (int i = 0; i < cells.length; i++) {
              data[row].cells[i].value = newValue[i];
            }
            data[row].isEditing = !data[row].isEditing;
            notifyListeners();
            editingCellsInput[row]?.forEach((key, value) {
              value.dispose();
            });
            editingCellsInput.remove(row);
            editingValues.remove(row);
          },
        ),
      );
      actions.add(DynamicTableActionCancel(
        showOnlyOnEditing: true,
        onPressed: () {
          data[row].isEditing = !data[row].isEditing;
          notifyListeners();
          editingValues.remove(row);
        },
      ));
    }
    if (showDeleteAction) {
      actions.add(DynamicTableActionDelete(
        showOnlyOnEditing: !showDeleteAction,
        // showAlways: true,
        onPressed: () {
          var response = onRowDelete?.call(
              row,
              cells.map((e) {
                return e.value;
              }).toList());
          if (response == null || response) {
            _selectedCount -= data[row].selected ? 1 : 0;
            data.removeAt(row);
            notifyListeners();
          }
        },
      ));
    }

    if (actions.isNotEmpty) {
      DynamicTableActionsInput actionsInput = DynamicTableActionsInput();
      cellsList.add(
        DataCell(
          actionsInput.getChild(
            data[row].isEditing,
            actions.where((element) {
              if (element.showAlways) {
                return true;
              } else if (element.showOnlyOnEditing && data[row].isEditing) {
                return true;
              } else if (!element.showOnlyOnEditing && !data[row].isEditing) {
                return true;
              }
              return false;
            }).map((e) {
              return e;
            }).toList(),
            row: row,
            column: ++column,
          ),
        ),
      );
    }
    return cellsList;
  }

  List<DataCell> _buildRowCells(List<DynamicTableDataCell> cells, int row) {
    int column = -1;
    List<DataCell> cellsList = cells.map((e) {
      column++;
      var showEditingWidget = data[row].isEditing && columns[column].isEditable;
      return _buildDataCell(e, row, column, showEditingWidget);
    }).toList();
    cellsList.addAll(_addActionsInCell(cells, row, column));
    return cellsList;
  }

  DataCell _buildDataCell(DynamicTableDataCell cell, int index, int columnIndex,
      bool showEditingWidget) {
    var dynamicTableInputType = columns[columnIndex].dynamicTableInputType;
    if (showEditingWidget) {
      if (editingCellsInput[index] == null) {
        editingCellsInput[index] = {};
      }
      editingCellsInput[index]![columnIndex] = dynamicTableInputType;
    }
    return DataCell(
      dynamicTableInputType.getChild(
        showEditingWidget,
        editingValues[index]?[columnIndex] ?? cell.value,
        row: index,
        column: columnIndex,
        onChanged: (value, row, column) {
          if (editingValues[row] == null) {
            editingValues[row] = data[row].cells.map((e) {
              return e.value;
            }).toList();
          }
          editingValues[row]![column] = value;
        },
      ),
      placeholder: cell.placeholder,
      showEditIcon: cell.showEditIcon,
      onTap: cell.onTap,
      onLongPress: cell.onLongPress,
      onTapDown: cell.onTapDown,
      onDoubleTap: cell.onDoubleTap,
      onTapCancel: cell.onTapCancel,
    );
  }
}
