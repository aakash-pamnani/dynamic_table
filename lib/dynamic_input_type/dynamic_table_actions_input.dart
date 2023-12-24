part of 'dynamic_table_input_type.dart';

class DynamicTableActionsInput
    extends DynamicTableInputType<List<DynamicTableAction>> {
  @override
  Widget displayWidget(List<DynamicTableAction>? value) {
    return Row(
      children: value!
          .map((e) => InkWell(
                child: e.icon,
                onTap: () {
                  e.onPressed?.call();
                },
              ))
          .toList(),
    );
  }

  @override
  Widget editingWidget(List<DynamicTableAction>? value, Function? onChanged,
      void Function(int row, int column)? onEditComplete,
      int row, int column) {
    return displayWidget(value);
  }

  @override
  void dispose() {}
}
