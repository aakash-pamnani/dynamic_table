import 'package:flutter/gestures.dart';

/// The data for a cell of a [DynamicTable].
///
/// One list of [DynamicTableDataCell] objects must be provided for each [DynamicTableDataRow]
/// in the [DynamicTable], in the new [DynamicTableDataRow] constructor's `cells`
/// argument.
class DynamicTableDataCell {
  dynamic value;

  /// If this is true, the default text style for the cell is changed
  /// to be appropriate for placeholder text.
  final bool placeholder;

  /// Whether to show an edit icon at the end of the cell.
  ///
  /// This does not make the cell actually editable; the caller must
  /// implement editing behavior if desired (initiated from the
  /// [onTap] callback).
  ///
  /// If this is set, [onTap] should also be set, otherwise tapping
  /// the icon will have no effect.
  final bool showEditIcon;

  /// Called if the cell is tapped.
  ///
  /// If non-null, tapping the cell will call this callback. If
  /// null (including [onDoubleTap], [onLongPress], [onTapCancel] and [onTapDown]),
  /// tapping the cell will attempt to select the row (if
  /// [DynamicTableDataRow.onSelectChanged] is provided).
  final void Function()? onTap;

  /// Called when the cell is double tapped.
  ///
  /// If non-null, tapping the cell will call this callback. If
  /// null (including [onTap], [onLongPress], [onTapCancel] and [onTapDown]),
  /// tapping the cell will attempt to select the row (if
  /// [DynamicTableDataRow.onSelectChanged] is provided).
  final void Function()? onDoubleTap;

  /// Called if the cell is long-pressed.
  ///
  /// If non-null, tapping the cell will invoke this callback. If
  /// null (including [onDoubleTap], [onTap], [onTapCancel] and [onTapDown]),
  /// tapping the cell will attempt to select the row (if
  /// [DynamicTableDataRow.onSelectChanged] is provided).
  final void Function()? onLongPress;

  /// Called if the cell is tapped down.
  ///
  /// If non-null, tapping the cell will call this callback. If
  /// null (including [onTap] [onDoubleTap], [onLongPress] and [onTapCancel]),
  /// tapping the cell will attempt to select the row (if
  /// [DynamicTableDataRow.onSelectChanged] is provided).

  final void Function(TapDownDetails)? onTapDown;

  /// Called if the user cancels a tap was started on cell.
  ///
  /// If non-null, canceling the tap gesture will invoke this callback.
  /// If null (including [onTap], [onDoubleTap] and [onLongPress]),
  /// tapping the cell will attempt to select the
  /// row (if [DynamicTableDataRow.onSelectChanged] is provided).

  final void Function()? onTapCancel;

  /// Creates an object to hold the data for a cell in a [DynamicTable].
  ///
  /// The first argument is the data to show for the cell,
  /// and must not be null.
  ///
  /// If the cell has no data, placeholder
  /// text should be provided instead, and then the [placeholder]
  /// argument should be set to true.
  DynamicTableDataCell({
    required this.value,
    this.placeholder = false,
    this.showEditIcon = false,
    this.onTap,
    this.onLongPress,
    this.onTapDown,
    this.onDoubleTap,
    this.onTapCancel,
  });
}
