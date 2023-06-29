# Dynamic_Table

A fully customized data table for your flutter project in which you can edit, delete, add and update values in the table.

It is build upon [PaginatedDataTable](https://api.flutter.dev/flutter/material/PaginatedDataTable-class.html)

## Getting Started

To use Dynamic_Table just add DynamicTable Widget

See Example here [https://dynamic-table-example.web.app/](https://dynamic-table-example.web.app/)

<video controls>
  <source src="video/dynamic-table.mp4" type="video/mp4">
</video>
## Features

- Add new values
- Update values
- Save values
- Delete values
- Customize style
- Non Editable Column

## Usage

### Non Editable Table

```dart
DynamicTable(
      header: const Text("Person Table (Non Editable)"),
      rowsPerPage: 5,
      showFirstLastButtons: true,
      availableRowsPerPage: const [
        5,
        10,
        15,
        20,
      ],
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
              return genderDropdown.map((e) => Text(e)).toList(growable: false);
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
    );
```

## Editable Table

```dart
DynamicTable(
    header: const Text("Person Table"),
    onRowEdit: (index, row) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Row Edited index:$index row:$row"),
        ),
      );
    },
    onRowDelete: (index, row) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Row Deleted index:$index row:$row"),
        ),
      );
    },
    onRowSave: (index, old, newValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Row Saved index:$index old:$old new:$newValue"),
        ),
      );
    },
    showActions: _showActions,
    showAddRowButton: _showAddRowButton,
    showDeleteAction: _showDeleteAction,
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
    actionColumnTitle: "My Action Title",
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
```

# Available Methods

First create a GlobalKey of DynamicTableState.
Pass the key to DynmaicTable constructor.

```dart
final tableKey = GlobalKey<DynamicTableState>();
DynamicTable(key:tableKey);
```

## void addRow()

```dart
tableKey.currentState?.addRow();
```

Add new empty row at the 0th position in the table. The [showActions] parameter must be true because the row will be added in editing mode and to save the row we need actions.

NOTE: Cant add value to Non-Editable Columns.
<br>
<br>

## addRowWithValues(List<dynamic> values, {bool isEditing = false})

```dart
tableKey.currentState?.addRowWithValues([column1,column2...columnN]);
```

Add new row with values at the 0th position in the table.

If [isEditing] passed [true] the newly added row will be in editing mode. And if false the row will be in non editing mode.

If [isEditing] is true then [showActions] must also be true.

The [values].length must be equal to columns.length.

### deleteRow(int index)

```dart
tableKey.currentState?.deleteRow(0);
```

Delete the row at the given [index].

[index] should be index < rows.length && index>=0.

### updateRow(int index, List<dynamic> values)

```dart
tableKey.currentState.?.updateRow(0, dummyData[column1,column2,...,columnN]);
```

Update the column at [index] with the given values.

The [values].length must be equal to columns.length.

[index] should be index < rows.length && index>=0.

### insertRow(int index, List<dynamic> values, {bool isEditing = false,})

```dart
tableKey.currentState?.insertRow(
30, dummyData[column1,column2,...,columnN]
isEditing: true);
```

Insert new row at [index] with values at the in the table.

If [isEditing] passed [true] the newly added row will be in editing mode. And if false the row will be in non editing mode.

If [isEditing] is true then [showActions] must also be true.

The [values].length must be equal to columns.length.

### deleteAllRows()

```dart
tableKey.currentState?.deleteAllRows();
```

Delete all the rows from the table.

### deleteSelectedRows()

```dart
tableKey.currentState?.deleteSelectedRows();
```

Delete only selected rows from the table.

### getRowByIndex(int index)

```dart
tableKey.currentState?.getRowByIndex(10)
```

Get the row at [index] index.

The [index] should be index>=0 && index<rows.length.

### getSelectedRows()

```dart
tableKey.currentState?.getSelectedRows()
```

Get all the selected rows in the table.

### getAllRows()

```dart
tableKey.currentState?.getAllRows()
```

Get all the rows in the table.

### updateAllRows(List<List<dynamic>> data)

```dart
tableKey.currentState?.updateAllRows(data);
```

Update all the rows inside the table with the given data.

The [data].length must be equal to rows.length.

And data[].length for all must be equal to columns.length.

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
