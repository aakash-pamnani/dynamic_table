import 'dart:math';

import 'package:dynamic_table/dynamic_table.dart';
import 'package:flutter/material.dart';

import 'dummy_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tableKey = GlobalKey<DynamicTableState>();
  var myData = dummyData.toList();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Dynamic Table Example"),
        ),
        body: Builder(builder: (context) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: DynamicTable(
              key: tableKey,
              header: const Text("Person Table"),
              editOneByOne: true,
              autoSaveRows: true,
              addRowAtTheEnd: true,
              showActions: false,
              showAddRowButton: true,
              showDeleteOrCancelAction: true,
              touchMode: true,
              selectable: false,
              onRowEdit: (index, row) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Row Edited index:$index row:$row"),
                  ),
                );
                myData[index] = row;
                return true;
              },
              onRowDelete: (index, row) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Row Deleted index:$index row:$row"),
                  ),
                );
                myData.removeAt(index);
                return true;
              },
              onRowSave: (index, old, newValue) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content:
                //         Text("Row Saved index:$index old:$old new:$newValue"),
                //   ),
                // );
                if (newValue[0] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Name cannot be null"),
                    ),
                  );
                  return null;
                }

                if (newValue[0].toString().length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Name must be atleast 3 characters long"),
                    ),
                  );
                  return null;
                }
                if (newValue[0].toString().length > 20) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Name must be less than 20 characters long"),
                    ),
                  );
                  return null;
                }
                if (newValue[1] == null) {
                  //If newly added row then add unique ID
                  newValue[1] = Random()
                      .nextInt(500)
                      .toString(); // to add Unique ID because it is not editable
                }
                myData.insert(index, newValue); // Update data
                if (newValue[0] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Name cannot be null"),
                    ),
                  );
                  return null;
                }
                return newValue;
              },
              rowsPerPage: 5,
              showFirstLastButtons: true,
              availableRowsPerPage: const [
                5,
                10,
                15,
                20,
              ],
              dataRowMinHeight: 60,
              dataRowMaxHeight: 60,
              columnSpacing: 60,
              actionColumnTitle: "My Action Title",
              showCheckboxColumn: false,
              onSelectAll: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: value ?? false
                        ? const Text("All Rows Selected")
                        : const Text("All Rows Unselected"),
                  ),
                );
              },
              onRowsPerPageChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Rows Per Page Changed to $value"),
                  ),
                );
              },
              actions: [
                IconButton(
                  onPressed: () {
                    for (var i = 0; i < myData.length; i += 2) {
                      tableKey.currentState?.selectRow(i, isSelected: true);
                    }
                  },
                  icon: const Icon(Icons.select_all),
                  tooltip: "Select all odd Values",
                ),
                IconButton(
                  onPressed: () {
                    for (var i = 0; i < myData.length; i += 2) {
                      tableKey.currentState?.selectRow(i, isSelected: false);
                    }
                  },
                  icon: const Icon(Icons.deselect_outlined),
                  tooltip: "Unselect all odd Values",
                ),
              ],
              rows: List.generate(
                myData.length,
                (index) => DynamicTableDataRow(
                  onSelectChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: value ?? false
                            ? Text("Row Selected index:$index")
                            : Text("Row Unselected index:$index"),
                      ),
                    );
                  },
                  index: index,
                  cells: List.generate(
                    myData[index].length,
                    (cellIndex) => DynamicTableDataCell(
                      value: myData[index][cellIndex],
                    ),
                  ),
                ),
              ),
              columns: [
                DynamicTableDataColumn(
                    label:
                        Container(color: Colors.red, child: const Text("Name")),
                    onSort: (columnIndex, ascending) {},
                    dynamicTableInputType: DynamicTableInputType.text()),
                DynamicTableDataColumn(
                    label: const Text("Unique ID"),
                    onSort: (columnIndex, ascending) {},
                    isEditable: false,
                    dynamicTableInputType: DynamicTableInputType.text()),
                DynamicTableDataColumn(
                  label: const Text("Birth Date"),
                  onSort: (columnIndex, ascending) {},
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
                  dynamicTableInputType: DynamicTableInputType.dropDown<String>(
                    items: genderDropdown
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(growable: false),
                    selectedItemBuilder: (context) {
                      return genderDropdown
                          .map((e) => Text(e))
                          .toList(growable: false);
                    },
                    decoration: const InputDecoration(
                        hintText: "Select Gender",
                        border: OutlineInputBorder()),
                    displayBuilder: (value) =>
                        value ??
                        "", // How the string will be displayed in non editing mode
                  ),
                ),
                DynamicTableDataColumn(
                  label: const Text("Other Info"),
                  onSort: (columnIndex, ascending) {},
                  isEditable: false,
                  dynamicTableInputType: DynamicTableInputType.text(
                    decoration: const InputDecoration(
                      hintText: "Enter Other Info",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
