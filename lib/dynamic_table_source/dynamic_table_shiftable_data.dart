import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_cell.dart';
import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_row.dart';

/**
 * data has the saved values for each row, state information such as isEditing, isSaved and isSelected are also contained in data
 * editingValues has the current edited values of a row
 * keyColumn holds the column index which is considered the key of the data in the table
 */

class DynamicTableShiftableData {
  DynamicTableShiftableData(List<DynamicTableDataRow> data,
      {void Function(Map<int, int> shiftData)? onShift})
      : _data = data;

  final List<DynamicTableDataRow> _data;

  void Function(Map<int, int> shiftData)? onShift;

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
    onShift?.call(shiftData);
  }

  void insert(int index, int columnsLength) {
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

  void sortByColumn(int sortColumnIndex) {
    _data.sort((a, b) =>
        a.cells[sortColumnIndex].value
            ?.compareTo(b.cells[sortColumnIndex].value) ??
        (b.cells[sortColumnIndex].value == null ? 0 : 1));
    shift();
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

  void updateRow(int row, int columnsLength, List<dynamic> values) {
    for (int index = 0; index < columnsLength; index++) {
      _data[row].cells[index].value = values[index];
    }
  }

  bool isEmpty(int row) {
    return _data[row].cells.every((cell) => cell.value == null);
  }

  dynamic getSavedValue(int row, int column) {
    return _data[row].cells[column].value;
  }

  List<dynamic> getSavedValues(int row) {
    return _data[row]
        .cells
        .map(
          (cell) => cell.value,
        )
        .toList();
  }

  List<List<dynamic>> getAllSavedValues() {
    List<List<dynamic>> result = [];
    for (int row in List.generate(getDataLength(), (index) => index)) {
      result.add(getSavedValues(row));
    }
    return result;
  }

  List<List<dynamic>> getAllSelectedSavedValues() {
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
