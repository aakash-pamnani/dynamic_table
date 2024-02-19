enum SortOrder {
  asc(1), desc(-1);

  const SortOrder(int value) : _value = value;

  final int _value;

  int get comparatorMultiple => _value;

  int operator * (int other) {
    return this.comparatorMultiple * other;
  }

  static SortOrder byOrder({required bool order}) {
    return order? asc: desc;
  }

  SortOrder switchOrder() {
    return switch(this) {
      asc => desc,
      desc => asc,
    };
  }

  bool toBool() {
    return switch(this) {
      asc => true,
      desc => false
    };
  }
}
