import 'package:dynamic_table/dynamic_table.dart';
import 'package:flutter/material.dart';

import 'dummy_data.dart';

class NonEditableTable extends StatefulWidget {
  const NonEditableTable({super.key});

  @override
  State<NonEditableTable> createState() => _NonEditableTableState();
}

class _NonEditableTableState extends State<NonEditableTable> {
  bool _showFirstLastButtons = true;
  bool _showCheckboxColumn = true;
  bool _showRowsPerPage = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _showFirstLastButtons,
                  onChanged: (value) {
                    setState(() {
                      _showFirstLastButtons = value;
                    });
                  },
                ),
                const Text("Show First Last Buttons"),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _showCheckboxColumn,
                  onChanged: (value) {
                    setState(() {
                      _showCheckboxColumn = value;
                    });
                  },
                ),
                const Text("Show Checkbox Column"),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _showRowsPerPage,
                  onChanged: (value) {
                    setState(() {
                      _showRowsPerPage = value;
                    });
                  },
                ),
                const Text("Show Rows Per Page"),
              ],
            ),
          ],
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: DynamicTable(
            header: const Text("Person Table (Non Editable)"),
            rowsPerPage: 5,
            showFirstLastButtons: _showFirstLastButtons,
            availableRowsPerPage: const [
              5,
              10,
              15,
              20,
            ],
            dataRowHeight: 60,
            columnSpacing: 60,
            showCheckboxColumn: _showCheckboxColumn,
            onRowsPerPageChanged: _showRowsPerPage
                ? (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Rows Per Page Changed to $value"),
                      ),
                    );
                  }
                : null,
            rows: List.generate(
              dummyData.length,
              (index) => DynamicTableDataRow(
                index: index,
                onSelectChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: value ?? false
                          ? Text("Row Selected index:$index")
                          : Text("Row Unselected index:$index"),
                    ),
                  );
                },
                cells: List.generate(
                  dummyData[index].length,
                  (cellIndex) => DynamicTableDataCell(
                    value: dummyData[index][cellIndex],
                  ),
                ),
              ),
            ),
            columns: [
              DynamicTableDataColumn(
                  label: const Text("Name"),
                  onSort: (columnIndex, ascending) {},
                  dynamicTableInputType: DynamicTableTextInput()),
              // dynamicTableInputType: DynamicTableInputType.text()),
              DynamicTableDataColumn(
                  label: const Text("Unique ID"),
                  onSort: (columnIndex, ascending) {},
                  isEditable: false,
                  dynamicTableInputType: DynamicTableTextInput()),
              // dynamicTableInputType: DynamicTableInputType.text()),
              DynamicTableDataColumn(
                label: const Text("Birth Date"),
                onSort: (columnIndex, ascending) {},
                // dynamicTableInputType: DynamicTableDateInput()
                dynamicTableInputType: DynamicTableInputType.date(
                  context: context,
                  decoration: const InputDecoration(
                      hintText: "Select Birth Date",
                      suffixIcon: Icon(Icons.date_range),
                      border: OutlineInputBorder()),
                  initialDate: DateTime(1900),
                  lastDate: DateTime.now().add(
                    const Duration(days: 365),
                  ),
                ),
              ),
              DynamicTableDataColumn(
                label: const Text("Gender"),
                // dynamicTableInputType: DynamicTableDropDownInput<String>()
                dynamicTableInputType: DynamicTableInputType.dropDown<String>(
                  items: genderDropdown,
                  selectedItemBuilder: (context) {
                    return genderDropdown
                        .map((e) => Text(e))
                        .toList(growable: false);
                  },
                  decoration: const InputDecoration(
                      hintText: "Select Gender", border: OutlineInputBorder()),
                  displayBuilder: (value) =>
                      value ??
                      "", // How the string will be displayed in non editing mode
                  itemBuilder: (value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  },
                ),
              ),
              DynamicTableDataColumn(
                  label: const Text("Other Info"),
                  onSort: (columnIndex, ascending) {},
                  dynamicTableInputType: DynamicTableInputType.text(
                    decoration: const InputDecoration(
                      hintText: "Enter Other Info",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 100,
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
