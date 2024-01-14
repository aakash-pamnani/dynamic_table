extension Shifting<T> on Map<int , T> {
  void shiftKeys(Map<int , int > shiftData, int length,
      {void Function(T? value)? onRemoved}) {
        
    List<int > removed = shiftData.values
        .where((index) => (!shiftData.keys.contains(index) && index < length))
        .toList();
    for (int  removedIndex in removed) {
      onRemoved?.call(this[removedIndex]);
    }

    var temp = this.map(
      (key, value) {
        if (shiftData.containsKey(key)) {
          return MapEntry(shiftData[key]!, value);
        }
        return MapEntry(key, value);
      },
    );
    this.removeWhere((key, value) => true);
    this.addAll(temp);
  }
}
