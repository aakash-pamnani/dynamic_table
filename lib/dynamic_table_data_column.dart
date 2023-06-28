import 'package:flutter/material.dart';

import 'dynamic_table.dart';

@immutable
class DynamicTableDataColumn {
  /// Typically, this will be a [Text] widget. It could also be an
  /// [Icon] (typically using size 18), or a [Row] with an icon and
  /// some text.
  ///
  /// The [label] is placed within a [Row] along with the
  /// sort indicator (if applicable). By default, [label] only occupy minimal
  /// space. It is recommended to place the label content in an [Expanded] or
  /// [Flexible] as [label] to control how the content flexes. Otherwise,
  /// an exception will occur when the available space is insufficient.
  ///
  /// By default, [DefaultTextStyle.softWrap] of this subtree will be set to false.
  /// Use [DefaultTextStyle.merge] to override it if needed.
  ///
  /// The label should not include the sort indicator.
  final Widget label;

  /// The column heading's tooltip.
  ///
  /// This is a longer description of the column heading, for cases
  /// where the heading might have been abbreviated to keep the column
  /// width to a reasonable size.
  final String? tooltip;

  /// Whether this column represents numeric data or not.
  ///
  /// The contents of cells of columns containing numeric data are
  /// right-aligned.
  final bool numeric;

  /// Called when the user asks to sort the table using this column.
  ///
  /// If null, the column will not be considered sortable.
  ///
  /// See [DynamicTable.sortColumnIndex] and [DynamicTable.sortAscending].
  final DataColumnSortCallback? onSort;

  /// The type of input that will be used in the cells of this column.
  ///
  /// For example you can use [DynamicTableInputType.text] or directly create a instance of [DynamicTableTextInput].
  ///
  /// If you want to create a custom input type, you can extend [DynamicTableInputType] (Beta).
  ///
  /// Available input types: text, dropdown, date.
  final DynamicTableInputType dynamicTableInputType;

  /// Whether this column is editable or not.
  ///
  /// If true, the cells of this column will be editable.
  /// If false, the cells of this column will not be editable.
  ///
  /// Default value is true.
  final bool isEditable;

  /// Creates the configuration for a column of a [DynamicTable].
  ///
  /// The [label] argument must not be null.
  /// The column heading.
  ///
  const DynamicTableDataColumn(
      {required this.label,
      this.tooltip,
      this.numeric = false,
      this.onSort,
      this.isEditable = true,
      required this.dynamicTableInputType});
}
