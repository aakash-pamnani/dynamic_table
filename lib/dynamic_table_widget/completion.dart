import 'package:dynamic_table/dynamic_table_widget/comparables.dart';

enum ActionCompletion {
  Completed,
  Cancelled,
  Edited;
}

class ActionCompletionData<T> {
  final ComparableValueBase<T>? editedValue;

  const ActionCompletionData({ComparableValueBase<T>? editedValue})
      : this.editedValue = editedValue;

  bool isValueEdited() {
    return editedValue != null;
  }

  factory ActionCompletionData.empty() {
    return ActionCompletionData<T>();
  }
}

class ActionCompletionResult<T> {
  ActionCompletionResult({required this.status, required this.data});

  final ActionCompletion status;
  final ActionCompletionData<T> data;

  factory ActionCompletionResult.cancel() {
    return ActionCompletionResult<T>(
        status: ActionCompletion.Cancelled,
        data: ActionCompletionData<T>.empty());
  }

  factory ActionCompletionResult.edit(T editedValue) {
    return ActionCompletionResult<T>(
        status: ActionCompletion.Edited,
        data: ActionCompletionData<T>(
            editedValue: ComparableValueBase<T>.map(editedValue)));
  }

  factory ActionCompletionResult.complete(T editedValue) {
    return ActionCompletionResult<T>(
        status: ActionCompletion.Completed,
        data: ActionCompletionData<T>(
            editedValue: ComparableValueBase<T>.map(editedValue)));
  }
}
