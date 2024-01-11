extension Shifting<T> on Map<num, T> {
  void shiftKeys(Map<num, num> shiftData, int length,
      {void Function(T? value)? onRemoved}) {
    List<num> removed = shiftData.values
        .where((index) => (!shiftData.keys.contains(index) && index < length))
        .toList();
    for (num removedIndex in removed) {
      onRemoved?.call(this[removedIndex]);
    }
    this.addAll(this.map(
      (key, value) {
        if (shiftData.containsKey(key)) {
          return MapEntry(shiftData[key]!, value);
        }
        return MapEntry(key, value);
      },
    ));
  }
}
