class DynamicTableFocusData {
  const DynamicTableFocusData({required this.row, required this.column, this.previous});

  final int row;
  final int column;
  final DynamicTableFocusData? previous;

  @override
  String toString() {
    return 'row: ' + row.toString() + ' | ' + 'column: ' + column.toString();
  }

  DynamicTableFocusData shift(
      Map<int, int> shiftData) {
    var previousFocus = this.previous?.shift(shiftData);
    if (shiftData.containsKey(this.row)) {
      return DynamicTableFocusData(
          row: shiftData[this.row]!, column: this.column, previous: previousFocus);
    }
    if (previousFocus != this.previous) {
      return DynamicTableFocusData(
          row: this.row, column: this.column, previous: previousFocus);
    }
    return this;
  }
}