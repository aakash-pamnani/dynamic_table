import 'package:dynamic_table/dynamic_table_focus.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_table/dynamic_input_type/dynamic_table_input_type.dart';
import 'package:dynamic_table/dynamic_table_action.dart';
import 'package:dynamic_table/dynamic_table_data_cell.dart';
import 'package:dynamic_table/dynamic_table_data_column.dart';
import 'package:dynamic_table/dynamic_table_data_row.dart';

class DynamicTableSource extends DataTableSource {
  final String actionColumnTitle;
  final bool showActions;
  final bool showDeleteAction;
  final bool showDeleteAndCancelAction;
  final bool touchMode;
  final bool selectable;
  final bool Function(int index, List<dynamic> row)? onRowEdit;
  final bool Function(int index, bool isEditing)? onRowAdd;
  final bool Function(int index, List<dynamic> row)? onRowDelete;
  final List<dynamic>? Function(
      int index, List<dynamic> oldValue, List<dynamic> newValue)? onRowSave;

  final List<DynamicTableDataRow> data;
  final List<DynamicTableDataColumn> columns;
  Map<int, List<dynamic>> _editingValues = {};
  //freshly added rows that are not save yet even once
  List<int> _unsavedRows = [];
  DynamicTableFocus? _focus;

  //{1:[3,4]} 3 and 4th column are dependent on 1st column
  Map<int, List<int>> dependentOn = {};
  Map<int, Map<int, DynamicTableInputType>> _editingCellsInput = {};
  int _selectedCount = 0;

  DynamicTableSource({
    required this.actionColumnTitle,
    required this.data,
    required this.columns,
    this.showActions = false,
    this.showDeleteAction = false,
    this.showDeleteAndCancelAction = true,
    this.touchMode = true,
    this.selectable = true,
    this.onRowEdit,
    this.onRowAdd,
    this.onRowDelete,
    this.onRowSave,
    DynamicTableSource? lastSource,
  }) : _focus = lastSource?._focus {
    _selectedCount = data.where((element) => element.selected).length;
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
    lastSource?._unsavedRows.sort((a, b) => a.compareTo(b));
    for (int row in lastSource?._unsavedRows??[]) {
      _insertRow(row, List.filled(columns.length, null), isEditing: false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _editingCellsInput.forEach((key, value) {
      value.forEach((key, value) {
        value.dispose();
      });
    });
  }

  void _insertRow(int index, List<dynamic> values, {bool isEditing = false}) {
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
    _shiftValues(index, 1);
    _editingValues[index] = values;
    _unsavedRows.add(index);
  }

  void insertRow(int index, List<dynamic> values, {bool isEditing = false}) {
    if (values.length != columns.length) {
      throw Exception('Values length must match columns');
    }
    if (index < 0 || index > data.length) {
      throw Exception('Index out of bounds');
    }

    if (!(onRowAdd?.call(index, isEditing)??true))
      return;

    _insertRow(index, values, isEditing: isEditing);
    
    notifyListeners();
  }

  void addRow() {
    insertRow(0, List.filled(columns.length, null), isEditing: true);
  }

  void addRowLast() {
    insertRow(data.length, List.filled(columns.length, null), isEditing: true);
  } 

  void addRowWithValues(List<dynamic> values, {bool isEditing = false}) {
    insertRow(0, values, isEditing: isEditing);
  }

  // void _deleteUnsavedRows() {
  //   _unsavedRows.forEach((element) {
  //     deleteRow(element);
  //   });
  //   _unsavedRows.clear();
  // }

  void deleteRow(int index) {
    if (index < 0 || index > data.length) {
      throw Exception('Index out of bounds');
    }
    _selectedCount -= data[index].selected ? 1 : 0;
    data.removeAt(index);
    _disposeInputAt(index);
    _shiftValues(index, -1);
    notifyListeners();
  }

  void deleteAllRows() {
    data.clear();
    _selectedCount = 0;
    _disposAllInputs();
    notifyListeners();
  }

  void deleteSelectedRows() {
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i].selected) {
        deleteRow(i);
      }
    }
  }

  void _shiftValues(int index, int shiftBy) {
    _unsavedRows = _unsavedRows.map((e) {
      if (shiftBy < 0 && e > index) {
        return e + shiftBy;
      } else if (shiftBy > 0 && e >= index) {
        return e + shiftBy;
      }
      return e;
    }).toList();

    _editingValues = _editingValues.map((key, value) {
      if (shiftBy < 0 && key > index) {
        return MapEntry(key + shiftBy, value);
      } else if (shiftBy > 0 && key >= index) {
        return MapEntry(key + shiftBy, value);
      }
      return MapEntry(key, value);
    });

    _editingCellsInput = _editingCellsInput.map((key, value) {
      if (shiftBy < 0 && key > index) {
        return MapEntry(key + shiftBy, value);
      } else if (shiftBy > 0 && key >= index) {
        return MapEntry(key + shiftBy, value);
      }
      return MapEntry(key, value);
    });
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

  List<DynamicTableDataRow> getEditingRows() {
    return data.where((element) => element.isEditing).toList();
  }

  int getEditingRowsCount() {
    return getEditingRows().length;
  }

  bool isEditingRowsCountZero() {
    return getEditingRowsCount()==0;
  }

  bool autoSaveRows() {
    return getEditingRows().map((e) { return saveRow(e.index); }).every((e) => e);
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
    data[index].isEditing = false;
    _unsavedRows.remove(index);
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

  void editRow(int row) {
    var response = onRowEdit?.call(
      row,
      data[row].cells.map((e) {
        return e.value;
    }).toList()) ?? false;
    if ((response) && !data[row].isEditing) {
      data[row].isEditing = !data[row].isEditing;
      _editingValues[row] = data[row].cells.map((e) {
        return e.value;
      }).toList();
      notifyListeners();
      return;
    }
  }

  bool saveRow(int row) {
    List newValue = [];
    List oldValue = data[row].cells.map((e) {
      return e.value;
    }).toList();

    for (int i = 0; i < columns.length; i++) {
      if (columns[i].isEditable) {
        newValue.add(_editingValues[row]?[i] ?? oldValue[i]);
      } else {
        newValue.add(oldValue[i]);
      }
    }

    var response = onRowSave?.call(row, oldValue, newValue);
    if (onRowSave != null && response == null) {
      return false;
    }
    if (response != null) {
      newValue = response;
    }
    for (int i = 0; i < data[row].cells.length; i++) {
      data[row].cells[i].value = newValue[i];
    }
    data[row].isEditing = !data[row].isEditing;
    _unsavedRows.remove(row);
    _disposeInputAt(row);
    notifyListeners();
    return true;
  }

  void selectRow(int index, {required bool isSelected}) {
    if (index < 0 || index > data.length) {
      throw Exception('Index out of bounds');
    }
    if (!selectable) {
      return;
    }
    if (data[index].selected != isSelected) {
      _selectedCount += isSelected ? 1 : -1;
      assert(_selectedCount >= 0, 'Selected count cannot be less than 0');
      data[index].selected = isSelected;
      notifyListeners();
    }
  }

  void selectAllRows({required bool isSelected}) {
    for (int i = 0; i < data.length; i++) {
      selectRow(i, isSelected: isSelected);
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

  int getActionsColumn(int row) {
    return data[row].cells.length;
  }

  DataRow? _buildRow(int index) {
    var datarow = DataRow.byIndex(
      index: index,
      selected: data[index].selected,
      onSelectChanged: selectable? (value) {
        selectRow(index, isSelected: value ?? false);
        data[index].onSelectChanged?.call(value);
      } : null,
      onLongPress: data[index].onLongPress,
      color: data[index].color,
      cells: _buildRowCells(index),
    );
    return datarow;
  }

  List<DataCell> _addActionsInCell(int row) {
    List<DynamicTableAction> actions = [];
    List<DataCell> cellsList = [];

    if (showActions)
      actions.add(
        DynamicTableActionEdit(
          showOnlyOnEditing: false,
          onPressed: () {
            editRow(row);
          },
        ),
      );

    if (showActions)
      actions.add(
        DynamicTableActionSave(
          showOnlyOnEditing: true,
          onPressed: () {
            saveRow(row);
          },
        ),
      );

    if (showActions
    || showDeleteAndCancelAction)
      actions.add(DynamicTableActionCancel(
        showOnlyOnEditing: true,
        onPressed: () {
          data[row].isEditing = !data[row].isEditing;
          if (_unsavedRows.contains(row)) {
            _unsavedRows.remove(row);
            deleteRow(row);
          }
          _disposeInputAt(row);
          notifyListeners();
        },
      ));

    if ((showActions && showDeleteAction)
    || showDeleteAndCancelAction)
      actions.add(DynamicTableActionDelete(
        showOnlyOnEditing: false,
        showAlways: !showDeleteAndCancelAction,
        onPressed: () {
          var response = onRowDelete?.call(
              row,
              data[row].cells.map((e) {
                return e.value;
              }).toList());
          if (response == null || response) {
            deleteRow(row);
            _unsavedRows.remove(row);
          }
        },
      ));

    if (actions.isNotEmpty) {
      DynamicTableActionsInput actionsInput = DynamicTableActionsInput();
      cellsList.add(
        DataCell(
          actionsInput.getChild(
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
            isEditing: data[row].isEditing,
            row: row,
            column: getActionsColumn(row),
          ),
        ),
      );
    }
    return cellsList;
  }

  void _disposeInputAt(int row) {
    _editingCellsInput[row]?.forEach((key, value) {
      value.dispose();
    });
    _editingCellsInput.remove(row);
    _editingValues.remove(row);
  }

  void _disposAllInputs() {
    _editingCellsInput.forEach((key, value) {
      value.forEach((key, value) {
        value.dispose();
      });
    });
    _editingCellsInput.clear();
    _editingValues.clear();
    _unsavedRows.clear();
    data.forEach((element) {
      element.isEditing = false;
    });
  }

  List<DataCell> _buildRowCells(int row) {
    int column = -1;
    List<DataCell> cellsList = data[row].cells.map((e) {
      column++;
      var showEditingWidget = data[row].isEditing && columns[column].isEditable;
      return _buildDataCell(e, row, column, showEditingWidget);
    }).toList();
    cellsList.addAll(_addActionsInCell(row));
    return cellsList;
  }

  DataCell _buildDataCell(DynamicTableDataCell cell, int index, int columnIndex,
      bool showEditingWidget) {
    //TODO: in move to next editable column skip also the dropdown columns having no selection values.
    //TODO: disallow all edit functionality if the data table has no editable columns.
    DynamicTableFocus resetFocus(DynamicTableFocus? focus) {
      if (focus==null)
        return DynamicTableFocus(row: 0, column: -1);

      var isRowOutOfFocus = () => !(focus.row >= 0 && focus.row < data.length);
      var isColumnOutOfFocus = () => !(focus.column >= -1 && focus.column < columns.length);

      if (isRowOutOfFocus() && isColumnOutOfFocus())
        return DynamicTableFocus(row: 0, column: -1);

      //resetting row focus if it is out of focus
      if (isRowOutOfFocus())
        return DynamicTableFocus(row: 0, column: focus.column);

      //resetting column focus if it is out of focus
      if (isColumnOutOfFocus())
        return DynamicTableFocus(row: focus.row, column: -1);

      if (focus.column == -1)
        focus = moveToNextEditableColumn(focus);

      return focus;
    }

    DynamicTableFocus moveToNextEditableColumn(DynamicTableFocus focus) {
      //moving to the next editable column
      var i = 1;
      while (
          ((focus.column + i) < columns.length) && !columns[focus.column + i].isEditable) {
        i = i + 1;
      }
      return DynamicTableFocus(row: focus.row, column: focus.column + i);
    }

    void focusNextRow(int row) {
      saveRow(row);
      //checking if last row
      if (row == (data.length - 1)) {
        addRowLast();
      }
      _focus = DynamicTableFocus(row: row+1, column: -1);
      notifyListeners();
    }

    void focusNextField(int row, int column) {
      var focus = moveToNextEditableColumn(DynamicTableFocus(row: row, column: column));

      //checking if there are no more editable columns
      if ((focus.column) == columns.length) {
        focusNextRow(focus.row);
        return;
      }

      _focus = focus;
      notifyListeners();
    }

    void tapToEdit(int row, int column) {
      editRow(row);
      _focus = DynamicTableFocus(row: row, column: column);
      notifyListeners();
    }

    var dynamicTableInputType = columns[columnIndex].dynamicTableInputType;
    if (showEditingWidget) {
      if (_editingCellsInput[index] == null) {
        _editingCellsInput[index] = {};
      }
      _editingCellsInput[index]![columnIndex] = dynamicTableInputType;
      if (dynamicTableInputType.dependentOn != null) {
        (dynamicTableInputType as DynamicTableDependentDropDownInput)
                .dependentValue =
            _editingValues[index]?[dynamicTableInputType.dependentOn!];
      }
    }
    assert(
        cell.value == null ||
            dynamicTableInputType.typeOf() == cell.value.runtimeType,
        '''Data type of cell value and input type must be same"
        Row: $index
        Column: $columnIndex
        Cell value type: ${cell.value.runtimeType}
        Input type: ${dynamicTableInputType.typeOf()}
        Cell value: ${cell.value}''');

    var focus = resetFocus(_focus);
    return DataCell(
      dynamicTableInputType.getChild(
        focused: touchMode? (focus.row == index && focus.column == columnIndex) : false,
        showEditingWidget ? (_editingValues[index]?[columnIndex]) : cell.value,
        isEditing: showEditingWidget,
        row: index,
        column: columnIndex,
        onChanged: (value, row, column) {
          if (_editingValues[row] == null) {
            _editingValues[row] = data[row].cells.map((e) {
              return e.value;
            }).toList();
          }
          _editingValues[row]![column] = value;
          if (dependentOn[column] != null) {
            dependentOn[column]!.forEach((element) {
              _editingValues[row]![element] = null;
            });
            notifyListeners();
          }
        },
        onEditComplete: touchMode? (row, column) {
            focusNextField(row, column);
        } : null,
      ),
      placeholder: cell.placeholder,
      showEditIcon: cell.showEditIcon,
      onTap: () {
        if (touchMode) if (!showEditingWidget && columns[columnIndex].isEditable) {
          tapToEdit(index, columnIndex);
        }
        cell.onTap?.call();
      },
      onLongPress: cell.onLongPress,
      onTapDown: cell.onTapDown,
      onDoubleTap: cell.onDoubleTap,
      onTapCancel: cell.onTapCancel,
    );
  }
}
