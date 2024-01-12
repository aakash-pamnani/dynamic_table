import 'package:flutter/material.dart';

import 'package:dynamic_table/dynamic_table_data/dynamic_table_data_cell.dart';

/// Row configuration and cell data for a [DynamicTable].
///
/// One row configuration must be provided for each row to
/// display in the table. The list of [DynamicTableDataRow] objects is passed
/// as the `rows` argument to the [DynamicTable.new] constructor.
///
/// The data for this row of the table is provided in the [cells]
/// property of the [DynamicTableDataRow] object.
class DynamicTableDataRow {
  int index;

  /// Called when the user selects or unselects a selectable row.
  ///
  /// If this is not null, then the row is selectable. The current
  /// selection state of the row is given by [selected].
  ///
  /// If any row is selectable, then the table's heading row will have
  /// a checkbox that can be checked to select all selectable rows
  /// (and which is checked if all the rows are selected), and each
  /// subsequent row will have a checkbox to toggle just that row.
  ///
  /// A row whose [onSelectChanged] callback is null is ignored for
  /// the purposes of determining the state of the "all" checkbox,
  /// and its checkbox is disabled.
  ///
  /// If a [DynamicTableDataCell] in the row has its [DynamicTableDataCell.onTap] callback defined,
  /// that callback behavior overrides the gesture behavior of the row for
  /// that particular cell.
  final ValueChanged<bool?>? onSelectChanged;

  /// Called if the row is long-pressed.
  ///
  /// If a [DynamicTableDataCell] in the row has its [DynamicTableDataCell.onTap], [DynamicTableDataCell.onDoubleTap],
  /// [DynamicTableDataCell.onLongPress], [DynamicTableDataCell.onTapCancel] or [DynamicTableDataCell.onTapDown] callback defined,
  /// that callback behavior overrides the gesture behavior of the row for
  /// that particular cell.
  final GestureLongPressCallback? onLongPress;

  /// Whether the row is selected.
  ///
  /// If [onSelectChanged] is non-null for any row in the table, then
  /// a checkbox is shown at the start of each row. If the row is
  /// selected (true), the checkbox will be checked and the row will
  /// be highlighted.
  ///
  /// Otherwise, the checkbox, if present, will not be checked.
  bool selected;

  /// The data for this row.
  ///
  /// There must be exactly as many cells as there are columns in the
  /// table.
  List<DynamicTableDataCell> cells;

  /// The color for the row.
  ///
  /// By default, the color is transparent unless selected. Selected rows has
  /// a grey translucent color.
  ///
  /// The effective color can depend on the [MaterialState] state, if the
  /// row is selected, pressed, hovered, focused, disabled or enabled. The
  /// color is painted as an overlay to the row. To make sure that the row's
  /// [InkWell] is visible (when pressed, hovered and focused), it is
  /// recommended to use a translucent color.
  ///
  /// ```dart
  /// DynamicTableDataRow(
  ///   color: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
  ///     if (states.contains(MaterialState.selected)) {
  ///       return Theme.of(context).colorScheme.primary.withOpacity(0.08);
  ///     }
  ///     return null;  // Use the default value.
  ///   }),
  ///   cells: const <DataCell>[
  ///     // ...
  ///   ],
  /// )
  /// ```
  ///
  MaterialStateProperty<Color?>? color;

  /// Whether the row is in editing mode.
  ///
  /// When a row is in editing mode, the cells will be replaced by
  /// [DataCell]s with appropriate editing widgets.
  ///
  /// See [DataCell] for more details.
  ///
  /// Defaults to false.
  ///
  /// See also:
  /// * [DataCell], which is the cell of a [DataTable] widget.
  bool isEditing;

  /// Creates the configuration for a row of a [DataTable].
  ///
  /// The [cells] argument must not be null.
  DynamicTableDataRow({
    required this.index,
    this.selected = false,
    this.onSelectChanged,
    this.onLongPress,
    this.color,
    this.isEditing = false,
    required this.cells,
  });
}
