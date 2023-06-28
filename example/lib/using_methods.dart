import 'dart:math';

import 'package:dynamic_table/dynamic_table.dart';
import 'package:flutter/material.dart';

import 'dummy_data.dart';

class UsingMethods extends StatelessWidget {
  const UsingMethods({super.key});

  @override
  Widget build(BuildContext context) {
    final tableKey = GlobalKey<DynamicTableState>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    tableKey.currentState?.addRow();
                  },
                  child: const Text(
                      "Add Row (Show actions must be true to save Data)"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    tableKey.currentState?.addRowWithValues(
                        dummyData[Random().nextInt(50)],
                        isEditing: true); //using random data
                  },
                  child: const Text("Add Row With Values"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    tableKey.currentState?.deleteRow(0);
                  },
                  child: const Text("Delete 0th Row"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    tableKey.currentState
                        ?.updateRow(0, dummyData[Random().nextInt(50)]);
                  },
                  child: const Text("Update 0th Row"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    tableKey.currentState?.insertRow(
                        3, dummyData[Random().nextInt(50)],
                        isEditing: true);
                  },
                  child: const Text("Insert Row at 3rd index"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    tableKey.currentState?.insertRow(
                        3, dummyData[Random().nextInt(50)],
                        isEditing: false);
                  },
                  child: const Text("Insert Row at 3rd index (Non Editing)"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    tableKey.currentState?.deleteAllRows();
                  },
                  child: const Text("Delete All Rows"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    tableKey.currentState?.deleteSelectedRows();
                  },
                  child: const Text("Delete Selected Rows"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    if ((tableKey.currentState?.getAllRows().length ?? 0) <
                        10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Add 10 rows first"),
                        ),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "10th Row: ${tableKey.currentState?.getRowByIndex(10)}"),
                      ),
                    );
                  },
                  child: const Text("Get 10th Row"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Selected Rows: ${tableKey.currentState?.getSelectedRows()}"),
                      ),
                    );
                  },
                  child: const Text("Get Selected Rows"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "All Rows: ${tableKey.currentState?.getAllRows().length}"),
                      ),
                    );
                  },
                  child: const Text("Get All Rows"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    tableKey.currentState?.updateAllRows(
                      List.generate(
                        tableKey.currentState?.getAllRows().length ?? 0,
                        (index) => dummyData[Random().nextInt(50)],
                      ),
                    );
                  },
                  child: const Text("Update all Rows"),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: DynamicTable(
            key: tableKey,
            header: const Text("Person Table (Non Editable)"),
            rowsPerPage: 5,
            availableRowsPerPage: const [
              5,
              10,
              15,
              20,
            ],
            showActions: true,
            dataRowHeight: 60,
            columnSpacing: 60,
            showCheckboxColumn: true,
            onRowsPerPageChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Rows Per Page Changed to $value"),
                ),
              );
            },
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
                  dynamicTableInputType: DynamicTableTextInput()),
              // dynamicTableInputType: DynamicTableInputType.text()),
              DynamicTableDataColumn(
                  label: const Text("Unique ID"),
                  isEditable: false,
                  dynamicTableInputType: DynamicTableTextInput()),
              // dynamicTableInputType: DynamicTableInputType.text()),
              DynamicTableDataColumn(
                label: const Text("Birth Date"),
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
