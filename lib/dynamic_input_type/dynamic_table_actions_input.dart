part of 'dynamic_table_input_type.dart';

class DynamicTableActionsInput
    extends DynamicTableInputType<List<DynamicTableAction>> {
  @override
  Widget displayWidget(List<DynamicTableAction>? value, bool focused, void Function()? onEditComplete, ) {
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
      void Function()? onEditComplete,
      void Function()? focusThisField,
      bool focused) {
    return displayWidget(value, focused, onEditComplete);
  }

  @override
  void dispose() {}
}
