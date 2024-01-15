class DynamicTableFocusData {
  const DynamicTableFocusData({required this.row, required this.column});

  final int row;
  final int column;

  @override
  String toString() {
    return 'row: ' + row.toString() + ' | ' + 'column: ' + column.toString();
  }
}