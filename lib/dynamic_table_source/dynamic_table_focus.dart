import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_source.dart';

mixin DynamicTableFocus implements DynamicTableSourceView {
  DynamicTableFocusData? getRawFocus();
  void updateFocus(DynamicTableFocusData? focus);

  //TODO: in move to next editable column skip also the dropdown columns having no selection values.
  //TODO: disallow touchMode if the data table has no editable columns.
  //TODO: consider pagination when resetting focus and changing focus
  //TODO: in editing cell if esc key is pressed then cancel the editing
  DynamicTableFocusData resetFocus(DynamicTableFocusData? focus) {
    if (focus == null) return DynamicTableFocusData(row: 0, column: -1);

    var isRowOutOfFocus = () => !(focus.row >= 0 && focus.row < getDataLength());
    var isColumnOutOfFocus =
        () => !(focus.column >= -1 && focus.column < getColumnsLength());

    if (isRowOutOfFocus() && isColumnOutOfFocus())
      return DynamicTableFocusData(row: 0, column: -1);

    //resetting row focus if it is out of focus
    if (isRowOutOfFocus())
      return DynamicTableFocusData(row: 0, column: -1);

    //resetting column focus if it is out of focus
    if (isColumnOutOfFocus())
      return DynamicTableFocusData(row: focus.row, column: -1);

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

  bool checkFocus(int row, int column) {
    var focus = getFocus();
    return focus.row == row && focus.column == column;
  }

  void focusNextRow(int row, { void onFocusNextRow(int oldRow)?, void onFocusLastRow()? }) {
    updateFocus(DynamicTableFocusData(row: row + 1, column: -1));
    onFocusNextRow?.call(row);
    //checking if last row
    if (row == (getDataLength() - 1)) {
      onFocusLastRow?.call();
    }
  }

  void focusNextField(int row, int column, { void onFocusNextRow(int oldRow)?, void onFocusLastRow()? }) {
    var focus =
        moveToNextEditableColumn(DynamicTableFocusData(row: row, column: column));

    //checking if there are no more editable columns
    if ((focus.column) == getColumnsLength()) {
      focusNextRow(focus.row, onFocusLastRow: onFocusLastRow, onFocusNextRow: onFocusNextRow);
      return;
    }

    updateFocus(focus);
  }

  void focusThisField(int row, int column, { void onFocusThisField(int row)? }) {
    updateFocus(DynamicTableFocusData(row: row, column: column));
    onFocusThisField?.call(row);
  }
}
