import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_source.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';

mixin DynamicTableFocus implements DynamicTableSourceView {
  DynamicTableFocusData? getRawFocus();
  void updateFocus(DynamicTableFocusData? focus);

  //TODO: in move to next editable column skip also the dropdown columns having no selection values.
  //TODO: disallow touchMode if the data table has no editable columns.
  //TODO: in editing cell if esc key is pressed then cancel the editing
  DynamicTableFocusData resetFocus(DynamicTableFocusData? focus) {
    if (focus == null) return DynamicTableFocusData(row: 0, column: -1);

    var isRowOutOfFocus = () => !(focus.row >= 0 && focus.row < getDataLength());
    var isColumnOutOfFocus =
        () => !(focus.column >= -1 && focus.column < getColumnsLength());

    if (isRowOutOfFocus() && isColumnOutOfFocus()) {
      return DynamicTableFocusData(row: 0, column: -1);
    }

    //resetting row focus if it is out of focus
    if (isRowOutOfFocus()) {
      return DynamicTableFocusData(row: 0, column: -1);
    }

    //resetting column focus if it is out of focus
    if (isColumnOutOfFocus()) {
      return DynamicTableFocusData(row: focus.row, column: -1);
    }

    return focus;
  }

  DynamicTableFocusData moveToNextEditableColumn(DynamicTableFocusData focus) {
    //moving to the next editable column
    var i = 1;
    while (((focus.column + i) < getColumnsLength()) &&
        !isColumnEditable(focus.column + i)) {
      i = i + 1;
    }
    return DynamicTableFocusData(row: focus.row, column: focus.column + i);
  }

  DynamicTableFocusData getFocus() {
    var focus = resetFocus(getRawFocus());
    if (focus.column == -1) focus = moveToNextEditableColumn(focus);
    return focus;
  }

  bool checkFocus(Reference<int> row, int column) {
    var focus = getFocus();
    return focus.row == row.value && focus.column == column;
  }

  void focusNextRow(Reference<int> row, { void onFocusNextRow(Reference<int> oldRow)?, void onFocusLastRow()? }) {
    updateFocus(DynamicTableFocusData(row: row.value + 1, column: -1));
    onFocusNextRow?.call(row);
    //checking if last row
    if (getRawFocus() != null && getRawFocus()!.row == (getDataLength())) {
      onFocusLastRow?.call();
    }
  }

  void focusNextField(Reference<int> row, int column, { void onFocusNextRow(Reference<int> oldRow)?, void onFocusLastRow()? }) {
    var focus =
        moveToNextEditableColumn(DynamicTableFocusData(row: row.value, column: column));

    //checking if there are no more editable columns
    if ((focus.column) == getColumnsLength()) {
      focusNextRow(row, onFocusLastRow: onFocusLastRow, onFocusNextRow: onFocusNextRow);
      return;
    }

    updateFocus(focus);
  }

  void focusThisField(Reference<int> row, int column, { void onFocusThisField(Reference<int> row)? }) {
    updateFocus(DynamicTableFocusData(row: row.value, column: column));
    onFocusThisField?.call(row);
  }

  void focusThisRow(Reference<int> row) {
    updateFocus(DynamicTableFocusData(row: row.value, column: -1));
  }

  DynamicTableFocusData? shiftFocus(DynamicTableFocusData? focus, Map<int, int> shiftData) {
    if (focus != null && shiftData.containsKey(focus.row)) {
      return DynamicTableFocusData(row: shiftData[focus.row]!, column: focus.column);
    }
    return focus;
  }
}
