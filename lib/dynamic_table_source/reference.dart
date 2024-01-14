class Reference<T> {
  Reference({required T value}) : _value = value;

  T _value;

  T get value => _value;

  Reference<T> _update(T value) {
    _value = value;
    return this;
  }
}

extension Operations on Reference<int> {
  bool operator >(int other) {
    return this.value > other;
  }

  bool operator >=(int other) {
    return this.value >= other;
  }

  bool operator <(int other) {
    return this.value < other;
  }

  bool operator <=(int other) {
    return this.value <= other;
  }

  void shift(Map<int, int> shiftData) {
    if (shiftData[this.value]!=null) this._update(shiftData[this.value]!);
  }

}