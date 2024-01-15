import 'package:dynamic_table/dynamic_table_source/dynamic_table_focus_data.dart';
import 'package:dynamic_table/dynamic_table_source/dynamic_table_source.dart';
import 'package:dynamic_table/dynamic_table_source/reference.dart';

mixin DynamicTableFocus implements DynamicTableSourceQuery {
  DynamicTableFocusData? getRawFocus();
  void updateFocus(DynamicTableFocusData? focus);

  //TODO: focus the selection list in the dropdown controls instead of the outter container
  //TODO: in editing cell if esc key is pressed then cancel the editing
  DynamicTableFocusData resetFocus(DynamicTableFocusData? focus) {
    if (focus == null) return DynamicTableFocusData(row: 0, column: -1);

    var isRowOutOfFocus =
        () => !(focus.row >= 0 && focus.row < getDataLength());
    var isColumnOutOfFocus = () => !(focus.column >= -1 &&
        focus.column < getColumnsQuery().getColumnsLength());
    var doesRowExceedDataLength = () => focus.row >= getDataLength();

    if (isRowOutOfFocus() && isColumnOutOfFocus()) {
      return DynamicTableFocusData(row: 0, column: -1);
    }

    //resetting row focus if it is out of focus
    if (isRowOutOfFocus()) {
      if (doesRowExceedDataLength()) {
        return DynamicTableFocusData(row: getDataLength() - 1, column: -1);
      }
      return DynamicTableFocusData(row: 0, column: -1);
    }

    //resetting column focus if it is out of focus
    if (isColumnOutOfFocus()) {
      return DynamicTableFocusData(row: focus.row, column: -1);
    }

    return focus;
  }

  bool isColumnNotAFocusTarget(DynamicTableFocusData focus, int columnIncrement) {
    return (!getColumnsQuery()
            .isColumnEditable(focus.column + columnIncrement) ||
        isDropdownColumnAndHasNoDropdownValues(
            Reference<int>(value: focus.row), focus.column + columnIncrement));
  }

  ({bool noMoreEditableColumns, DynamicTableFocusData focus})
      moveToNextEditableColumn(DynamicTableFocusData focus) {
    var columnIncrement = 1;
    while (((focus.column + columnIncrement) <
            getColumnsQuery().getColumnsLength()) &&
        isColumnNotAFocusTarget(focus, columnIncrement)) {
      columnIncrement = columnIncrement + 1;
    }
    return (
      noMoreEditableColumns: (focus.column + columnIncrement) ==
          getColumnsQuery().getColumnsLength(),
      focus: DynamicTableFocusData(
          row: focus.row, column: focus.column + columnIncrement)
    );
  }

  ({bool noMoreEditableColumns, DynamicTableFocusData focus})
      moveToPreviousEditableColumn(DynamicTableFocusData focus) {
    var columnIncrement = -1;
    while (((focus.column + columnIncrement) > -1) &&
        isColumnNotAFocusTarget(focus, columnIncrement)) {
      columnIncrement = columnIncrement - 1;
    }
    return (
      noMoreEditableColumns: (focus.column + columnIncrement) == -1,
      focus: DynamicTableFocusData(
          row: focus.row, column: focus.column + columnIncrement)
    );
  }

  DynamicTableFocusData getFocus() {
    var focus = resetFocus(getRawFocus());
    if (focus.column == -1) focus = moveToNextEditableColumn(focus).focus;
    if (focus.column == getColumnsQuery().getColumnsLength()) focus = moveToPreviousEditableColumn(focus).focus;
    return focus;
  }

  bool checkFocus(Reference<int> row, int column) {
    var focus = getFocus();
    return focus.row == row.value && focus.column == column;
  }

  void _focusPreviousRow(Reference<int> row,
      {void onFocusPreviousRow(Reference<int> oldRow)?}) {
    //checking if first row
    if (getRawFocus() != null && getRawFocus()!.row == 0) {
      return;
    }
    updateFocus(DynamicTableFocusData(row: row.value - 1, column: getColumnsQuery().getColumnsLength()));
    onFocusPreviousRow?.call(row);
  }

  void focusPreviousField(Reference<int> row, int column,
      {void onFocusPreviousRow(Reference<int> oldRow)?}) {
    var (:noMoreEditableColumns, :focus) = moveToPreviousEditableColumn(
        DynamicTableFocusData(row: row.value, column: column));

    if (noMoreEditableColumns) {
      _focusPreviousRow(row, onFocusPreviousRow: onFocusPreviousRow);
      return;
    }

    updateFocus(focus);
  }

  void _focusNextRow(Reference<int> row,
      {void onFocusNextRow(Reference<int> oldRow)?, void onFocusLastRow()?}) {
    updateFocus(DynamicTableFocusData(row: row.value + 1, column: -1));
    onFocusNextRow?.call(row);
    //checking if last row
    if (getRawFocus() != null && getRawFocus()!.row == (getDataLength())) {
      onFocusLastRow?.call();
    }
  }

  void focusNextField(Reference<int> row, int column,
      {void onFocusNextRow(Reference<int> oldRow)?, void onFocusLastRow()?}) {
    var (:noMoreEditableColumns, :focus) = moveToNextEditableColumn(
        DynamicTableFocusData(row: row.value, column: column));

    if (noMoreEditableColumns) {
      _focusNextRow(row,
          onFocusLastRow: onFocusLastRow, onFocusNextRow: onFocusNextRow);
      return;
    }

    updateFocus(focus);
  }

  void focusThisField(Reference<int> row, int column,
      {void onFocusThisField(Reference<int> row)?}) {
    updateFocus(DynamicTableFocusData(row: row.value, column: column));
    onFocusThisField?.call(row);
  }

  void focusThisRow(Reference<int> row) {
    updateFocus(DynamicTableFocusData(row: row.value, column: -1));
  }

  DynamicTableFocusData? shiftFocus(
      DynamicTableFocusData? focus, Map<int, int> shiftData) {
    if (focus != null && shiftData.containsKey(focus.row)) {
      return DynamicTableFocusData(
          row: shiftData[focus.row]!, column: focus.column);
    }
    return focus;
  }
}
