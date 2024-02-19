import 'dart:math';

import 'package:dynamic_table/dynamic_table.dart';
import 'package:flutter/material.dart';

import 'dummy_data.dart';

void main() {
  runApp(const MyApp());
}

enum MyDataField {
  name(0), uniqueId(1), birthDate(2), gender(3), otherInfo(4);

  final int _index;

  int get idx => _index;

  const MyDataField(int index) : _index = index;
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tableKey = GlobalKey<DynamicTableState>();
  Map<String, List<Comparable<dynamic>?>> myData = dummyData.asMap().map(
        (key, value) => MapEntry(value[MyDataField.uniqueId.idx] as String, value),
      );
  String actionColumnTitle = "My Action Title";

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
              selectable: true,
              onRowEdit: (key, row) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Row Edited key:$key row:$row"),
                  ),
                );
                return true;
              },
              onRowDelete: (key, row) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Row Deleted key:$key row:$row"),
                  ),
                );
                if (myData.containsKey(key)) myData.remove(key);
                return true;
              },
              onRowSave: (key, old, newValue) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content:
                //         Text("Row Saved index:$index old:$old new:$newValue"),
                //   ),
                // );
                if (newValue[MyDataField.name.idx] == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Name cannot be null"),
                    ),
                  );
                  return null;
                }

                if (newValue[MyDataField.name.idx].toString().length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Name must be atleast 3 characters long"),
                    ),
                  );
                  return null;
                }
                if (newValue[MyDataField.name.idx].toString().length > 20) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Name must be less than 20 characters long"),
                    ),
                  );
                  return null;
                }
                if (key == null) {
                  //If newly added row then add unique ID
                  newValue[MyDataField.uniqueId.idx] = (Random().nextInt(500) + 100)
                      .toString(); // to add Unique ID because it is not editable

                  while (myData.containsKey(newValue[MyDataField.uniqueId.idx])) {
                    newValue[MyDataField.uniqueId.idx] = (Random().nextInt(500) + 100).toString();
                  }
                }
                myData.putIfAbsent(
                    newValue[MyDataField.uniqueId.idx]! as String, () => newValue); // Update data
                if (newValue[MyDataField.name.idx] == null) {
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
              actionColumnTitle: actionColumnTitle,
              selectAllToolTip: 'Select all odd Values',
              unselectAllToolTip: 'Unselect all Values',
              showSelectAllButton: true,
              filterSelectionByIndex: (index) => (index + 1).isOdd,
              showCheckboxColumn: true,
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
                      setState(() {
                        actionColumnTitle = "New Action Title";
                        myData['101'] = [
                          "Aakash",
                          "101",
                          DateTime(2000, 2, 11),
                          genderDropdown[0],
                          "Some more info about Aakash"
                        ];
                        myData['100'] = [
                          "Raksha",
                          "100",
                          DateTime(2000, 2, 11),
                          genderDropdown[1],
                          "Some other info about Raksha"
                        ];
                      });
                    },
                    icon: const Icon(Icons.refresh))
              ],
              rows: Map<String, List<Comparable<dynamic>?>>.from(myData),
              columns: [
                DynamicTableDataColumn(
                    label:
                        Container(color: Colors.red, child: const Text("Name")),
                    dynamicTableInputType: DynamicTableInputType.text()),
                DynamicTableDataColumn(
                    label: const Text("Unique ID"),
                    isKeyColumn: true,
                    isEditable: false,
                    dynamicTableInputType: DynamicTableInputType.text()),
                DynamicTableDataColumn(
                  label: const Text("Birth Date"),
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
                    readOnly: false
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
