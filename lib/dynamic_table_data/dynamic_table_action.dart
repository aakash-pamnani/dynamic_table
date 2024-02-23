import 'package:flutter/material.dart';

/// This is the actions which you see on the last column of [DynamicTable]
@immutable
abstract class DynamicTableAction {
  /// The [icon] which will be displayed on the last column of [DynamicTable] as action.
  ///
  /// You can use [Icon] or [Image] or any other widget.
  final Widget icon;

  /// The [onPressed] function which will be called when the user clicks on the [icon].
  final void Function()? onPressed;

  /// If [showAlways] is true, the [icon] will be displayed on the last column of [DynamicTable] as action.
  ///
  final bool showAlways;

  /// If [showOnlyOnEditing] is true, the [icon] will be displayed on the last column of [DynamicTable] as action only when the [DynamicTableDataRow.isEditing] is in editing mode.
  final bool showOnlyOnEditing;

  /// This is the actions which you see on the last column of [DynamicTable]

  const DynamicTableAction(
      {required this.icon,
      this.onPressed,
      this.showAlways = false,
      this.showOnlyOnEditing = true})
      : assert(!(showAlways && showOnlyOnEditing),
            'showAlways and showOnlyOnEditing cannot be true at the same time');
}

class DynamicTableActionEdit extends DynamicTableAction {
  const DynamicTableActionEdit(
      {super.icon = const Icon(Icons.edit),
      super.onPressed,
      super.showAlways,
      super.showOnlyOnEditing});
}

class DynamicTableActionSave extends DynamicTableAction {
  const DynamicTableActionSave(
      {super.icon = const Icon(Icons.save),
      super.onPressed,
      super.showAlways,
      super.showOnlyOnEditing});
}

class DynamicTableActionCancel extends DynamicTableAction {
  const DynamicTableActionCancel(
      {super.icon = const Icon(Icons.cancel),
      super.onPressed,
      super.showAlways,
      super.showOnlyOnEditing});
}

class DynamicTableActionDelete extends DynamicTableAction {
  const DynamicTableActionDelete(
      {super.icon = const Icon(Icons.delete),
      super.onPressed,
      super.showAlways,
      super.showOnlyOnEditing});
}
