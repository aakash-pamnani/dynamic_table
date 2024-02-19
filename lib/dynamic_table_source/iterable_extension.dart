/**
 * data has the saved values for each row, state information such as isEditing, isSaved and isSelected are also contained in data
 * editingValues has the current edited values of a row
 * keyColumn holds the column index which is considered the key of the data in the table
 */

extension FetchingFirstOrNull<T> on Iterable<T> {
  T? firstOrNull() {
    if (this.isNotEmpty) {
      return this.first;
    } else {
      return null;
    }
  }
}

extension ContainsAnyCheck<T> on Iterable<T> {
  bool containsAny(Iterable<T> other) {
    for (T value in other) {
      if (this.contains(value)) return true;
    }
    return false;
  }
}
